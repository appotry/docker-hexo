# docker-hexo

[Hexo](https://hexo.io/) 博客环境的 Docker 镜像，发布到 Docker Hub `bloodstar/hexo`。

## 命令

| 操作 | 命令 |
|------|------|
| 构建镜像 | `docker build -t bloodstar/hexo .` |
| 创建容器 | `docker create --name=hexo -e HEXO_SERVER_PORT=4000 -e GIT_USER="name" -e GIT_EMAIL="email" -v /path/to/blog:/app -p 4000:4000 bloodstar/hexo` |
| 进入容器 | `docker exec -it hexo bash` |
| 查看日志 | `docker logs --follow hexo` |
| 重启 pm2 | `pm2 restart /hexo_run.js`（容器内） |
| 重启容器 | `docker restart hexo` |

## 项目结构

```
├── Dockerfile              # 构建 node:20-slim 基础镜像
├── entrypoint.sh           # 容器入口：初始化博客、SSH密钥、启动pm2
├── hexo_run.js             # pm2 管理的 Hexo 服务进程
├── userRun.sh              # 用户自定义启动脚本（可被挂载覆盖）
├── renovate.json           # Renovate 自动依赖更新
├── .github/
│   ├── workflows/
│   │   └── Build Image.yml # CI：多架构构建并推送 Docker Hub
│   └── dependabot.yml      # Docker 依赖每日扫描
```

## 关键细节

- **基础镜像**：本地 `node:20-slim`，远程 `origin/master` 已升级到 `node:26-slim` — 两个分支已分叉。
- **入口流程**：`entrypoint.sh` → 若 `/app` 为空则 `hexo init` → 安装插件和 `requirements.txt` → 生成 SSH 密钥 → 配置 Git → 执行 `userRun.sh` → `pm2 start /hexo_run.js` → `pm2 logs`。
- **包管理器**：所有 npm 操作使用 **cnpm**（淘宝 npm 镜像），非 npm。
- **用户定制**：编辑 `/app/userRun.sh` 添加启动命令，或在博客卷中添加 `requirements.txt` 安装插件。
- **环境变量**：`HEXO_SERVER_PORT`（默认 4000）、`GIT_USER`、`GIT_EMAIL`。

## CI / Docker

- **CI 触发**：`main`/`master` 推送、Release 发布、Star 事件、每月 1 号定时、手动调度
- **多架构构建**：`linux/amd64,linux/arm64`（QEMU + Buildx）
- **镜像标签**：`bloodstar/hexo:latest`、`bloodstar/hexo:node20`、`bloodstar/hexo:{hexo-ver}-node20`（例：`7.3.0-node20`）
- **所需 Secret**：`DOCKER_USERNAME`、`DOCKER_PASSWORD`
- **Renovate**：`renovate.json` 启用 base 配置自动更新
- **Dependabot**：每日扫描 Docker 依赖（`.github/dependabot.yml`）
- **Stale**：自动标记 60 天无活动 Issue/PR（`.github/workflows/stale.yml`）
- **Labeler**：根据文件路径自动为 PR 打标签（`.github/workflows/label.yml`）
- **Greetings**：首次贡献者自动欢迎（`.github/workflows/greetings.yml`）

## 工程化约定

### Git 提交

```
[emoji] type(scope): 简短描述（50 字以内）
```

| type | emoji | 用途 |
|------|-------|------|
| feat | ✨ | 新功能 |
| fix | 🐛 | Bug 修复 |
| docs | 📖 | 文档变更 |
| chore | 🔧 | 构建/工具/依赖 |
| ci | 🔧 | CI/CD 配置 |
| refactor | ♻️ | 代码重构 |
| perf | ⚡ | 性能优化 |
| test | 🧪 | 测试相关 |
| style | 🎨 | 代码格式 |

原则：小提交，每提交只做一件事。

### 分支命名

| 分支类型 | 命名格式 | 说明 |
|---------|---------|------|
| master | `master` / `main` | 生产分支，永久 |
| develop | `develop` | 开发分支，永久 |
| feature | `feature/<name>` | 功能分支，从 develop 创建，合回 develop 后删除 |
| release | `release/<version>` | 发布分支，从 develop 创建，合到 master+develop 后删除 |
| hotfix | `hotfix/<version>` | 紧急修复，从 master tag 创建，合到 master+develop 后删除 |

### 编码规范

- 缩进：2 空格
- 编码：UTF-8
- Shell 脚本：bash，使用 `set -e` 确保错误退出
- 交流使用中文

## 文档导航

| 文档 | 内容 |
|------|------|
| `README.md` | 项目简介、快速开始、环境变量说明（简体中文） |
| `README.en.md` | Project introduction, quick start, environment variables (English) |
| `README.zh-TW.md` | 專案簡介、快速開始、環境變數說明（繁體中文） |
| `README.ja.md` | プロジェクト概要、クイックスタート、環境変数（日本語） |
| `README.ko.md` | 프로젝트 소개, 빠른 시작, 환경 변수 (한국어) |
| `README.es.md` | Introducción, inicio rápido, variables de entorno (Español) |
| `README.fr.md` | Présentation, démarrage rapide, variables d'environnement (Français) |
| `README.de.md` | Projektübersicht, Schnellstart, Umgebungsvariablen (Deutsch) |
| `README.pt.md` | Introdução, início rápido, variáveis de ambiente (Português) |
| `README.ru.md` | Описание, быстрый старт, переменные окружения (Русский) |
| `README.ar.md` | مقدمة، بداية سريعة، متغيرات البيئة (العربية) |
| `docs/ARCHITECTURE.md` | 架构说明、组件关系、数据流 |
| `docs/REQUIREMENTS.md` | 需求说明、功能与非功能需求 |
| `docs/TESTING.md` | 测试策略、Docker 构建验证方法 |
| `docs/CHANGELOG.md` | 版本变更历史 |
| `DOCKER_README.md` | Docker Hub 专用 README（全 GitHub 域名引用） |

## 经验知识库

共享路径：`~/Work/dev-experience/`

本项目标签：`docker`, `static-site`, `ci-cd`, `automation`

相关经验：
- `04-documentation/07-docker-image-doc-architecture.md` — Docker 镜像项目工程化文档体系搭建（v1.0.0）
- `04-documentation/08-docker-hub-readme-spec.md` — Docker Hub README 文档规范（v1.0.0）
- `05-ci-cd/02-docker-multi-stage.md` — Docker 标签与构建策略（v1.0.0）
- `99-general/14-docker-standards.md` — Dockerfile 编码规范（v1.0.0）
- `99-general/07-documentation-writing-standards.md` — Hexo 兼容的 LaTeX/Mermaid 语法（v1.0.0）
- `03-git-workflow/04-enhanced-commit-convention.md` — Emoji 提交规范（v1.0.0）
