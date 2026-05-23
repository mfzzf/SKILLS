#!/usr/bin/env python3
"""lint-skills.py — validate every catalog SKILL.md frontmatter.

Why: Claude Code / Codex parse SKILL.md frontmatter as YAML. A bare colon
inside an unquoted value (the description being the usual offender) trips
"mapping values are not allowed in this context" and the skill silently
fails to load.

This linter has two modes:

  1. If `pyyaml` is importable, do a real YAML parse — most accurate.
  2. Else, fall back to a stdlib-only heuristic that:
       - extracts the frontmatter block,
       - splits top-level `key: value` lines,
       - for each unquoted value, strips properly-quoted substrings,
       - then flags any remaining `: [\"`']` pattern.
     This catches every failure we've actually hit so far.

It also checks that every SKILL.md has non-empty `name:` and `description:`.

Exit code: 0 if all pass, 1 if any fail.

Usage:
    scripts/lint-skills.py                # lint every catalog skill
    scripts/lint-skills.py path/SKILL.md  # lint one file
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---", re.S)

try:
    import yaml  # type: ignore[import-not-found]
    HAS_YAML = True
except ImportError:
    HAS_YAML = False


def extract_frontmatter(text: str) -> str | None:
    m = FRONTMATTER_RE.match(text)
    return m.group(1) if m else None


def find_risky_colon(value: str) -> int | None:
    """Scan an unquoted YAML scalar value char-by-char tracking quote context.

    Returns the column (0-based, within the value) of the first ': ' that
    sits OUTSIDE any quote — that's a YAML "implicit mapping" trap.

    Tracks `"` and `` ` `` as quote delimiters. Deliberately does NOT track
    `'` because English apostrophes (`it's`, `don't`) would otherwise hijack
    the state machine and cause false negatives; YAML single-quoted scalars
    are very rare in skill descriptions, so the trade-off is heavily worth it.
    """
    i = 0
    n = len(value)
    quote = None  # current quote char or None
    while i < n:
        c = value[i]
        if quote is None:
            if c in ('"', "`"):
                quote = c
            elif c == ":" and i + 1 < n and value[i + 1] == " ":
                return i
        else:
            if c == quote:
                quote = None
        i += 1
    return None


def heuristic_check(fm: str) -> list[str]:
    """Return a list of issue strings; empty list = clean."""
    issues: list[str] = []
    for lineno, line in enumerate(fm.splitlines(), start=2):  # +1 for the opening ---
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*): (.*)$", line)
        if not m:
            continue
        key, value = m.group(1), m.group(2)
        # Block scalar markers are immune from this class of bug
        if value.strip() in ("|", "|-", "|+", ">", ">-", ">+"):
            continue
        # A value that is itself fully quoted is also fine
        v = value.strip()
        if (v.startswith('"') and v.endswith('"') and len(v) >= 2) or \
           (v.startswith("'") and v.endswith("'") and len(v) >= 2):
            continue
        risky_col = find_risky_colon(value)
        if risky_col is not None:
            snippet = value[max(0, risky_col - 12) : risky_col + 18]
            col = risky_col + len(key) + 2  # account for "key: "
            issues.append(
                f"line {lineno}, col {col} in `{key}`: bare `: ` outside quotes "
                f"(...{snippet}...) — YAML parses this as nested mapping"
            )
    return issues


def yaml_check(fm: str) -> list[str]:
    try:
        data = yaml.safe_load(fm)
    except yaml.YAMLError as e:
        return [f"YAML parse error: {e}"]
    if not isinstance(data, dict):
        return ["frontmatter is not a mapping"]
    issues = []
    for required in ("name", "description"):
        if required not in data:
            issues.append(f"missing required key `{required}`")
        elif not str(data.get(required, "")).strip():
            issues.append(f"`{required}` is empty")
    return issues


def lint_file(path: Path) -> list[str]:
    if not path.is_file():
        return [f"not a file: {path}"]
    text = path.read_text(encoding="utf-8")
    fm = extract_frontmatter(text)
    if fm is None:
        return ["no YAML frontmatter (file must start with `---` block)"]
    if HAS_YAML:
        issues = yaml_check(fm)
    else:
        issues = heuristic_check(fm)
        # Also enforce required keys via simple regex when YAML isn't there
        for req in ("name", "description"):
            if not re.search(rf"^{req}: +\S", fm, re.M):
                issues.append(f"missing or empty `{req}:` line")
    return issues


def find_skill_files() -> list[Path]:
    """Find every catalog skill's SKILL.md, plus top-level (if any)."""
    targets: list[Path] = []
    # Read .gitmodules to know which subdirs are catalog submodules
    gm = ROOT / ".gitmodules"
    if gm.exists():
        for line in gm.read_text(encoding="utf-8").splitlines():
            m = re.match(r"\s*path = (.+)$", line)
            if m:
                p = ROOT / m.group(1) / "SKILL.md"
                if p.is_file():
                    targets.append(p)
    # Also walk known bundle dirs (anthropics-skills/skills, superpowers/skills) for nested SKILL.md
    for bundle_rel in ("anthropics-skills/skills", "superpowers/skills"):
        bundle = ROOT / bundle_rel
        if bundle.is_dir():
            for sub in sorted(bundle.iterdir()):
                sub_skill = sub / "SKILL.md"
                if sub_skill.is_file():
                    targets.append(sub_skill)
    return targets


def main(argv: list[str]) -> int:
    files = [Path(a) for a in argv[1:]] if len(argv) > 1 else find_skill_files()
    if not files:
        print("no SKILL.md files found", file=sys.stderr)
        return 1

    mode = "pyyaml" if HAS_YAML else "heuristic"
    print(f"→ linting {len(files)} SKILL.md file(s) [{mode}]")
    failed = 0
    for f in files:
        rel = f.relative_to(ROOT) if f.is_relative_to(ROOT) else f
        issues = lint_file(f)
        if issues:
            failed += 1
            print(f"✗ {rel}")
            for i in issues:
                print(f"    - {i}")
        else:
            print(f"✓ {rel}")

    print()
    if failed:
        print(f"✗ {failed}/{len(files)} failed")
        if not HAS_YAML:
            print("  (heuristic mode — install pyyaml for full validation: `pip install pyyaml`)")
        return 1
    print(f"✓ all {len(files)} clean")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
