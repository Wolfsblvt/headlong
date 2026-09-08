# Headlong

[![CI](https://github.com/Wolfsblvt/headlong/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Wolfsblvt/headlong/actions/workflows/ci.yml)
[![Status: alpha research](https://img.shields.io/badge/status-alpha%20research-orange)](#safety-and-control)
[![Core: under 10K lines of Bash](https://img.shields.io/badge/core-%3C10K%20lines%20of%20Bash-4EAA25?logo=gnubash&logoColor=white)](.github/workflows/ci.yml)

**A small, inspectable Bash harness for agents that keep thinking between messages.**

Headlong is an open-source agent microharness built around **persistent agency**. A
named agent has one continuous trajectory rather than a pile of request-response
sessions. Messages become observations in that stream; a dispatcher keeps the mind
moving; and the agent decides what to think about, do, or answer next.

At the center is `shellm`, a Bash implementation of [recursive language
models](https://alexzhang13.github.io/blog/2025/rlm/). `shellm` writes shell commands,
runs them, and reads their output. Headlong adds the durable system around that
primitive: identity, memory, thinkers, context, trajectory, chat bridges, and a
dashboard. It is deliberately of Bash, by Bash, for Bash: shells all the way down.

> [!NOTE]
> This is the `Wolfsblvt/headlong` public, upstream-derived fork of [Laude Institute's
> Headlong](https://github.com/laude-institute/headlong). The canonical project and
> current upstream development live there. This fork also preserves source used by a
> separate persistent-resident experiment; that experiment is stopped and parked, not
> a running service or an implied restart.

> [!CAUTION]
> Headlong is alpha research software. Its agents execute real shell commands and may
> call an LLM around the clock. Use Docker, a dedicated spend-capped key, and no
> secrets you are unwilling to expose. A shared agent has one shared mind, so
> conversations are not isolated per user.

**[Visit Headlong](https://headlong.ai)** · **[Quick start](#quick-start)** · [Read the philosophy](philosophy.md) · [Browse current upstream](https://github.com/laude-institute/headlong)

```text
██  ██ █████  ████  █████  ██     ████  ██  ██  ████               ██
██  ██ ██    ██  ██ ██  ██ ██    ██  ██ ███ ██ ██           ██   ██
██▀▀██ ████  ██████ ██  ██ ██    ██  ██ ██▀███ ██ ███     ██   ██
██  ██ ██    ██  ██ ██  ██ ██    ██  ██ ██ ▀██ ██  ██   ██   ██
██  ██ █████ ██  ██ █████  █████  ████  ██  ██  █████      ██
```

## Quick start

By default, the hosted installer clones the canonical upstream repository. Before
running it, you need:

- Bash 3.2 or newer, Git, curl, and jq;
- an Anthropic, OpenAI, Gemini, or OpenRouter API key;
- Docker, strongly recommended so generated shell commands do not run directly on your
  machine.

The optional dashboard also needs [uv](https://docs.astral.sh/uv/) and Bun or Node; the
installer can offer to fetch them.

```bash
curl -fsSL https://headlong.ai/install.sh | bash
```

The installer interviews you, creates the first identity, starts its mind, and opens the
dashboard. The identity name becomes a command; the default examples use `ada`.

| Command | What it does |
| --- | --- |
| `ada hello` | Send one message and wait for the reply |
| `ada` | Open an interactive chat |
| `ada status` | Show the mind and dashboard state |
| `ada stop` / `ada start` | Pause or resume the mind |
| `ada dash` | Print or open the dashboard URL |
| `ada bugreport` | Bundle useful diagnostics with credential-looking values scrubbed |

A successful install writes `status.json` under `~/.headlong/`. `ada status` should
report the mind and dashboard state, and `ada dash` should reach the local dashboard.
Replies commonly take 15 to 45 seconds while the thinker wakes.

### Run this fork's checkout

Use the checked-in source here instead of canonical upstream when you specifically need
this fork:

```bash
git clone https://github.com/Wolfsblvt/headlong.git
cd headlong
./install.sh --init
```

The full installation guide covers Docker, non-interactive installs, updates, state
paths, and uninstalling: [docs/install.md](docs/install.md).

## How the mind moves

```text
human messages, chat bridges, or idle time
                    │
                    ▼
        one append-only trajectory
                    │
          context projects history
                    │
                    ▼
        thinkers choose the next step
                    │
                    ▼
       shellm writes and runs Bash
                    │
                    └──── thoughts, actions, and replies return to the trajectory
```

The design has a few deliberately unusual properties:

- **Persistent agency.** The mind can continue between external interactions instead of
  waking only for a request or scheduled checklist.
- **One shared experience.** CLI, web, Slack, and Telegram conversations enter the same
  trajectory rather than separate per-user sessions.
- **Inspectable state.** Identity, memories, skills, and trajectories are ordinary
  files, mostly Markdown and append-only JSONL.
- **History without destructive compaction.** Context is projected from the trajectory
  at tiered resolution; older raw steps remain available.
- **Recursive delegation.** A `shellm` run can call `shellm` again, and subagents can
  see the trajectory that led to their creation.
- **Fork, test, merge.** An agent can change its own source or fork its trajectory, keep
  successful experiments, and discard the rest through ordinary version control.
- **Unix composition.** The model works through Bash, pipes, files, environment
  variables, and tools such as `curl` and `jq` instead of a bespoke function catalogue.
- **A core small enough to read.** CI keeps the executables in `bin/` plus the thought
  processes in `thinkers/` below 10,000 code lines.

The longer design argument lives in [philosophy.md](philosophy.md).

## The system at a glance

| Layer | Main pieces | Responsibility |
| --- | --- | --- |
| Thinking | `thinkers`, `shellm`, `llm` | Select the next thought, call a model, and turn model-written Bash into observable work |
| History and context | `traj`, `context`, `recap` | Keep the append-only trajectory, project context, and summarize runs |
| Identity and learning | `identity`, `mem`, `skills`, `focus` | Create identities, preserve memories, reuse procedures, and carry goals |
| Interaction | `persona`, `chat`, `headlong-web`, Slack and Telegram bridges | Talk to one identity from the CLI, browser, or shared channels |
| Execution safety | `shellm-docker`, `shellm-docker-broker`, `headlong-killall` | Sandbox generated commands, broker constrained Docker access, and stop runaway processes |

The detailed command inventory and implementation notes remain in the maintained
references below.

## Safety and control

With a working Docker daemon, the installer offers either a fully containerized agent or
a host installation whose generated commands still run in Docker. Running generated
commands directly on the host exists only behind an explicit confirmation and is not
recommended.

The thinking loop can incur continuing model costs. Use a dedicated, spend-capped API
key and inspect the provider account separately; actual cost depends on model choice and
loop cadence. Keep sensitive credentials out of the agent's environment and workspaces
unless they are genuinely required.

A shared Headlong identity has no private per-user conversation walls. Everyone talking
to that identity contributes to the same experience and should assume the agent may
connect or repeat what it has observed.

```bash
curl -fsSL https://headlong.ai/status.sh | bash    # inspect an installation
ada stop                                           # pause one identity
ada start                                          # resume one identity
headlong-killall                                    # stop every Headlong process
curl -fsSL https://headlong.ai/uninstall.sh | bash # remove the installation
```

See [stopping and uninstalling](docs/install.md#stopping-and-uninstalling) before
deleting state you may want to keep.

## About this fork

`Wolfsblvt/headlong` keeps Headlong's product identity, upstream history, and
Apache-licensed source intact. It is not the canonical release line and may lag [Laude
Institute's repository](https://github.com/laude-institute/headlong); use upstream when
you need the latest Headlong development.

The default `main` branch is the ordinary upstream-derived fork line. The public
[`resident` branch](https://github.com/Wolfsblvt/headlong/tree/resident) preserves the
Headlong changes used by the fork's first persistent-resident experiment.

That run was deliberately stopped and parked on September 1, 2026. Its runtime state and
operating decisions live outside this public source repository. The preserved branch is
historical evidence and recoverable source, not a currently running resident or an
instruction to resume it.

## Documentation

| Destination | Go there for |
| --- | --- |
| [Installation guide](docs/install.md) | Every install mode, non-interactive setup, updates, state, diagnostics, and removal |
| [Operating guide](AGENTS.md) | Health checks, paths, automation, naming, and sharp edges for a running identity |
| [`shellm` reference](docs/shellm.md) | The recursive loop, context passing, providers, Docker behavior, and options |
| [Philosophy](philosophy.md) | Why text streams, Unix composition, and inspectable state shape the harness |
| [Web](web/README.md), [Slack](slack/README.md), and [Telegram](telegram/README.md) | Dashboard and bridge-specific setup |
| [Deployment](deploy/README.md) | Dedicated-box and systemd operation |
| [CI workflow](.github/workflows/ci.yml) | The exact Bash, Python, web, Rust, macOS, install, secret-scan, and size gates |
| [Canonical upstream](https://github.com/laude-institute/headlong) | Current Headlong source, issues, and ongoing development |
| [Launch post](https://www.laude.org/updates/headlong-a-microharness-for-persistent-agents) | The original public introduction to Headlong |

## Provenance

Headlong is developed by the [Laude Institute](https://github.com/laude-institute). The
recursive language-model work in `shellm` draws from the earlier [Recursive
LLM](https://github.com/andyk/recursive_llm) experiment and Alex Zhang's [Recursive
Language Models](https://alexzhang13.github.io/blog/2025/rlm/); persistent agency and
the name also draw from the earlier [Headlong research
project](https://github.com/andyk/headlong).

## License

Licensed under the [Apache License 2.0](LICENSE), which permits use, modification, and
distribution subject to its notice and patent terms; copyright © 2026 Laude Institute.
