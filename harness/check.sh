#!/usr/bin/env bash
# Kiro harness checks, run by .github/workflows/checks.yml on this branch.
# Validates agent front matter, referenced paths, sub-agent targets, and that
# the orchestrator's allow rules cover every role's (Kiro requires both).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 -c 'import yaml' 2>/dev/null || python3 -m pip install -q --break-system-packages pyyaml

python3 - <<'EOF'
import fnmatch, glob, os, re, sys
import yaml

errors = []
def err(f, msg):
    errors.append(f"::error file={f}::{msg}")

shell_allow = {}
for f in sorted(glob.glob(".kiro/agents/*.md")):
    text = open(f).read()
    if not text.startswith("---\n") or "\n---\n" not in text[4:]:
        err(f, "missing YAML front matter"); continue
    fm, body = text[4:].split("\n---\n", 1)
    try:
        d = yaml.safe_load(fm)
    except yaml.YAMLError as e:
        err(f, f"invalid YAML: {e}"); continue
    name = d.get("name")
    if name != os.path.basename(f)[:-3]:
        err(f, f"name '{name}' does not match the file name")
    if not d.get("description"):
        err(f, "missing description")
    for r in d.get("resources", []):
        p = r.removeprefix("file://")
        if not os.path.exists(p):
            err(f, f"resource not found: {r}")
    for t in d.get("tools", []):
        if t.startswith("subagent/") and not os.path.exists(f".kiro/agents/{t[9:]}.md"):
            err(f, f"sub-agent not defined: {t}")
    rules = (d.get("permissions") or {}).get("rules", [])
    for r in rules:
        if r.get("effect") not in {"allow", "ask", "deny"} or not isinstance(r.get("match"), list):
            err(f, f"malformed permission rule: {r}")
    shell_allow[name] = {m for r in rules if r.get("capability") == "shell" and r.get("effect") == "allow" for m in r["match"]}
    for m in re.findall(r"`(docs/agents/[^`<]+\.md)`", body):
        if not os.path.exists(m):
            err(f, f"broken reference: {m}")

if "orchestrator" in shell_allow:
    roles = set().union(*(v for k, v in shell_allow.items() if k != "orchestrator"))
    orch = shell_allow["orchestrator"]
    # A role pattern is covered if some orchestrator pattern matches it as a glob.
    missing = sorted(p for p in roles if not any(fnmatch.fnmatchcase(p, o) for o in orch))
    if missing:
        err(".kiro/agents/orchestrator.md", "shell allow rules missing (sub-agents will prompt): " + ", ".join(missing))

for f in glob.glob(".kiro/steering/*.md"):
    text = open(f).read()
    for p in re.findall(r"#\[\[file:([^\]]+)\]\]", text):
        if not os.path.exists(p):
            err(f, f"file reference not found: {p}")
    if not text.startswith("---\n"):
        err(f, "no front matter: this steering file would load into every session")

print("\n".join(errors) if errors else "kiro harness: ok")
sys.exit(1 if errors else 0)
EOF
