# AGENTS.md - Dagger CI Verification Loop Protocol

## Goal
Run `make lint`, `make build`, `make test` and keep them green. These three
commands are a MANDATORY GATE that must pass before every `git commit` and
`git push`. If any of them fails, fix the root cause and re-run the loop until
all three pass. Never commit or push while the gate is red.

## Loop Protocol (READ to PLAN to BUILD to RUN to TEST to VERIFY to CHECK to DECIDE)

### READ
- Read current `.github/workflows/ci.yml`
- Read current `ci/src/obsidian_reminder/main.py`
- Read current `Makefile`
- Read `CLAUDE.md` for command documentation

### PLAN
1. If `make lint` fails: Check Dagger SDK lint function exists and uses `node:21` (not slim)
2. If `make build` fails: Check Dagger SDK build function uses `node:21` and includes package-lock.json
3. If `make test` fails: Check Dagger SDK test function and npm install works
4. If CI workflow fails: Check it installs Dagger SDK via uv before running dagger commands

### BUILD
- Modify `ci/src/obsidian_reminder/main.py` if needed
- Modify `.github/workflows/ci.yml` if needed
- Modify `Makefile` if needed

### RUN  (this is the gate - all three must exit 0)
Run the Dagger pipeline targets. These are the canonical CI commands and the
authoritative gate:
make lint
make build
make test
If the Dagger engine or Docker daemon is not available locally (e.g. this
sandbox, or a runner that does not expose Docker), use the equivalent npm
scripts as the LOCAL VERIFICATION PROXY. They run the exact same underlying
commands the Dagger functions invoke, so a green npm run proves the source is
clean:
npm run lint && npm run build && npm run test -- --no-coverage
NOTE: a slow Dagger startup can time out locally (less than 60s) without the
command actually failing. A timeout is NOT a failure - if the npm proxy is
green, accept it and let CI validate. A genuine failure (non-zero exit) MUST be
fixed and re-run before any commit/push.

### TEST
- Run the commands from RUN.
- All three must finish with exit code 0.
- A non-zero exit = failure, go back to PLAN/BUILD and fix.

### VERIFY
- `make lint` (or `npm run lint`) -> 0 errors
- `make build` (or `npm run build`) -> completes successfully
- `make test` (or `npm run test`) -> all 310 tests pass
- If any of the above is not satisfied, the gate is RED - do not proceed.

### CHECK
- Local npm proxy green plus Dagger timed out -> source is correct; push and let CI validate.
- Local npm proxy green and Dagger runs green -> source is correct.
- Any real failure -> identify and fix the root cause, then re-run RUN to TEST to VERIFY.

### DECIDE  (commit and push ONLY when the gate is green)
MANDATORY: do NOT `git commit` or `git push` unless all three commands
passed (exit 0) in the RUN/VERIFY step.

git add -A && git commit -m "<type>: <description> - gate green (lint/build/test)" && git push origin merge-uphy-master

- If the gate is RED: return to PLAN/BUILD, fix the root cause, re-run
  RUN to TEST to VERIFY until all three pass. Only then commit and push.
- If 3 consecutive gate failures with no progress -> stop and report to the user.
  Never commit or push a failing state.

## Error Matrix

| Symptom | Cause | Fix |
|---------|-------|-----|
| npm ERR code ENOENT syscall spawn git | node:21-slim lacks git | Use node:21 instead |
| npm ERR code EUSAGE npm ci fails | package-lock.json not mounted | Use npm install --legacy-peer-deps |
| Dagger timeout (more than 60s) | Local environment slow | Accept local npm pass plus push to CI |

## Loop State
- MAX_ATTEMPTS: 3
- Current attempt: 0
