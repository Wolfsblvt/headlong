# resident-v2026.08.27.2

## Meaning

This patch release records two failures found by the first owner-controlled runtime qualification: the direct OpenAI Chat Completions route used a Responses-only reasoning object, and Headlong recap used a jq variable name rejected by the resident image's jq 1.6. It contains reusable public harness code and regression coverage only; no private resident state, owner context, Identity source, credentials, workplace extracts, or autobiographical material is included.

## Coordinates

```text
release tag: resident-v2026.08.27.2
release date: 2026-08-27
author: Wolf (primary), Katja (setup coworker)
upstream base: laude-institute/headlong@b076bbf89aab696493c27b796e148dd7db3de10d
previous live commit: a56e44e2b39d678363b2e35f73111f7467c93c32
candidate implementation commit: 6ac938e5c2f4c7f48fd2d0a35998be82b41fbb29
candidate implementation tree: 5d63003e37f217017da8a0d55786785d6f75875a
state backup: not applicable; this is public source with no resident state mutation
```

## What changed

- Send OpenAI Chat Completions reasoning effort through its supported top-level `reasoning_effort` field instead of the Responses API's nested `reasoning` object.
- Preserve the existing nested reasoning shape for non-OpenAI compatible gateways rather than silently changing their contract.
- Add an offline request-payload regression for `gpt-5.6-luna`, including the existing `max_completion_tokens` boundary.
- Rename jq input variables while preserving emitted recap JSON fields so the maintained runtime's jq 1.6 can generate episodes and rollups.

## Why

The first provider-backed monolith wake reached OpenAI but failed before generation with `Unknown parameter: 'reasoning'`. Current official OpenAI Chat Completions documentation defines `reasoning_effort` as the request field, while the GPT-5.6 Luna model documentation confirms the configured `medium` and `high` effort levels are supported.

The same runtime image then exposed that jq 1.6 parses `$end` as a reserved keyword. Headlong's recap tests passed on the hosted runner's newer jq but failed in the exact Debian image intended to operate the resident. The serialized keys remain unchanged; only internal jq variable names move.

## Verification

- `bash -n bin/llm`, `bash -n bin/recap`, and `bash -n tests/test_llm_openai_reasoning.sh`: passed in the resident Linux image.
- `bash tests/test_llm_openai_reasoning.sh`: 3 passed, 0 failed.
- `SHELLM_ENV=local tests/run-all.sh`: 28 suites passed, 0 failed against exact implementation commit `6ac938e5c2f4c7f48fd2d0a35998be82b41fbb29` in a writable disposable copy inside the resident image.
- `git diff --check`: passed.
- The complete candidate diff was inspected for private state, owner context, Identity source, credentials, workplace extracts, and autobiographical material; none is present.
- Protocol references: [OpenAI Chat Completions API](https://platform.openai.com/docs/api-reference/chat/create) and [GPT-5.6 Luna](https://developers.openai.com/api/docs/models/gpt-5.6-luna).

## Expected live effect

Direct OpenAI cognition reaches GPT-5.6 Luna with the selected effort instead of failing schema validation, and recap remains usable in the actual resident image without changing its persisted JSON contract.

## Observed after promotion

Not yet observed when this pre-promotion record was committed. Branch, tag, GitHub release, hosted verification, and owner-controlled provider readback remain separate facts.

## Limitations and unknowns

- The offline payload regression proves the request schema, not a successful provider response or model quality.
- The private resident inputs remain intentionally absent from this public repository and are qualified only in the owner-controlled runtime.
- The failed first provider attempts remain preserved in the private trajectory as setup evidence.
- Hosted CI and the final provider-backed production readback are unobserved at record-commit time.

## Rollback

Create a rollback branch from this release and revert the two-commit patch without rewriting public history:

```text
git switch -c rollback/resident-v2026.08.27.2 resident-v2026.08.27.2
git revert --no-edit resident-v2026.08.27.1..resident-v2026.08.27.2
```

The previous public resident coordinate remains `resident-v2026.08.27.1` at `a56e44e2b39d678363b2e35f73111f7467c93c32`.
