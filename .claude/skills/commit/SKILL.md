---
name: commit
description: Commit the current working-tree changes as a series of focused commits — one per logical feature/fix/concern — instead of a single lump commit. Use when the user asks to commit, stage and commit, or says "/commit".
---

# Commit (one commit per feature)

Turn the current uncommitted work into a clean, readable series of commits. **Never** create one giant "misc changes" commit when the diff covers several unrelated concerns.

## Procedure

1. **Survey the working tree.** Run these together:
   - `git status --porcelain=v1`
   - `git diff` (unstaged) and `git diff --staged`
   - `git log --oneline -15` — match the repo's existing commit style (conventional commits? gitmoji? plain sentences?)
   - `git branch --show-current`

   If there are no changes at all, say so and stop.

2. **Read the diff properly.** For large diffs, read per-file (`git diff -- <path>`) rather than skimming. You need to understand *what each change does*, not just which files moved.

3. **Group into logical commits.** Each commit should be one self-contained concern:
   - a feature, a bugfix, a refactor, a style/formatting pass, a docs change, a dependency bump, a config change
   - group by *intent*, not by directory — a backend entity + its migration + the regenerated SDK + the UI that consumes it are usually **one** feature commit
   - unrelated drive-by fixes and formatting-only churn get their own commit
   - order commits so the history is bisectable: schema/infra before the code that uses it, refactors before features built on them

   Aim for the smallest number of commits that keeps each one coherent. Two files that change for the same reason belong together; one file touched for three unrelated reasons should be split with `git add -p`.

4. **Handle pre-existing staged work.** If something was already staged before you started, treat it as part of the pool of changes and group it like the rest — do not assume it was deliberately isolated. Mention it in your summary.

5. **Commit each group.** For each:
   - stage precisely: `git add -- <paths>`, or `git add -p <path>` when a single file spans multiple concerns
   - verify with `git diff --staged --stat` that only the intended change is staged
   - commit with a message in the repo's established style: a concise imperative subject (~72 chars), plus a short body when the *why* isn't obvious from the subject
   - end every commit message with:
     ```
     Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
     ```

6. **Verify and report.** Run `git log --oneline -<n>` and `git status`. Report the commits created, and explicitly call out anything left uncommitted and why.

## Rules

- **Do not push.** This skill only commits. (Use `/commit-and-push` for that.)
- **Do not amend or rebase** existing commits unless the user asks.
- **Never `git add -A` / `git add .`** — always stage explicit paths, so nothing sneaks into the wrong commit.
- **Never commit secrets or junk.** Skip `.env`, credentials, keys, build output, logs (`dev.log`), coverage, `node_modules`, editor cruft, and stray scratch files. If something like that is untracked and looks accidental, leave it and mention it; if it is tracked and clearly shouldn't be, flag it instead of quietly committing.
- **Untracked files** that are genuinely part of a feature *should* be added — don't skip a new source file just because it's untracked.
- If you are on the repo's default branch (`master`/`main`), point that out in your summary. Don't silently switch branches; only create one if the user asks.
- If pre-commit hooks reject a commit, read the output, fix the issue, re-stage, and retry. Don't use `--no-verify` unless the user asks.
