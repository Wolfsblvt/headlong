#!/usr/bin/env bash
# test_resident_cognition.sh — owner/Identity/Leitsatz composition on every cognition path

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

pass=0
fail=0
ok()  { pass=$((pass+1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL %s%s\n' "$1" "${2:+ — $2}"; }

hash_file() { sha256sum "$1" | awk '{print $1}'; }
byte_count() { wc -c < "$1" | tr -d ' '; }
occurrences() { printf '%s' "$1" | grep -Foc "$2" || true; }

assert_once() {
    local path="$1" prompt="$2" marker="$3" count
    count=$(occurrences "$prompt" "$marker")
    if [[ "$count" == 1 ]]; then
        ok "$path contains $marker exactly once"
    else
        bad "$path contains $marker exactly once" "count=$count"
    fi
}

assert_absent() {
    local path="$1" prompt="$2" marker="$3" count
    count=$(occurrences "$prompt" "$marker")
    if [[ "$count" == 0 ]]; then
        ok "$path excludes $marker"
    else
        bad "$path excludes $marker" "count=$count"
    fi
}

report_prompt() {
    local path="$1" prompt="$2" hash bytes
    hash=$(printf '%s' "$prompt" | sha256sum | awk '{print $1}')
    bytes=$(printf '%s' "$prompt" | wc -c | tr -d ' ')
    printf 'readback %s sha256=%s bytes=%s profile=%s core=%s authority=%s origin=%s budget=%s leitsatz=%s\n' \
        "$path" "$hash" "$bytes" \
        "$(occurrences "$prompt" FIXTURE_PROFILE_MARKER)" \
        "$(occurrences "$prompt" FIXTURE_CORE_MARKER)" \
        "$(occurrences "$prompt" FIXTURE_AUTHORITY_MARKER)" \
        "$(occurrences "$prompt" FIXTURE_ORIGIN_MARKER)" \
        "$(occurrences "$prompt" FIXTURE_BUDGET_MARKER)" \
        "$(occurrences "$prompt" FIXTURE_LEITSATZ_MARKER)"
}

mkdir -p "$WORK/identity" "$WORK/owner" "$WORK/bin" "$WORK/leitsatz"

cat > "$WORK/identity/PROFILE.md" <<'EOF'
# Fixture Profile

FIXTURE_PROFILE_MARKER

<!-- identity-core-begin -->
FIXTURE_CORE_MARKER
<!-- identity-core-end -->
EOF
printf 'FIXTURE_CORE_MARKER\n' > "$WORK/identity/CORE.md"

cat > "$WORK/owner/AUTHORITY.md" <<'EOF'
<!-- resident-prompt-begin -->
FIXTURE_AUTHORITY_MARKER
<!-- resident-prompt-end -->
EOF
cat > "$WORK/owner/ORIGIN.md" <<'EOF'
<!-- resident-prompt-begin -->
FIXTURE_ORIGIN_MARKER
<!-- resident-prompt-end -->
EOF
cat > "$WORK/owner/BUDGET.md" <<'EOF'
<!-- resident-prompt-begin -->
FIXTURE_BUDGET_MARKER
<!-- resident-prompt-end -->
EOF
cat > "$WORK/LIVED-BRIEF.md" <<'EOF'
<!-- resident-prompt-begin -->
FIXTURE_LIVED_MARKER
<!-- resident-prompt-end -->
EOF

printf 'FIXTURE_LEITSATZ_MARKER\n' > "$WORK/leitsatz/AGENTS.md"
git -C "$WORK/leitsatz" init -q
git -C "$WORK/leitsatz" add AGENTS.md
git -C "$WORK/leitsatz" -c user.name=Fixture -c user.email=fixture@example.invalid commit -q -m fixture
LEITSATZ_COMMIT=$(git -C "$WORK/leitsatz" rev-parse HEAD)

cat > "$WORK/identity/IDENTITY.env" <<EOF
RESIDENT_PROFILE_SHA256=$(hash_file "$WORK/identity/PROFILE.md")
RESIDENT_PROFILE_BYTES=$(byte_count "$WORK/identity/PROFILE.md")
RESIDENT_CORE_SHA256=$(hash_file "$WORK/identity/CORE.md")
RESIDENT_CORE_BYTES=$(byte_count "$WORK/identity/CORE.md")
EOF
cat > "$WORK/owner/LEITSATZ.env" <<EOF
LEITSATZ_RELEASE_COMMIT=$LEITSATZ_COMMIT
LEITSATZ_GLOBAL_RELATIVE_PATH=AGENTS.md
LEITSATZ_GLOBAL_SHA256=$(hash_file "$WORK/leitsatz/AGENTS.md")
LEITSATZ_GLOBAL_BYTES=$(byte_count "$WORK/leitsatz/AGENTS.md")
EOF

cat > "$WORK/bin/skills" <<'EOF'
#!/usr/bin/env bash
[[ "${FIXTURE_EMPTY_SKILLS:-0}" == 1 ]] && exit 1
[[ "${1:-}" == prompt ]] && printf 'FIXTURE_SKILLS_MARKER\n'
EOF
chmod +x "$WORK/bin/skills"

export PATH="$WORK/bin:$REPO/bin:$PATH"
export IDENTITY_NAME=resident
export RESIDENT_IDENTITY_LABEL='the unnamed resident'
export RESIDENT_IDENTITY_PROFILE_FILE="$WORK/identity/PROFILE.md"
export RESIDENT_IDENTITY_CORE_FILE="$WORK/identity/CORE.md"
export RESIDENT_IDENTITY_MANIFEST_FILE="$WORK/identity/IDENTITY.env"
export OWNER_AUTHORITY_FILE="$WORK/owner/AUTHORITY.md"
export OWNER_ORIGIN_FILE="$WORK/owner/ORIGIN.md"
export OWNER_BUDGET_FILE="$WORK/owner/BUDGET.md"
export OWNER_LEITSATZ_PIN_FILE="$WORK/owner/LEITSATZ.env"
export LEITSATZ_MIRROR="$WORK/leitsatz"
export RESIDENT_LIVED_BRIEF_FILE="$WORK/LIVED-BRIEF.md"

# shellcheck disable=SC1091
source "$REPO/thinkers/_lib/common.sh"

if grep -Fq 'system_prompt=$(_build_system_prompt)' "$REPO/thinkers/responder/step"; then
    ok 'responder uses the shared resident prompt builder'
else
    bad 'responder uses the shared resident prompt builder'
fi
if grep -Fq 'system_prompt=$(_build_thinker_context)' "$REPO/thinkers/monolith/step"; then
    ok 'monolith carries only mutable thinker context into shellm'
else
    bad 'monolith carries only mutable thinker context into shellm'
fi

responder_prompt=$(_build_system_prompt)
monolith_context=$(_build_thinker_context)
direct_prompt=$("$REPO/bin/shellm" --print-system-prompt)
monolith_prompt=$(SHELLM_SYSTEM_PROMPT="$monolith_context" "$REPO/bin/shellm" --print-system-prompt)
nested_prompt=$(SHELLM_RUN_STEP_ID=fixture-parent "$REPO/bin/shellm" --print-system-prompt)

if empty_skills_responder=$(FIXTURE_EMPTY_SKILLS=1 _build_system_prompt); then
    assert_once "responder with no selected skills" "$empty_skills_responder" FIXTURE_PROFILE_MARKER
    assert_absent "responder with no selected skills" "$empty_skills_responder" FIXTURE_SKILLS_MARKER
else
    bad "responder with no selected skills still returns a usable prompt"
fi
if empty_skills_monolith=$(FIXTURE_EMPTY_SKILLS=1 _build_thinker_context); then
    assert_once "monolith with no selected skills" "$empty_skills_monolith" FIXTURE_LIVED_MARKER
    assert_absent "monolith with no selected skills" "$empty_skills_monolith" FIXTURE_SKILLS_MARKER
else
    bad "monolith with no selected skills still returns usable context"
fi

for path in responder monolith direct-shellm nested-shellm; do
    case "$path" in
        responder) prompt="$responder_prompt" ;;
        monolith) prompt="$monolith_prompt" ;;
        direct-shellm) prompt="$direct_prompt" ;;
        nested-shellm) prompt="$nested_prompt" ;;
    esac
    for marker in FIXTURE_PROFILE_MARKER FIXTURE_CORE_MARKER \
        FIXTURE_AUTHORITY_MARKER FIXTURE_ORIGIN_MARKER \
        FIXTURE_BUDGET_MARKER FIXTURE_LEITSATZ_MARKER; do
        assert_once "$path" "$prompt" "$marker"
    done
    report_prompt "$path" "$prompt"
done

for path in responder monolith; do
    case "$path" in
        responder) prompt="$responder_prompt" ;;
        monolith) prompt="$monolith_prompt" ;;
    esac
    assert_once "$path" "$prompt" FIXTURE_LIVED_MARKER
    assert_once "$path" "$prompt" FIXTURE_SKILLS_MARKER
done
for path in direct-shellm nested-shellm; do
    case "$path" in
        direct-shellm) prompt="$direct_prompt" ;;
        nested-shellm) prompt="$nested_prompt" ;;
    esac
    assert_absent "$path" "$prompt" FIXTURE_LIVED_MARKER
    assert_absent "$path" "$prompt" FIXTURE_SKILLS_MARKER
done

direct_envelope="${direct_prompt%%You are shellm,*}"
nested_envelope="${nested_prompt%%You are shellm,*}"
if [[ "$direct_envelope" == "$nested_envelope" ]]; then
    ok 'direct and nested shellm use the same immutable cognition envelope'
else
    bad 'direct and nested shellm use the same immutable cognition envelope'
fi

if RESIDENT_COGNITION_LIB="$WORK/missing-cognition-lib.sh" \
    "$REPO/bin/shellm" --print-system-prompt > "$WORK/missing.out" 2> "$WORK/missing.err"; then
    bad 'missing explicit cognition library fails closed' 'prompt unexpectedly rendered'
elif grep -Fq 'resident cognition library not found' "$WORK/missing.err"; then
    ok 'missing explicit cognition library fails closed'
else
    bad 'missing explicit cognition library fails closed' "$(tr '\n' ' ' < "$WORK/missing.err")"
fi

printf 'tamper\n' >> "$WORK/identity/CORE.md"
if resident_cognition_prompt > "$WORK/tampered.out" 2> "$WORK/tampered.err"; then
    bad 'Core hash mismatch fails closed' 'prompt unexpectedly rendered'
elif grep -Fq 'Core hash mismatch' "$WORK/tampered.err"; then
    ok 'Core hash mismatch fails closed'
else
    bad 'Core hash mismatch fails closed' "$(tr '\n' ' ' < "$WORK/tampered.err")"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
