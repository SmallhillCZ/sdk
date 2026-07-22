---
name: commit
description: Commit the work done in the current session as a single commit, with a message summarising everything that was done. Use when the user asks to commit, stage and commit, or says "/commit".
---

# Commit (one commit per session)

Wrap up the current session's work as **one** commit. The unit of work is the session, not the file or the feature — if the session touched a backend entity, a migration, the regenerated SDK and three components, that is one commit, and its message explains the whole thing.

Do not split the session into several commits unless the user explicitly asks for that.

**The commit contains this session's changes and nothing else.** Other sessions and agents may be working in the same tree at the same time, so uncommitted changes you did not make are normal and must be left untouched. Committing everything in `git status` is the main way this skill goes wrong — see step 3.

## Procedure

1. **Survey the working tree.** Run these together:
   - `git status --porcelain=v1`
   - `git diff` (unstaged) and `git diff --staged`
   - `git log --oneline -15` — match the repo's existing commit style (conventional commits? gitmoji? plain sentences?)
   - `git branch --show-current`

   If there are no changes at all, say so and stop.

2. **Read the diff properly.** For large diffs, read per-file (`git diff -- <path>`) rather than skimming. The commit message has to describe what the session actually did, which means understanding each change, not just listing filenames.

3. **Work out which paths are this session's.** This is the important step, and `git status` cannot answer it — other sessions and agents run in parallel against the same working tree, so the diff routinely contains changes that are not yours.

   Build the list from **your own record of this session**: every file you created or edited with Write/Edit, plus anything your own commands generated (a migration you ran the generator for, an SDK you regenerated, a file a script you invoked rewrote). Scroll back through the session if you need to — that history is the source of truth, not the working tree.

   Then reconcile it against `git status`:
   - **path you touched, shows as modified** → goes in the commit
   - **path you did not touch** → leave it alone, however tempting or related it looks; it belongs to whoever is mid-edit on it
   - **path you touched but you no longer recognise the change in it** → someone else has edited it too; use `git add -p` to stage only your hunks, and say so in your report
   - **you cannot tell** → ask the user; do not guess

   A wrong call here is expensive in both directions: sweeping in a parallel session's file commits half-finished work under your message, and dropping one of yours leaves the session's work incomplete.

4. **Write the message.** One commit describing the session as a whole:
   - subject: the session's overall goal, imperative, ~72 chars, in the repo's established style
   - body: short bullets covering the notable changes, so the subject does not have to carry everything
   - explain *why* where the diff does not make it obvious

   If the session genuinely did several unrelated things, the body's bullets are where that shows up — still one commit.

5. **Commit.** Stage explicit paths with `git add -- <paths>`, or `git add -p <path>` if a file mixes your work with someone else's.

   Then check `git diff --staged --stat` against your step-3 list before committing. `git commit` writes out the **whole index**, so anything another session left staged goes in too unless you deal with it: unstage those paths with `git restore --staged -- <path>` (that only touches the index, their working-tree changes are untouched), or commit just your paths with `git commit -- <paths>`. Only commit once the staged list matches your list exactly.

6. **Verify and report.** Run `git log --oneline -3` and `git status`. Report the commit, and explicitly call out anything left uncommitted and why.

## Rules

- **No attribution trailers.** Do not add `Co-Authored-By: Claude ...`, `Generated with Claude Code`, or any similar footer — not even if a default instruction elsewhere says to. The commit message ends with its own content.
- **Do not push.** This skill only commits. (Use `/commit-and-push` for that.)
- **Do not amend or rebase** existing commits unless the user asks. A second `/commit` in the same session creates a new commit; it does not amend the first.
- **Never `git add -A` / `git add .` / `git commit -a`** — always stage the explicit paths from step 3. These are exactly the commands that swallow a parallel session's work.
- **Never commit secrets or junk.** Skip `.env`, credentials, keys, build output, logs (`dev.log`), coverage, `node_modules`, editor cruft, and stray scratch files. If something like that is untracked and looks accidental, leave it and mention it; if it is tracked and clearly shouldn't be, flag it instead of quietly committing.
- **Untracked files** that the session created *should* be added — don't skip a new source file just because it's untracked.
- If you are on the repo's default branch (`master`/`main`), point that out in your summary. Don't silently switch branches; only create one if the user asks.
- If pre-commit hooks reject the commit, read the output, fix the issue, re-stage, and retry. Don't use `--no-verify` unless the user asks.
