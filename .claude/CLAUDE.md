# Global Claude Instructions

## Reference Repository: smallhillcz/skeletons

When implementing new features, always consult the reference repository at **https://github.com/smallhillcz/skeletons** for patterns and conventions. Match code structure and style.

Inside devcontainers, the repo is typically already cloned at `/workspaces/smallhill/skeletons`. Prefer reading from there over fetching from GitHub.

The repo contains these skeletons:
- `nestjs/` — NestJS application skeleton
- `sdk/` — SDK skeleton
- `github/` — GitHub Actions / CI workflows
- `Dockerfile` — base Dockerfile pattern

When implementing anything that overlaps with these areas, read the relevant skeleton files first and follow the same patterns.

## Updating the Reference Repository

When explicitly told to update the skeletons repository:

1. If `/workspaces/smallhill/skeletons` exists and is the right repo, work there directly.
2. Otherwise clone it: `git clone https://github.com/smallhillcz/skeletons /workspaces/tmp/skeletons`
3. Make the requested changes.
4. Commit and push freely — no need to ask for confirmation.
