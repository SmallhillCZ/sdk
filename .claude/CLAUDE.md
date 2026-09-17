# Global Claude Instructions

## General rules

* Do not put any explanatory comments in the code
* If memory of some code needs to be preserved for future sessions, save to CLAUDE.md in that repository. Keep CLAUDE.md small and compact it after edits.

## Reference Repository: smallhillcz/skeletons

When implementing new features, like backend, frontend etc., always consult the reference repository at **https://github.com/smallhillcz/skeletons**.

If feature is implemented as a top level item in this directory, copy it and after copying change what is needed (like package names).

If smallhillcz/skeletons repo is in the current workspace, use it, but be sure to pull changes from the remote before using it.

After adding a feature from skeletons repo, commit the changes with a message like "feat: add <feature> from skeletons repo <repo url>" with skull gitmoji.

## Contributing Back to the Reference Repository

If a feature is not found in the skeletons repo and it is a major standalone feature (a backend, frontend, CLI, library, infrastructure setup or similar reusable top level item), add its implementation to the skeletons repo:

1. Implement the feature in the current repository first.
2. Port it to the skeletons repo as a top level item, stripped of anything project specific (package names, domains, secrets, business logic) so it works as a generic starting point.
3. Follow the steps in "Updating the Reference Repository" to clone or pull, commit and push.

Do not port small changes, bug fixes or project specific logic.

## Updating the Reference Repository

When explicitly told to update the skeletons repository:

1. If needed clone it to a temp folder and update it there. If it is already cloned in the workspace, pull the latest changes from the remote before editing.
2. Make the requested changes.
3. Commit and push freely — no need to ask for confirmation.
