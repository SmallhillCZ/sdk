#!/bin/bash -e

mkdir -p ~/.claude
cp "$(dirname "$0")/.claude/CLAUDE.md" ~/.claude/CLAUDE.md

mkdir -p ~/.claude/skills
cp -r "$(dirname "$0")/.claude/skills/." ~/.claude/skills/
