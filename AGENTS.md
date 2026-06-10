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

- **CI 触发**：`main`/`master` 推送（Dependabot 合并 PR 时触发）、手动调度
- **多架构构建**：`linux/amd64,linux/arm64`（QEMU + Buildx）
- **版本来源**：从 `package.json` 的 `dependencies.hexo` 读取，Dependabot 检测到 hexo 新版本自动发 PR
- **镜像标签**：`bloodstar/hexo:latest`、`bloodstar/hexo:node20`、`bloodstar/hexo:{hexo-ver}-node20`（例：`8.1.2-node20`）
- **所需 Secret**：`DOCKER_USERNAME`、`DOCKER_PASSWORD`
- **Renovate**：`renovate.json` 启用 base 配置自动更新
- **Dependabot**：npm + Docker 双生态每日扫描（`.github/dependabot.yml`）
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

## 编码纪律

> 以下四项核心纪律约束所有编码行为，AI 和人类开发者共同遵守。

### 1. 编程前先思考（Think Before Coding）

不要臆测，不要隐藏困惑，暴露权衡。在开始实现之前：
- **明确说明你的假设**。如果不确定，请提问。
- **如果存在多种解释**，请展示出来——不要默默选择其中一个。
- **如果存在更简单的方案**，请告知。在必要时提出质疑。
- **如果某些内容不清晰**，请停止。指出令人困惑的地方。提问。

### 2. 简约优先（Simplicity First）

以解决问题为目的的最简代码。不要任何推测性内容。
- 不要包含任何超出要求的额外功能。
- 不要为仅使用一次的代码编写抽象。
- 不要包含未要求的"灵活性"或"可配置性"。
- 不要为不可能发生的场景编写错误处理。
- 如果你写了 200 行代码但本可以只用 50 行，请重写。

**自问：** "资深工程师会觉得这太复杂了吗？"如果是，请简化。

### 3. 外科手术式的精准修改（Surgical Changes）

只修改必须修改的部分。只清理你自己的"烂摊子"。
- 不要"改进"相邻的代码、注释或格式。
- 不要重构没有损坏的部分。
- 遵循现有的风格，即使你会有不同的做法。
- 如果你注意到无关的废弃代码，请提出来——**不要删除它**。

当你的更改产生"孤儿"内容时：
- **删除**因为**你的修改**而变得不再使用的导入/变量/函数。
- 除非被要求，否则**不要删除**预先存在的废弃代码。

**测试标准**：每一行修改都应能直接追溯到用户的请求。

### 4. 目标驱动的执行（Goal-Driven Execution）

定义成功标准。循环直到验证通过。
- "添加验证" → "为无效输入编写测试，然后使它们通过"
- "修复 Bug" → "编写一个能复现该 Bug 的测试，然后使它通过"
- "重构 X" → "确保在重构前后的测试都通过"

对于多步骤任务，陈述一个简要计划：
`[步骤] → 验证：[检查]`
`[步骤] → 验证：[检查]`

**这些准则生效的标志是：**
1. Diff 中的不必要变动减少；
2. 由于过度复杂导致的重写次数减少；
3. 在出错之前，先提出澄清问题。

## 经验知识库

路径：`~/Work/dev-experience/`（[gateway skill](~/.agents/skills/dev-experience/SKILL.md) 自动加载）
本项目标签：`docker`, `static-site`, `ci-cd`, `automation`
