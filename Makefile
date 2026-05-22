.PHONY: help init status sync bump bump-all add-skill remove-skill check push pull foreach clean link unlink link-status

# -------- config --------
SHELL := /bin/bash
SKILL ?=
URL   ?=
MSG   ?=

# Roots that consume skills. Override with `make link CLAUDE_ROOT=... CODEX_ROOT=...`.
CLAUDE_ROOT ?= $(HOME)/.claude/skills
CODEX_ROOT  ?= $(HOME)/.codex/skills

# Catalog root (absolute) — used as symlink target so links survive `cd`.
CATALOG := $(abspath .)

# Discover submodule paths from .gitmodules at make-time
SKILLS := $(shell git config -f .gitmodules --get-regexp '^submodule\..*\.path$$' 2>/dev/null | awk '{print $$2}')

# For the upstream anthropics-skills bundle, the actual skills live one level deeper.
# Override on the cmdline if you add more bundles: `make link BUNDLES="anthropics-skills:skills other:foo"`
BUNDLES ?= anthropics-skills:skills

# -------- meta --------
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make init                                  # first-time clone setup"
	@echo "  make sync                                  # pull catalog + submodules to pinned commits"
	@echo "  make bump SKILL=frontend-build-2026        # bump one skill to its remote HEAD"
	@echo "  make bump-all                              # bump every skill to remote HEAD"
	@echo "  make add-skill SKILL=my-skill URL=git@github.com:mfzzf/my-skill.git"
	@echo "  make remove-skill SKILL=my-skill"
	@echo "  make push                                  # push catalog changes to origin"

# -------- everyday --------
init: ## Initialize submodules after a fresh clone (idempotent)
	git submodule update --init --recursive

status: ## Show current commit of each skill and whether it's behind upstream
	@for s in $(SKILLS); do \
	  printf "\033[1m%s\033[0m\n" "$$s"; \
	  (cd "$$s" && \
	    cur=$$(git rev-parse --short HEAD) && \
	    git fetch -q origin && \
	    rem=$$(git rev-parse --short origin/HEAD 2>/dev/null || git rev-parse --short origin/main) && \
	    behind=$$(git rev-list --count HEAD..origin/HEAD 2>/dev/null || git rev-list --count HEAD..origin/main) && \
	    echo "  pinned: $$cur   remote: $$rem   behind: $$behind"); \
	done

sync: ## Pull catalog AND move submodules to the catalog's pinned commits
	git pull --ff-only
	git submodule update --init --recursive

pull: sync ## Alias for sync

# -------- bumping skills --------
bump: ## Bump one skill to its remote default-branch HEAD (requires SKILL=)
	@test -n "$(SKILL)" || (echo "ERROR: SKILL= is required (e.g. make bump SKILL=frontend-build-2026)"; exit 1)
	@test -d "$(SKILL)" || (echo "ERROR: $(SKILL) is not a submodule"; exit 1)
	cd "$(SKILL)" && git fetch origin && git checkout main && git pull --ff-only origin main
	git add "$(SKILL)"
	@if git diff --cached --quiet; then \
	  echo "no changes — $(SKILL) already at pinned commit"; \
	else \
	  sha=$$(cd "$(SKILL)" && git rev-parse --short HEAD); \
	  git commit -m "bump $(SKILL) to $$sha"; \
	  echo "bumped $(SKILL) -> $$sha (commit staged; run \`make push\` to publish)"; \
	fi

bump-all: ## Bump every skill to its remote HEAD
	git submodule update --remote --merge
	@if git diff --quiet; then \
	  echo "no changes — every skill already at remote HEAD"; \
	else \
	  git add $(SKILLS); \
	  git commit -m "bump all skills to remote HEAD"; \
	  echo "bumped all skills (commit staged; run \`make push\` to publish)"; \
	fi

# -------- managing the catalog --------
add-skill: ## Add a new skill submodule (requires SKILL= and URL=)
	@test -n "$(SKILL)" || (echo "ERROR: SKILL= is required"; exit 1)
	@test -n "$(URL)"   || (echo "ERROR: URL= is required (e.g. git@github.com:mfzzf/foo.git)"; exit 1)
	@test ! -e "$(SKILL)" || (echo "ERROR: $(SKILL) already exists"; exit 1)
	git submodule add "$(URL)" "$(SKILL)"
	@echo ""
	@echo "Submodule added. Next steps:"
	@echo "  1. Add a Catalog entry for $(SKILL) in README.md"
	@echo "  2. make check"
	@echo "  3. git commit -m 'add $(SKILL)'  (or: make commit MSG=\"add $(SKILL)\")"
	@echo "  4. make push"

remove-skill: ## Remove a skill submodule (requires SKILL=)
	@test -n "$(SKILL)" || (echo "ERROR: SKILL= is required"; exit 1)
	@test -d "$(SKILL)" || (echo "ERROR: $(SKILL) is not a submodule"; exit 1)
	git submodule deinit -f -- "$(SKILL)"
	git rm -f "$(SKILL)"
	rm -rf ".git/modules/$(SKILL)"
	@echo "Removed $(SKILL). Don't forget to drop its Catalog entry from README.md, then \`make push\`."

# -------- helpers --------
foreach: ## Run a command in every skill (CMD="git status")
	@test -n "$(CMD)" || (echo "ERROR: CMD= is required (e.g. make foreach CMD='git log -1 --oneline')"; exit 1)
	git submodule foreach --recursive "$(CMD)"

check: ## Sanity-check the catalog (no detached drift, README has entries)
	@echo "→ submodules registered:"
	@for s in $(SKILLS); do echo "  - $$s"; done
	@echo "→ README.md mentions:"
	@for s in $(SKILLS); do \
	  if grep -q "$$s" README.md; then echo "  ✓ $$s"; else echo "  ✗ $$s   (missing from README catalog!)"; fi; \
	done
	@echo "→ working tree:"
	@git status --short

commit: ## Commit pending catalog changes (MSG=...)
	@test -n "$(MSG)" || (echo "ERROR: MSG= is required"; exit 1)
	git commit -m "$(MSG)"

push: ## Push catalog (NOT submodule sources — those are pushed from their own repos)
	git push origin main

clean: ## Drop untracked junk inside submodules (does not touch tracked files)
	git submodule foreach --recursive 'git clean -fdx -e .gitkeep || true'

# -------- realtime sync via symlinks --------
# Strategy: ~/.claude/skills/<name> and ~/.codex/skills/<name> are symlinks
# into this catalog. Pulling/bumping in the catalog is instantly visible to
# both Claude Code and Codex with no copy step.

link: ## Symlink every catalog skill into ~/.claude/skills and ~/.codex/skills
	@mkdir -p "$(CLAUDE_ROOT)" "$(CODEX_ROOT)"
	@for s in $(SKILLS); do \
	  bundle_inner=""; \
	  for pair in $(BUNDLES); do \
	    name=$${pair%%:*}; inner=$${pair##*:}; \
	    if [ "$$s" = "$$name" ]; then bundle_inner=$$inner; fi; \
	  done; \
	  if [ -n "$$bundle_inner" ]; then \
	    for sub in "$(CATALOG)/$$s/$$bundle_inner"/*/; do \
	      [ -d "$$sub" ] || continue; \
	      name=$$(basename "$$sub"); \
	      $(MAKE) -s _link_one TARGET="$(CATALOG)/$$s/$$bundle_inner/$$name" NAME="$$name"; \
	    done; \
	  else \
	    $(MAKE) -s _link_one TARGET="$(CATALOG)/$$s" NAME="$$s"; \
	  fi; \
	done
	@echo ""
	@echo "Done. Verify with: make link-status"

# Internal: link one TARGET as NAME into both roots, skipping conflicts.
_link_one:
	@for root in "$(CLAUDE_ROOT)" "$(CODEX_ROOT)"; do \
	  dest="$$root/$(NAME)"; \
	  if [ -L "$$dest" ]; then \
	    cur=$$(readlink "$$dest"); \
	    if [ "$$cur" = "$(TARGET)" ]; then \
	      echo "  = $$dest"; \
	    else \
	      ln -sfn "$(TARGET)" "$$dest"; \
	      echo "  ~ $$dest  (was -> $$cur)"; \
	    fi; \
	  elif [ -e "$$dest" ]; then \
	    echo "  ! $$dest exists as a real dir/file — skipped. Move it aside, then rerun."; \
	  else \
	    ln -s "$(TARGET)" "$$dest"; \
	    echo "  + $$dest"; \
	  fi; \
	done

unlink: ## Remove symlinks this catalog created in both roots (keeps real dirs untouched)
	@for root in "$(CLAUDE_ROOT)" "$(CODEX_ROOT)"; do \
	  [ -d "$$root" ] || continue; \
	  for entry in "$$root"/*; do \
	    [ -L "$$entry" ] || continue; \
	    target=$$(readlink "$$entry"); \
	    case "$$target" in \
	      "$(CATALOG)"/*) rm "$$entry" && echo "  - $$entry";; \
	    esac; \
	  done; \
	done

link-status: ## Show what's linked in ~/.claude/skills and ~/.codex/skills
	@for root in "$(CLAUDE_ROOT)" "$(CODEX_ROOT)"; do \
	  echo ""; \
	  printf "\033[1m%s\033[0m\n" "$$root"; \
	  [ -d "$$root" ] || { echo "  (does not exist)"; continue; }; \
	  for entry in "$$root"/*; do \
	    [ -e "$$entry" ] || [ -L "$$entry" ] || continue; \
	    name=$$(basename "$$entry"); \
	    if [ -L "$$entry" ]; then \
	      target=$$(readlink "$$entry"); \
	      case "$$target" in \
	        "$(CATALOG)"/*) echo "  ↪ $$name -> $$target  [catalog]";; \
	        *)              echo "  ↪ $$name -> $$target  [external]";; \
	      esac; \
	    else \
	      echo "  □ $$name  (real dir, not linked)"; \
	    fi; \
	  done; \
	done
