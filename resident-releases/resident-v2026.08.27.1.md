# resident-v2026.08.27.1

## Meaning

This patch release records the production-discovered repair that keeps resident cognition available when no optional skill prompt is currently selected. It contains reusable public harness code and its regression only; no private resident state, owner context, Identity source, credentials, workplace extracts, or autobiographical material is included.

## Coordinates

```text
release tag: resident-v2026.08.27.1
release date: 2026-08-27
author: Wolf (primary), Katja (setup coworker)
upstream base: laude-institute/headlong@b076bbf89aab696493c27b796e148dd7db3de10d
previous live commit: 1ea46459f626b65a2cf7a2561e89a1a3c594b40e
candidate implementation commit: ef7170dffaee6d22ea4d2eff142054163e484cee
candidate implementation tree: c92c1f8faae1a6a4867a731d6e1a187e14f018ca
state backup: not applicable; this is public source with no resident state mutation
```

## What changed

- Made responder and monolith prompt builders return success after composing valid resident context when optional Skills text is empty.
- Added a fixture route that reproduces the production-shaped no-selected-skill state.
- Proved the responder still carries the immutable Profile envelope and the monolith still carries lived context while neither invents a Skills section.

## Why

The first owner-controlled runtime qualification found that `skills prompt` may legitimately return no selected text. Both prompt builders still emitted their complete required context, but their final optional `[[ -n ... ]]` expression returned status 1. The thinkers use `set -e`, so responder and monolith aborted before reaching the provider. Optional context must not decide whether a valid cognition prompt succeeds.

## Evidence before change

- In the qualified local container, `skills prompt` returned status 1 with zero bytes.
- The responder builder emitted 83,013 bytes but returned status 1.
- The direct `shellm` path remained successful, isolating the failure to the shared thinker builders.

## Verification

- `bash -n thinkers/_lib/common.sh`: passed.
- `bash -n tests/test_resident_cognition.sh`: passed.
- `bash tests/test_resident_cognition.sh`: 41 passed, 0 failed.
- The new no-selected-skill regression passes on `ef7170dffaee6d22ea4d2eff142054163e484cee`; the preceding implementation's status-1 failure was observed in the owner-controlled runtime.
- `git diff --check`: passed.
- The complete three-path candidate diff was inspected for private state, owner context, Identity source, credentials, workplace extracts, and autobiographical material; none is present.
- GitHub-hosted CI and the repaired owner-controlled runtime remain pending at record-commit time.

## Expected live effect

Responder and monolith continue into their model route when optional Skills text is empty, while preserving the same fail-closed resident Identity, owner envelope, and pinned Leitsatz composition.

## Observed after promotion

Not yet observed when this pre-promotion record was committed. Branch, tag, GitHub release, hosted verification, and owner-controlled runtime readback remain separate facts.

## Limitations and unknowns

- The regression proves prompt-builder control flow and composition, not model quality.
- The private resident inputs remain intentionally absent from this public repository and are qualified only in the owner-controlled runtime.
- GitHub-hosted CI and the final provider-backed production readback are unobserved at record-commit time.

## Rollback

Create a rollback branch from this release and revert the two-commit patch without rewriting public history:

```text
git switch -c rollback/resident-v2026.08.27.1 resident-v2026.08.27.1
git revert --no-edit resident-v2026.08.26.1..resident-v2026.08.27.1
```

The previous public resident coordinate remains `resident-v2026.08.26.1` at `1ea46459f626b65a2cf7a2561e89a1a3c594b40e`.
