# SKILLS — 维护手册

本文件讲清楚一个核心问题：**这个仓库是一个目录索引，子 skill 各自有源仓**。
所以维护工作分两类：

- **catalog 操作**（在本仓做）：增删 skill、bump pin 到的 commit、更新 README、推 catalog。
- **skill 内容修改**（在源仓做）：写 SKILL.md、加 references、修触发词。本仓不直接修改 skill 内容；本仓只 pin 一个 commit。

> 心智模型：本仓相当于一个 `requirements.txt`/`go.mod`，submodule 就是 pinned version。

所有常用动作都封装成了 `make` 目标，先看一眼能干啥：

```bash
make help
```

---

## 0. 前置约定

- 默认分支：每个 skill 源仓和本仓都用 `main`。
- 远程：通过 SSH 拉取（`git@github.com:mfzzf/...`）。你需要 `gh auth` 或本机 SSH key 已配好。
- 子目录名 = `.gitmodules` 中的 `path`，约定与源仓名一致；如果差异，README 也按 path 写。

---

## 1. 首次克隆

```bash
git clone --recursive git@github.com:mfzzf/SKILLS.git
cd SKILLS
```

如果忘了 `--recursive`：

```bash
make init     # 等价于 git submodule update --init --recursive
```

`make init` 是幂等的，任何时候跑都安全。

---

## 2. 日常同步（同事更新过 catalog，我要拉最新）

```bash
make sync
```

这一条做了两件事：

1. `git pull --ff-only` 拉 catalog。
2. `git submodule update --init --recursive` 把每个子目录移动到 catalog 当前 pin 住的 commit。

> 注意：`make sync` **不会** 让 skill 跟随源仓的 HEAD。它只移动到 catalog 当前 pin 的位置。
> 想把 pin 也升上去，看 §4。

查看现在 pin 的 commit 和 upstream 差几个：

```bash
make status
```

输出例子：

```
frontend-build-2026
  pinned: b3f6e42   remote: b3f6e42   behind: 0
go-backend-ddd
  pinned: ddaa921   remote: f1c2030   behind: 3
```

---

## 3. 新增一个 skill

**前提**：skill 已经在 GitHub 有源仓，且根目录有 `SKILL.md`（含 `name` / `description` 的 YAML frontmatter）。

```bash
make add-skill SKILL=foo-skill URL=git@github.com:mfzzf/foo-skill.git
```

这会：
- `git submodule add <URL> foo-skill`
- 把 submodule 配置写进 `.gitmodules`
- 把当前 HEAD pin 进 catalog 索引

然后**手动**做剩下两步（这部分故意不自动化，目录条目最好你亲手过一遍）：

1. 在 `README.md` 的 **Catalog** 一节，按现有格式加一条：
   ```markdown
   ### [foo-skill](./foo-skill) · [source](https://github.com/mfzzf/foo-skill)

   一句话定位。

   **Triggers**: ...
   **What's inside**: ...
   ```
2. 验证 + 提交 + 推送：
   ```bash
   make check                          # 检查 submodule 和 README 都对得上
   make commit MSG="add foo-skill"
   make push
   ```

---

## 4. 升级一个或全部 skill 的 pin（catalog bump）

最常见的维护动作：源仓 skill 改完后，把 catalog 也跟上。

**升一个**：

```bash
make bump SKILL=frontend-build-2026
```

它会进入子目录 `git checkout main && git pull`，再 `git add` 子目录，commit message 自动写成 `bump <skill> to <short-sha>`。如果已经在最新，提示无变更并退出。

**全部升**：

```bash
make bump-all
```

底层就是 `git submodule update --remote --merge` + 一个聚合 commit。

随后：

```bash
make push
```

> 提醒：`bump*` 只 stage 一个 commit，**不会**自动 push。push 是你显式触发的。

---

## 5. 修改某个 skill 的内容

**不要**直接在本仓子目录里改完就 commit——那会让 submodule 进入 detached HEAD 状态，改动也不会推到源仓。

正确流程：

```bash
# 1. 进入源仓单独工作（推荐另开终端 / 另开目录）
cd ~/path/to/frontend-build-2026
git checkout main
# ...改 SKILL.md / references ...
git commit -am "..."
git push

# 2. 回到 catalog，bump pin
cd /Users/zzf/GoProjects/modelverse/research/SKILLS
make bump SKILL=frontend-build-2026
make push
```

如果你**临时**就想在 catalog 子目录里改 + 验证，记得：

```bash
cd frontend-build-2026
git checkout main             # 脱离 detached
# 编辑...
git commit -am "..."
git push origin main          # 推回源仓
cd ..
make bump SKILL=frontend-build-2026
```

---

## 6. 删除一个 skill

```bash
make remove-skill SKILL=foo-skill
```

它会跑 `git submodule deinit` + `git rm` + 清理 `.git/modules/foo-skill`。然后手动：

1. 从 `README.md` 的 Catalog 里删条目。
2. `make commit MSG="remove foo-skill" && make push`

源仓本身不会动，只是 catalog 不再 pin 它。

---

## 7. 调试 / 检查

| 想干嘛 | 命令 |
|---|---|
| 看 catalog 工作树状态 | `git status` 或 `make check` |
| 看每个 skill pin / 上游差多少 | `make status` |
| 在每个 skill 跑命令 | `make foreach CMD='git log -1 --oneline'` |
| 清理子模块里未跟踪垃圾 | `make clean` |
| 看所有 make 目标 | `make help` |

---

## 8. 常见坑

- **submodule 显示 dirty / 有未提交改动**：你在子目录里改了文件却没 commit/push。先去源仓提交并推送，再回来 `make bump`。
- **detached HEAD**：`git submodule update` 默认就是 detached。`make bump` 里会 `git checkout main` 帮你脱离；如果手动操作，记得自己 `checkout main`。
- **`make sync` 之后 skill 回退了**：因为 catalog pin 的 commit 老于源仓 HEAD。要么 `make bump-all`，要么接受现状（catalog 就是要锁版本）。
- **README 没更新就 push**：`make check` 会提示 `✗ skill missing from README`。CI 阶段也可以加这步当门禁。
- **想看子 skill 的最新内容而非 pin 的版本**：进入子目录 `git fetch && git log origin/main`，但**不要** commit 它到 catalog，除非你打算 bump。

---

## 9. 速查卡

```bash
# 拉
git clone --recursive git@github.com:mfzzf/SKILLS.git
make init                                                    # 兜底
make sync                                                    # 日常同步

# 看
make status                                                  # pin vs upstream
make check                                                   # 索引完整性
make link-status                                             # 客户端 symlink 状态

# 改 catalog
make add-skill    SKILL=foo URL=git@github.com:mfzzf/foo.git
make bump         SKILL=foo
make bump-all
make remove-skill SKILL=foo

# 客户端实时同步
make link                                                    # 链入 ~/.claude/skills + ~/.codex/skills
make unlink                                                  # 反向解链

# 发
make commit MSG="..."
make push
```

---

## 10. 与 Claude Code / Codex 客户端实时同步

Claude Code 读取 `~/.claude/skills/`，Codex 读取 `~/.codex/skills/`。我们要的是**改 catalog → 客户端立刻看到**，而不是 copy。结论：用 **symlink**，不要 copy。

### 一次绑定

```bash
make link
```

这会把每个 catalog skill 链入两个客户端目录：
- `frontend-build-2026`、`go-backend-ddd`、`modelverse-image` → 直接指向 catalog 子目录
- `anthropics-skills` 是上游 bundle，自动展开它的 `skills/*` 每个子 skill（`frontend-design`、`skill-creator` 等）

冲突处理：
- 已存在的同名 symlink，会更新到新 target 并打印 `~`
- 已存在的**真目录**（不是 link），会**跳过并提示**——先把它挪到 `xxx.bak.<ts>` 或删掉，再 `make link`
- 已经指向 catalog 的 link，原样保留，打印 `=`

### 实时同步是怎么实现的

- 你在 catalog 里 `make bump SKILL=frontend-build-2026`：子目录 commit 移动 → 客户端通过 symlink 立刻看到新内容，**零延迟、零 copy**。
- 你在 `~/.claude/skills/foo-skill/SKILL.md` 里改一行：因为是 symlink，等同于改 catalog 子模块本体；走正常的"在源仓改 → push → catalog bump"流程（见 §5）。
- 升级所有上游 Anthropic skill：`make bump SKILL=anthropics-skills && make push`——两个客户端同时拿到新版。

### 验证

```bash
make link-status
```

每条会标记：
- `[catalog]` — 指向本仓 submodule（受控）
- `[external]` — 指向别处（你之前装的，比如 `~/.agents/skills/drawio`）
- `□ ... (real dir, not linked)` — 客户端目录里有同名真目录占位

### 反操作 / 卸载

```bash
make unlink
```

只删指向 catalog 的 symlink，不动其它东西（外部 link、真目录都安全）。

### 自定义目标根

默认 `CLAUDE_ROOT=~/.claude/skills`、`CODEX_ROOT=~/.codex/skills`。多环境（比如分离测试环境）可临时覆盖：

```bash
make link CLAUDE_ROOT=/tmp/claude-skills CODEX_ROOT=/tmp/codex-skills
```

### 不用 symlink 的情况

如果某个客户端目录在网络盘或 Windows 路径不支持 symlink，再退化到 copy + cron。否则 symlink 是事实标准——既"实时"又零维护成本。
