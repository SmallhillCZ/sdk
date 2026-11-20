#!/bin/bash -e

mkdir -p ~/.claude
cp "$(dirname "$0")/.claude/CLAUDE.md" ~/.claude/CLAUDE.md

mkdir -p ~/.claude/skills
cp -r "$(dirname "$0")/.claude/skills/." ~/.claude/skills/

mkdir -p ~/.claude/agents
cp -r "$(dirname "$0")/.claude/agents/." ~/.claude/agents/

mkdir -p ~/.local/bin
cp "$(dirname "$0")/bin/cclog" "$(dirname "$0")/bin/cclog-hook" ~/.local/bin/

if command -v jq >/dev/null; then
  settings=~/.claude/settings.json
  [ -s "$settings" ] || echo '{}' > "$settings"
  jq '
    def cclog: {matcher: "Bash", hooks: [{type: "command", command: "~/.local/bin/cclog-hook"}]};
    def ours: any(.hooks[]?; (.command // "") | test("cclog-hook|command-log\\.txt"));
    reduce ("PreToolUse", "PostToolUse", "PostToolUseFailure", "PermissionDenied") as $e
      (.; .hooks[$e] = ([(.hooks[$e] // [])[] | select(ours | not)] + [cclog]))
  ' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
else
  echo "jq not found: cclog hooks not registered in ~/.claude/settings.json" >&2
fi
