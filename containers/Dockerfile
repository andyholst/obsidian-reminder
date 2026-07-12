# Build/test/lint image for obsidian-reminder.
# Replaces the previous Dagger-based CI pipeline. Runs npm install + the
# project scripts inside a pinned node:22 container (with git installed,
# required by the @codemirror/stream-parser github dependency).
FROM node:22

# The electron package is only needed for its TypeScript types; skip the
# ~100MB binary download. electron's install.js only honors this bare env var.
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1

# Project sources are bind-mounted into /workspace at compose runtime.
WORKDIR /workspace

# Default command: shell so `docker compose run <svc> <args>` works.
CMD ["sh"]