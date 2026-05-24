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

### [shadcn-ui-docs](./shadcn-ui-docs) &nbsp;·&nbsp; [source](https://github.com/mfzzf/shadcn-ui-docs)

Offline mirror of the **shadcn/ui documentation** (`ui.shadcn.com/llms.txt` index + per-page `.md` for ~109 doc pages). Covers installation across Next.js/Vite/Remix/Astro/Laravel/Gatsby/React-Router/TanStack, all ~60 components (Button → DataTable → Sidebar → Sonner), CLI, `components.json`, theming, dark mode, RTL, forms, monorepo, React 19, Tailwind v4, MCP server, and the `registry.json` / `registry-item.json` schemas.

**Triggers**: `shadcn`, `shadcn/ui`, `npx shadcn add`, `components.json`, `registry.json`, `registry-item.json`, Radix-based component names (Dialog/Sheet/Combobox/DataTable/Sidebar/Sonner/…), "shadcn 文档".

---

### [nextjs-docs](./nextjs-docs) &nbsp;·&nbsp; [source](https://github.com/mfzzf/nextjs-docs)

Offline mirror of the **Next.js 16.2.6 documentation** (`nextjs.org/docs/llms.txt` + nested `pages/llms.txt` → 406 raw markdown pages). Covers both App Router and Pages Router — Getting Started, every Guide (auth, forms, MDX, testing, OpenTelemetry, PWA, migrations, multi-zones, view transitions), full API Reference (every directive / component / file convention / function / `next.config.js` option / CLI / Adapter / Edge Runtime / Turbopack), Architecture, Community.

**Triggers**: `next.config.js`, `app/`, `pages/`, `use server` / `use client` / `use cache`, Server Actions, RSC, ISR, PPR, `revalidateTag`, `generateMetadata`, `next/image`, `next/link`, `next/font`, `create-next-app`, Turbopack, Edge Runtime, `proxy.js`, `instrumentation.js`, "Next.js 16", "App Router", "Pages Router", "Next.js 文档".

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

### Upstream — [wdkns-skills](./wdkns-skills) &nbsp;·&nbsp; [source](https://github.com/wdkns/wdkns-skills)

视频讲座 → 结构化中文 LaTeX 讲义/PDF 的工具集，外加一个 SRT 字幕精修 skill。Bundle 结构，子 skill 通过 `make link` 自动展开到 `~/.claude/skills/`。

#### [→ youtube-render-pdf](./wdkns-skills/skills/youtube-render-pdf)

把 YouTube 视频（讲座、教程、技术分享）转成图文并茂的中文 LaTeX 讲义并渲染为 PDF：抓取标题/章节/字幕、抽取关键帧/图表/公式/代码、首页放原始封面、末尾加综述章节。

**Triggers**: "YouTube 视频转讲义"、"YouTube → PDF"、"把这个 YouTube 教程整理成笔记"。

#### [→ bilibili-render-pdf](./wdkns-skills/skills/bilibili-render-pdf)

YouTube 流程的 B 站适配版：字幕三级回退（CC → Whisper ASR → 纯视觉）、cookies 登录拿 1080P+、分 P 视频询问处理范围、过滤"一键三连"等平台话术。

**Triggers**: "B 站视频转讲义"、"Bilibili → PDF"、BV 号 + "整理成笔记"。

#### [→ subtitle-refine](./wdkns-skills/skills/subtitle-refine)

中文 SRT 字幕上线级精修：只做 ASR 纠错/语气词清理/停顿空格/单条字数限制，不润色不改写，保持与原音频严格同步；随附 `check_clean_srt.py` 做规则与时间轴校验。

**Triggers**: "字幕精修"、"clean SRT"、"SRT 校验"、纪录片/访谈/口播字幕清洗。

---

### Upstream — [shadcn-ui](./shadcn-ui) &nbsp;·&nbsp; [source](https://github.com/shadcn-ui/ui)

shadcn/ui 官方 monorepo 中的 skill 包。整个 `shadcn-ui/ui` 仓库作为 submodule pin 住，`make link` 通过 bundle 展开 `skills/*`。注意与 [`shadcn-ui-docs`](./shadcn-ui-docs) 区分——那个是文档离线镜像；这个是上游官方维护的 skill 本体。

#### [→ shadcn](./shadcn-ui/skills/shadcn)

管理 shadcn 组件和项目：add / search / fix / debug / style / compose UI，提供项目上下文、组件文档与用法示例。强制走 `npx shadcn@latest`（或 pnpm dlx / bunx）并优先使用已有组件 + 内置 variants + 语义化颜色，而不是写自定义样式。

**Triggers**: `shadcn`、`shadcn/ui`、`components.json`、`shadcn init`、`--preset`、"switch to --preset"、组件注册表 / 添加组件 / 调试组件样式。

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
