# 变更日志

All notable changes to this project are documented in this file.

## [Unreleased]

### Fixed
- `hexo_run.js`: template literals now use backtick quotes; `${HEXO_SERVER_PORT}` correctly interpolates
- `entrypoint.sh`: add `set -e` per shell coding standard; move `pm2 start` after blog init to prevent race condition
- `entrypoint.sh`: remove redundant `cnpm config set registry` (already set in Dockerfile)

### Added
- `Dockerfile`: `HEALTHCHECK` for hexo server HTTP 200 monitoring

### Changed
- `docs/ARCHITECTURE.md`: document HEALTHCHECK and USER design decisions
- `AGENTS.md`: update entrypoint flow description, add new experience library references
- `docs/CHANGELOG.md`: restructured to Keep a Changelog format

## [0.1.0] - 2026-06-07

### Added
- `AGENTS.md`: unified engineering conventions and command entry
- `docs/ARCHITECTURE.md`: architecture documentation
- `docs/REQUIREMENTS.md`: requirements documentation
- `docs/TESTING.md`: test strategy documentation
- `docs/CHANGELOG.md`: changelog documentation
- `tests/docker_test.sh`: automated verification script

### Changed
- CI: update `docker/build-push-action` to v7
- CI: update `docker/setup-buildx-action` to v4
- CI: update `docker/setup-qemu-action` to v4
- CI: update `docker/login-action` to v4
- CI: update `actions/checkout` to v6
- Local Dockerfile reverted to `node:20-slim` (remote master uses `node:26-slim`)
- Removed unsupported build platforms

### Security
- Enable Renovate automatic dependency updates
- Add Dependabot daily Docker dependency scanning
