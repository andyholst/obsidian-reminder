# Docker-based verification gate (replaces the old Dagger pipeline).
# make lint|build|test run the equivalent npm scripts inside the pinned
# node:22 container defined in containers/Dockerfile. node_modules is
# bind-mounted from the host so deps persist across runs, and the npm
# registry cache lives in a named volume.
#
# NOTE: the local nerdctl `compose run` injects --tty and fails with
# "provided file is not a console" when no real terminal is attached, so each
# run is wrapped in `script -qec` to allocate a pseudo-TTY.

COMPOSE := docker compose -f container-compose/docker-compose.yml

# Run a compose service non-interactively with a pseudo-TTY.
# `run --build` builds (or rebuilds, if the Dockerfile changed) ONLY the
# service's own image on demand instead of every image in the file.
# Usage: $(call run-service,NAME)
define run-service
	script -qec "$(COMPOSE) run --build --rm $1"
endef

# Build a single service image on demand (idempotent - Compose skips already
# built layers). Building the named service only, not all four, avoids the
# ~40s waste of re-exporting every image on every `make` invocation.
.PHONY: lint build test

lint:
	$(call run-service,lint)

build:
	$(call run-service,build)

test:
	$(call run-service,test)