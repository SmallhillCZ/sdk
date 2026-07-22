---
name: commit-and-push
description: Commit the current working-tree changes as a series of focused commits (one per logical feature/fix) and then push the branch to the remote. Use when the user asks to commit and push, or says "/commit-and-push".
---

# Commit and push

Same as `/commit`, then push.

## Step 1 — Commit

Follow the **exact** procedure and rules in the `commit` skill (`~/.claude/skills/commit/SKILL.md`): survey the tree, read the diff, group changes into one commit per logical concern, stage explicit paths, and commit each group with a message matching the repo's style.

Read that file now if it is not already in context, and apply it in full — including the rules about never using `git add -A`, never adding `Co-Authored-By` or other attribution trailers, never committing secrets or build artifacts, and never amending existing commits.

## Step 2 — Push

Only after every intended commit exists:

1. Check where you are: `git branch --show-current` and `git status -sb`.
2. **If the current branch is the repo's default branch (`master`/`main`):** stop and ask the user before pushing. Offer to move the commits onto a topic branch instead.
3. Push:
   - if the branch has an upstream: `git push`
   - if not: `git push -u origin <branch>`
4. **Never force-push** (`--force`, `--force-with-lease`) unless the user explicitly asks for it in this conversation.
5. If the push is rejected as non-fast-forward, do **not** force. Report the rejection and ask whether to pull/rebase first.

## Step 3 — Report

State the commits created, the branch, and the push result (including the remote URL or ref that was updated). Call out anything left uncommitted and why.
