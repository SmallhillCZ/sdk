---
name: preview
description: Launch the current app with all its dependencies (database, backend, frontend, queues, etc.) in the background and return the URL where it can be opened. Use when the user says "/preview" or asks to start/launch a preview of the app.
---

# Preview

Start the whole app locally, leave it running in the background, and give the user the URL.

## Output contract

The user sees **exactly two lines** and nothing else:

1. Before doing any work: `Starting preview...`
2. When the app responds: `Preview started at <URL>`

No explanations, no command echoes, no summaries, no lists of started services, no follow-up offers. Do all investigation silently through tool calls. Keep Bash `description` fields terse.

If the preview cannot be started, replace line 2 with a single line: `Preview failed: <one-sentence reason>`.

If a preview from this session is already running and responding, skip straight to line 2 with its URL.

## Procedure

1. **Find the launch recipe**, first match wins:
   - a project skill or `CLAUDE.md` / `README.md` section describing how to run the app locally
   - `docker-compose*.yml` / `compose*.yml` (root or `docker/`, `.devcontainer/`)
   - root `package.json` scripts such as `dev`, `start:dev`, `start`, `serve`, plus workspace packages (`backend/`, `frontend/`, `apps/*`, `packages/*`)
   - `Makefile` / `justfile` / `Taskfile` targets like `dev`, `run`, `up`
   - language defaults (`manage.py runserver`, `uvicorn`, `go run`, `cargo run`, `dotnet run`, ...)

2. **Install what is missing.** If dependencies are not installed (`node_modules` absent, no venv, ...), install them with the project's package manager using the lockfile (`npm ci`, `pnpm i --frozen-lockfile`, `yarn --immutable`, `pip install -r ...`). Copy `.env.example` / `.env.sample` to `.env` only if `.env` does not exist.

3. **Start infrastructure dependencies first** (database, cache, message broker, object storage):
   - with compose: `docker compose up -d <infra services>` (or the whole stack if the app itself is containerised)
   - without Docker available: use locally installed services (`service postgresql start`, `redis-server --daemonize yes`, ...), or the project's in-memory / sqlite fallback if it has one
   - wait until each is accepting connections (`pg_isready`, `redis-cli ping`, compose healthchecks, port probe)

4. **Prepare data** when the project expects it: run pending migrations and seeds using the project's own scripts (e.g. `migration:run`, `db:migrate`, `prisma migrate deploy`, `manage.py migrate`).

5. **Start the app processes** (backend, then frontend, plus workers if needed):
   - run each long-lived process in the background (Bash `run_in_background`, or `nohup ... > <scratchpad>/preview-<name>.log 2>&1 &`) so it survives the turn
   - never run them in the foreground, never use `watch`-less blocking commands
   - reuse ports from config; if a port is taken by something that is not this app, pick the next free port and pass it via the project's env var or flag

6. **Wait for readiness.** Poll the entry URL with `curl -s -o /dev/null -w '%{http_code}'` until it returns a non-5xx status (up to ~3 minutes). If a process exits or stays unhealthy, read its log, fix obvious causes (missing env var, missing dependency, port clash) and retry once.

7. **Pick the local entry point** the user should open: the frontend if there is one, otherwise the backend root or its docs page (e.g. `/api`, `/docs`, `/swagger`). The tunnel exposes a single port, so the frontend must reach the backend through relative URLs / its dev-server proxy, not `http://localhost:<backend port>`; start the frontend with its proxy config if it has one.

8. **Expose it with a Cloudflare quick tunnel** so the URL works from outside the machine:
   - if `cloudflared` is not on `PATH`, download the static binary for the current arch from `https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-<amd64|arm64>` (or `brew install cloudflared` on macOS) into `~/.local/bin` and `chmod +x` it
   - run in the background: `cloudflared tunnel --no-autoupdate --url http://localhost:<port> > <scratchpad>/preview-tunnel.log 2>&1 &`
   - read the public URL from the log: `grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' <log> | head -1` (poll up to ~30 s), then poll that URL until it returns a non-5xx status
   - dev servers reject unknown `Host` headers; allow the tunnel host via flags or env, never by editing tracked config: Angular `ng serve --host 0.0.0.0 --allowed-hosts .trycloudflare.com` (older: `--disable-host-check`), Vite `__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS=.trycloudflare.com`, webpack-dev-server `--allowed-hosts all`
   - every run gets a new random `*.trycloudflare.com` URL, independent per session; no account is needed
   - quick tunnels are for testing only: they cap concurrent requests and do not support Server-Sent Events, so SSE streaming may misbehave
   - if the tunnel cannot be started (no network, download blocked), fall back to a forwarded URL the environment exposes (e.g. Codespaces `https://$CODESPACE_NAME-<port>.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`), otherwise `http://localhost:<port>`

9. Print line 2 and end the turn. Do not stop the started processes.

## Rules

- Never modify tracked source files to make the preview start. Generated or ignored files (`.env`, build output, local DB data) are fine.
- Never commit anything.
- Remember the started processes (including the tunnel), ports, tunnel URL and log paths for the rest of the session so a later "stop the preview" or `/preview` can reuse or stop them.
