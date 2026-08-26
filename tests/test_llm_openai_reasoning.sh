#!/usr/bin/env bash
# test_llm_openai_reasoning.sh — OpenAI Chat Completions gets its own reasoning wire shape

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

pass=0
fail=0
ok()  { pass=$((pass+1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL %s%s\n' "$1" "${2:+ — $2}"; }

mkdir -p "$WORK/bin" "$WORK/home"
cat > "$WORK/bin/curl" <<'STUB'
#!/usr/bin/env bash
for arg in "$@"; do
    case "$arg" in
        @*) cat "${arg#@}" > "$REQUEST_BODY" ;;
    esac
done
printf 'data: {"choices":[{"delta":{"content":"ok"}}]}\n\n'
printf 'data: [DONE]\n'
STUB
chmod +x "$WORK/bin/curl"

export PATH="$WORK/bin:$PATH"
export HEADLONG_HOME="$WORK/home"
export OPENAI_API_KEY="test-key"
export LLM_RETRIES=0
export REQUEST_BODY="$WORK/request.json"

LLM="$REPO/bin/llm"
out=$(LLM_PROVIDER=openai "$LLM" -m gpt-5.6-luna --thinking high "say ok" 2>"$WORK/stderr")
rc=$?

if [[ "$rc" -eq 0 && "$out" == "ok" ]]; then
    ok "OpenAI reasoning request completes through the Chat Completions stub"
else
    bad "OpenAI reasoning request completes through the Chat Completions stub" "rc=$rc: $(head -1 "$WORK/stderr")"
fi

if jq -e '.reasoning_effort == "high" and (has("reasoning") | not)' "$REQUEST_BODY" >/dev/null; then
    ok "OpenAI payload uses top-level reasoning_effort without a Responses reasoning object"
else
    bad "OpenAI payload uses top-level reasoning_effort without a Responses reasoning object"
fi

if jq -e '.max_completion_tokens == 128000 and (has("max_tokens") | not)' "$REQUEST_BODY" >/dev/null; then
    ok "GPT-5.6 keeps the Chat Completions token field"
else
    bad "GPT-5.6 keeps the Chat Completions token field"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
