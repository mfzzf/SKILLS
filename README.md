# SKILLS

A curated index of Claude / Cursor / Codex compatible skills I maintain. Each entry is a standalone repo and is wired in here as a git submodule, so a single `git clone --recursive` pulls every skill at the pinned commit.

```bash
git clone --recursive git@github.com:mfzzf/SKILLS.git
# or, on an existing clone
git submodule update --init --recursive
```

To install a skill into your own Claude Code / Cursor / Codex setup, copy or symlink the corresponding subdirectory under `~/.claude/skills/` (or your tool's equivalent).

> Maintaining this catalog? See **[MAINTENANCE.md](./MAINTENANCE.md)** and run `make help`.

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
