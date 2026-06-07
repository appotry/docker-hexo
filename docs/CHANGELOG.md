# 变更日志

## [unreleased]

### docs
- 新增 AGENTS.md，统一工程化约定与命令入口
- 新增 docs/ARCHITECTURE.md 架构说明
- 新增 docs/REQUIREMENTS.md 需求文档
- 新增 docs/TESTING.md 测试策略
- 新增 docs/CHANGELOG.md 变更日志
- 新增 tests/docker_test.sh 自动化验证脚本

## [2026-06-07]

### ci
- 更新 docker/build-push-action 到 v7
- 更新 docker/setup-buildx-action 到 v4
- 更新 docker/setup-qemu-action 到 v4
- 更新 docker/login-action 到 v4
- 更新 actions/checkout 到 v6

### chore
- 本地 Dockerfile 回退到 node:20-slim（远程 master 已升级到 26-slim）
- 移除不支持的构建平台

## [2026-05-xx]

### ci
- 启用 Renovate 自动依赖更新
- 添加 Dependabot Docker 依赖每日扫描
