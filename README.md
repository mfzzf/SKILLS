# SKILLS

A curated index of Claude / Cursor / Codex compatible skills I maintain. Each entry is a standalone repo and is wired in here as a git submodule, so a single `git clone --recursive` pulls every skill at the pinned commit.

> Maintaining this catalog? See **[MAINTENANCE.md](./MAINTENANCE.md)** and run `make help`.

---

## Install on a new machine

End-to-end: clone the catalog, then symlink every skill into both Claude Code and Codex so updates are realtime (no copy step).

### 0. Prereqs

- `git` ≥ 2.30
- `make`
- `gh` CLI (optional, only needed if you'll publish from this machine)
- SSH key registered with GitHub *or* HTTPS auth working — pick one and stay consistent

Sanity check:

```bash
git --version && make --version | head -1 && ssh -T git@github.com 2>&1 | head -1
```

### 1. Pick a home and clone

Put the catalog somewhere persistent (NOT inside a project you might delete). Example:

```bash
mkdir -p ~/code && cd ~/code
git clone --recursive git@github.com:mfzzf/SKILLS.git
cd SKILLS
```

If you forgot `--recursive`, run `make init` — it's idempotent.

If you prefer HTTPS:

```bash
git clone --recursive https://github.com/mfzzf/SKILLS.git
```

### 2. Verify the catalog landed cleanly

```bash
make status        # each skill should show "behind: 0"
make check         # every submodule should also appear in this README
```

### 3. Wire it into Claude Code and Codex

```bash
make link
```

This creates symlinks:

- `~/.claude/skills/<name>` → catalog
- `~/.codex/skills/<name>`  → catalog
- Bundle skills (`anthropics-skills/skills/*`) are auto-expanded so each shows up as its own top-level entry (`frontend-design`, `skill-creator`, `claude-api`, …).

Conflict handling:

- An existing **symlink** with the same name is updated in place.
- An existing **real directory** is left alone and printed as a warning — move it aside (`mv foo foo.bak`) if you want the catalog version to take over.

Verify:

```bash
make link-status
```

Every catalog entry should appear as `↪ <name> -> ...  [catalog]` under both roots.

### 4. Restart your clients

- **Claude Code**: restart the CLI / VS Code extension so it rescans `~/.claude/skills/`.
- **Codex**: restart the Codex CLI / session.

Then ask the agent something that should trigger one of the skills (e.g. *"scaffold a Next.js app"* → should pick up `frontend-build-2026`).

### 5. Stay current — daily ops

```bash
cd ~/code/SKILLS

make sync          # pull catalog + move submodules to pinned commits
make bump-all      # advance every submodule to its upstream HEAD (then push)
make push          # publish bumped pins
make link          # safe to rerun; picks up newly added bundle members
```

Optional shell alias:

```bash
echo "alias skills-up='cd ~/code/SKILLS && make sync && make bump-all && make push && make link'" >> ~/.zshrc
source ~/.zshrc
```

### 6. Uninstall

```bash
cd ~/code/SKILLS
make unlink        # removes only the symlinks this catalog created
# then optionally:
cd .. && rm -rf SKILLS
```

`make unlink` is conservative: it ignores external symlinks (e.g. `~/.agents/skills/...`) and real directories. Nothing outside the catalog is touched.

---

## Quick clone (if you already know the drill)

```bash
git clone --recursive git@github.com:mfzzf/SKILLS.git
cd SKILLS && make link
```

---

## Catalog

### [go-backend-ddd](./go-backend-ddd) &nbsp;·&nbsp; [source](https://github.com/mfzzf/go-ddd-skills)

Build or refactor a Go backend service using **DDD + CQRS + Hexagonal** layout, modeled after the `gorder-v2` reference project.

**Triggers**: "build a Go backend", "new Go microservice", "DDD in Go", "CQRS handler", "ports and adapters", "add a bounded context", "command handler decorator", "go repository transaction", "重构 Go 项目", "搭一个 Go 微服务".

**What's inside**: bounded-context scaffolding, generics-based logging/metrics decorators, ports-and-adapters wiring, command/query handler templates, repository + transaction patterns.

---

### [frontend-build-2026](./frontend-build-2026) &nbsp;·&nbsp; [source](https://github.com/mfzzf/frontend-build-2026)

Production-grade **Next.js 16** frontend build playbook pinned to the May 2026 stack: React 19.2, Tailwind v4.3, shadcn/ui v4, Vercel AI SDK 5, Streamdown, AI Elements, AG-UI, Mastra, Biome v2.4, Vitest 4, Playwright, Storybook 9.

**Triggers**: "scaffold a Next.js app", "AI chat UI", "tool-call rendering", "streaming markdown", "HITL", "shadcn", "Tailwind v4", "Server Components", "Server Actions", "AGENTS.md", or any frontend stack/version question.

**What's inside**: pinned version table, decision tree for rendering / chat / styling / forms / state, file-layout conventions, ten hard rules (the AGENTS.md contract), six copy-paste recipes (shadcn CLI, streaming chat, Server Action + Zod, `"use cache"`, Tailwind v4 `@theme`, Vitest component test), anti-pattern blacklist; reference docs for stack rationale and agent protocols (AG-UI / MCP / A2A / Mastra / CopilotKit).

---

### [modelverse-image](./modelverse-image) &nbsp;·&nbsp; [source](https://github.com/mfzzf/modelverse-image)

Generate or edit raster images through the **ModelVerse OpenAI-compatible `gpt-image-2` API**. Use when an agent (Codex / Claude) needs to create images from prompts, edit an existing image with an optional mask, save returned base64 data to local files, or surface curl/Python examples.

**Triggers**: "generate an image", "image edit with mask", "gpt-image-2", "ModelVerse image API", "save b64_json to file".

**What's inside**: `scripts/modelverse_image.py` with `generate` and `edit` subcommands, an OpenAI-compatible agent spec, and an `references/api.md` covering auth, endpoints, and response shape.

---

### [ucloud-api](./ucloud-api) &nbsp;·&nbsp; [source](https://github.com/mfzzf/ucloud-skills)

Call any **UCloud OpenAPI** (UAI / ModelVerse / UMInfer / UHost / VPC / …) with correct SHA1 signing. Bundles a Python helper that handles param sorting, encoding edge cases (bool, float), VPC vs public endpoints, env-var creds, dry-run, and a `--selftest` against UCloud's published verification sample.

**Triggers**: any UCloud Action name (`List*`, `Describe*`, `Get*`, `Create*`, `Delete*`, `Modify*` against `api.ucloud.cn`), "UCloud signature", "UCloud PublicKey PrivateKey", "ListUMInferAPIKey", "GetProjectList", "调用 UCloud 接口", "UCloud 签名".

**What's inside**: `scripts/ucloud_call.py` (CLI + library) with selftest, `references/signing.md` (canonical algorithm walkthrough with verification sample), and a growing `references/apis/` recipe book (`list-um-infer-apikey.md`, `get-project-list.md`, …). Add a recipe whenever you call a new Action.

---

### [modelverse-api](./modelverse-api) &nbsp;·&nbsp; [source](https://github.com/mfzzf/modelverse-skills)

Data-plane caller for **UCloud ModelVerse / UModelVerse** — invoke any hosted model (DeepSeek, Qwen, GPT-5, gpt-image-2, Sora-2, Veo-3.1, Kling, Wan-2.x, MiniMax-Hailuo, Suno, Gemini / Claude compatible, embeddings, rerank, …) over OpenAI-compatible endpoints (`api.modelverse.cn` / `api.umodelverse.ai`). Pairs with `ucloud-api` (the control plane that mints API keys).

**Triggers**: "ModelVerse", "UModelVerse", `MODELVERSE_API_KEY`, "OpenAI compatible UCloud", any ModelVerse-hosted model name, "调用 ModelVerse", "UCloud 模型市场".

**What's inside**: `scripts/modelverse_call.py` (subcommands `models` / `chat` / `image` / `raw`, streaming-aware), full upstream `api_doc/` mirrored under `references/` (per-model recipes for ~80 text / image / video / audio models, plus error codes and quick-start), and `scripts/update-docs.sh` to refresh `references/` from the upstream internal GitLab.

---

### [openai-docs](./openai-docs) &nbsp;·&nbsp; [source](https://github.com/mfzzf/openai-docs)

Verbatim offline mirror of the **OpenAI API documentation** (`developers.openai.com/api/docs/llms-full.txt`, ~1.9 MB). Use as authoritative reference whenever a question hinges on OpenAI API behavior — endpoints, models, parameters, error codes, Responses/Realtime/Assistants/Batch/Files specs, function calling shapes, streaming SSE, etc.

**Triggers**: "OpenAI docs", "OpenAI SDK", `gpt-4.1`/`gpt-4o`/`gpt-5`, Responses API, Assistants, Realtime, Whisper, "OpenAI 文档".

---

### [gemini-docs](./gemini-docs) &nbsp;·&nbsp; [source](https://github.com/mfzzf/gemini-docs)

Verbatim offline mirror of **Google Gemini API documentation** (`ai.google.dev/api/llms.txt` index + ~15 child `.md.txt` files). Use for Gemini endpoint shapes, model ids, multimodal inputs, file/upload API, batch jobs, embeddings, code execution tool, grounding, safety settings.

**Triggers**: "Gemini docs", `gemini-2.5-pro`/`gemini-2.5-flash`/`gemini-3-pro`, `google-genai` SDK, Vertex AI, "Gemini 文档".

---

### [anthropic-docs](./anthropic-docs) &nbsp;·&nbsp; [source](https://github.com/mfzzf/anthropic-docs)

Verbatim offline mirror of **Anthropic / Claude API documentation** (`platform.claude.com/llms-full.txt`, ~80 MB raw → split into ~1300 per-page markdown files). Use for Claude API behavior — prompt caching, extended thinking, vision/PDF/files API, batches, tool use, computer use, MCP, Claude Code features, error codes, SDK usage.

**Triggers**: "Anthropic docs", "Claude API", `claude-opus-4-7`/`claude-sonnet-4-6`/`claude-haiku-4-5`, "Anthropic SDK", prompt caching, extended thinking, "Anthropic 文档".

> Note this skill is **separate** from [`anthropics-skills`](./anthropics-skills) below — that one is the official skill collection (frontend-design / skill-creator / mcp-builder / …); this one is the docs mirror.

---

### Upstream — [anthropics/skills](./anthropics-skills) &nbsp;·&nbsp; [source](https://github.com/anthropics/skills)

Anthropic's official skill collection, vendored as a submodule so we always have the canonical references at hand. The two we lean on most:

#### [→ frontend-design](./anthropics-skills/skills/frontend-design)

Create distinctive, production-grade frontend interfaces with high design quality. Generates creative, polished code that avoids generic AI aesthetics.

**Triggers**: "build a web component / page / app", "design a landing page", "make this look better", "non-generic UI".

#### [→ skill-creator](./anthropics-skills/skills/skill-creator)

The meta-skill for authoring, improving, and evaluating other skills — drafts SKILL.md, runs evals (with/without baselines), launches an eval viewer, iterates with quantitative + qualitative feedback, then optimizes the description for triggering accuracy.

**Triggers**: "create a new skill", "improve my skill", "run evals on a skill", "optimize a skill description".

> Also available inside `anthropics-skills/skills/`: `claude-api`, `mcp-builder`, `webapp-testing`, `pdf`, `docx`, `xlsx`, `pptx`, `canvas-design`, `theme-factory`, and more — browse the directory and pull what you need.

---

### Upstream — [superpowers](./superpowers) &nbsp;·&nbsp; [source](https://github.com/obra/superpowers)

Jesse Vincent's **Superpowers** — an opinionated software-development methodology delivered as a bundle of auto-triggering skills. Pushes the agent to spec → plan → subagent-driven TDD instead of jumping straight to code. Vendored as a submodule so we always have the canonical copies.

**Triggers**: "brainstorm a feature", "write a plan", "TDD this", "systematic debugging", "code review", "use a worktree", "dispatch subagents", "verify before done", "finish a branch", "create a skill".

**What's inside** (`superpowers/skills/`): `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch`, `writing-skills`, `using-superpowers`. Also ships hooks, install scripts for multiple harnesses (Claude Code / Codex / Gemini / OpenCode / Cursor / Copilot CLI), and `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` driver prompts.

---

## Layout

```
SKILLS/
├── README.md                # this file
├── MAINTENANCE.md           # how to add / sync / bump
├── Makefile                 # `make help`
├── .gitmodules              # submodule pins
├── go-backend-ddd/          # → mfzzf/go-ddd-skills @ main
├── frontend-build-2026/     # → mfzzf/frontend-build-2026 @ main
└── anthropics-skills/       # → anthropics/skills @ main (upstream Anthropic skills)
    └── skills/
        ├── frontend-design/
        ├── skill-creator/
        └── ...
```

## Updating a skill

```bash
# bump one skill to its remote HEAD
cd <skill-dir> && git pull origin main && cd ..
git add <skill-dir> && git commit -m "bump <skill> to <sha>"

# or bump everything at once
git submodule update --remote --merge
git commit -am "bump all skills"
```

## Adding a new skill

```bash
git submodule add git@github.com:mfzzf/<new-skill>.git <new-skill>
# then add an entry to the Catalog section above
git commit -am "add <new-skill>"
```

## Skill format

Every skill in this repo follows the Claude Code skill convention: a top-level `SKILL.md` with YAML frontmatter (`name`, `description`) and an optional `references/` folder for progressively-disclosed deeper docs. See [Anthropic's skill-creator guide](https://github.com/anthropics/skills) for the canonical format.
