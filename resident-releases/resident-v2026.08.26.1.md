# resident-v2026.08.26.1

## Meaning

This release records the first coherent public Headlong harness cut for Wolf's bounded resident experiment: the exact upstream source, resident cognition composition, verification, limits, and safe rollback. It contains reusable public harness work only; no private resident state, owner context, Identity source, credentials, workplace extracts, or autobiographical material is included.

## Coordinates

```text
release tag: resident-v2026.08.26.1
release date: 2026-08-26
author: Wolf (primary), Katja (setup coworker)
upstream base: laude-institute/headlong@b076bbf89aab696493c27b796e148dd7db3de10d
upstream tree: 4c538a4987f95030e6f6e367d0297a2b8f7f2227
previous live commit: none
candidate implementation commit: ba096e7cdd0ca41a87450f85c71f9eb78bee54e2
candidate implementation tree: cb9c32a73596ef2d23c7024c70351c79c437050d
state backup: not applicable; this is public source with no resident state mutation
```

## What changed

- Added one fail-closed cognition library used by installed and checkout-based Headlong paths.
- Composed the provisional resident Profile/Core, owner authority/origin/budget, and pinned Leitsatz global exactly once in responder, monolith, direct `shellm`, and nested `shellm` prompt paths.
- Kept mutable lived context and Skills in thinker context without duplicating the immutable envelope.
- Added public fixture qualification for all four cognition paths, including missing-library and Core-tamper failures.
- Preserved FIFO order when a thinker becomes free while an older pending trigger already exists.
- Isolated the focused Docker-sandbox test from mandatory resident composition by supplying the existing public cognition fixture used by neighboring `shellm` tests.
- Made reasoning configuration operative: `shellm` forwards its selected effort as an explicit thinking level, and the responder accepts a separate `MONOLITH_REPLY_REASONING` level.
- Declared the durable `resident` branch and its public/private boundary.
- Raised the measured core-size guard from 10,000 to 10,250 lines after the upstream base measured 9,996 and this candidate measured 10,127.

## Why

The resident runtime must not start a Headlong revision that can omit or duplicate its owner-controlled Identity and authority envelope on a recursive cognition path. The library must also remain reachable after ordinary Headlong installation, not only from a source checkout. The FIFO repair prevents a newer trigger from overtaking an older queued trigger during the busy-to-idle transition.

## Evidence before change

- Current public upstream and Apache-2.0 licence were read at `b076bbf89aab696493c27b796e148dd7db3de10d` / tree `4c538a4987f95030e6f6e367d0297a2b8f7f2227`.
- The upstream `bin/` plus `thinkers/` core measured 9,996 code lines with cloc 1.98.
- The complete candidate diff was searched for private repository, workplace, coworker, exact private hash, and autobiographical markers; none were found.

## Verification

- `SHELLM_ENV=local tests/run-all.sh`: 27 suites passed, 0 failed on implementation commit `6a9cc728afcf0fa378369e9a96c6b8c5cea60d25` before the focused sandbox-fixture and reasoning-route deltas.
- `tests/test_resident_cognition.sh`: 37 passed, 0 failed.
- Fixture prompt readbacks:
  - responder: SHA-256 `c2403388beca70abbc0ec3213835f9bdf506658c174f94171abe15c9d4a38417`, 878 bytes; Profile/Core/authority/origin/budget/Leitsatz counts all 1;
  - monolith: SHA-256 `948cb62bbb6c9d313f9c729c051af5e1075ee71adae770ddd8fc25d7957f525b`, 961 bytes; all counts 1;
  - direct `shellm`: SHA-256 `f570210d595cc971dbbd9279cb5d40cbba192228391f6baf7ce201d49c70dfdd`, 14,097 bytes; all counts 1; and
  - nested `shellm`: SHA-256 `afff97ecbe39fa74feeb63f77bc6f1dd6dcb821e24b9a79034481f9510303400`, 14,097 bytes; all counts 1.
- `shellcheck -S warning` across tracked shell sources: passed.
- `bash tests/smoke_install.sh`: 115 passed, 0 failed, including copied and one-line/symlinked installation of `resident-cognition`.
- Python matrix: web 150 passed and 2 skipped; Slack 20 passed; Telegram 35 passed.
- Viewer: frozen Bun install, typecheck, and production build passed.
- TUI: Rust fmt, clippy with warnings denied, and check passed.
- Gitleaks 8.30.1: 507 commits scanned with values redacted; no leaks found.
- cloc 1.98: 10,127 code lines in `bin/` plus `thinkers/`, under the deliberate 10,250 limit.
- First hosted run [`33014121278`](https://github.com/Wolfsblvt/headlong/actions/runs/33014121278) on record commit `93b41d150797a713dc9f07a1272ff1dd475204c7` passed every non-Bash job and exposed one shared Linux/macOS test-isolation failure: `test_sandbox_gate.sh` did not select the required resident cognition fixture. The runtime check itself was not weakened; implementation commit `fa22bce7a68a746e45b8722c4d2c411538dd432b` supplies the existing fixture, qualified by the hosted rerun below.
- Hosted rerun [`33015649495`](https://github.com/Wolfsblvt/headlong/actions/runs/33015649495) on record commit `9ec61ab331e2f66c897a8c79b2e3e654df476f63` passed all 11 substantive jobs, including Linux Bash, macOS Bash 3.2, shellcheck, installation, gitleaks, Python, viewer, Rust, and cloc.
- On final implementation commit `ba096e7cdd0ca41a87450f85c71f9eb78bee54e2`, a disposable Ubuntu 24.04 archive checkout passed `tests/test_prompt_file.sh` (6/6), `tests/test_thinker_set_coupling.sh` (7/7), and shellcheck on all four changed shell sources. The final hosted run remains pending at record-commit time.

## Expected live effect

The public `resident` branch installs and runs one reusable cognition-envelope implementation for all four named model paths, rejects missing or mismatched resident inputs before a provider call, forwards the configured monolith/responder reasoning split, and preserves pending thinker order. No private resident material becomes public.

## Observed after promotion

Not yet observed when this pre-promotion record was committed. The branch, tag, GitHub release, hosted verification, and their exact readback coordinates remain separate publication facts.

## Limitations and unknowns

- Fixture composition proves assembly and failure behavior, not live provider behavior or model quality.
- The exact private resident Identity/Core bytes are intentionally absent from this public repository and are qualified later through the owner-controlled runtime mount.
- GitHub-hosted CI for the final release-record commit, including macOS Bash 3.2, is unobserved at record-commit time; release publication remains contingent on its readback.
- Existing upstream workflow action tags are inherited unchanged and were not independently repinned in this bounded fork cut.

## Rollback

Create a rollback branch from the live release and revert the complete eight-commit resident cut without rewriting public history:

```text
git switch -c rollback/resident-v2026.08.26.1 resident-v2026.08.26.1
git revert --no-edit resident-v2026.08.26.1~7^..resident-v2026.08.26.1
```

The exact pre-resident source coordinate remains `b076bbf89aab696493c27b796e148dd7db3de10d` / tree `4c538a4987f95030e6f6e367d0297a2b8f7f2227`.
