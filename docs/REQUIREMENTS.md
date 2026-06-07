# 需求说明

## 项目定位

提供开箱即用的 Hexo 博客 Docker 镜像，用户无需安装 Node.js、npm、Hexo 等依赖即可运行和管理博客。

## 功能需求

### F1：Hexo 博客环境
- 容器内预装 hexo-cli、git、ssh，支持所有 hexo 命令
- 容器启动时若挂载卷 `/app` 为空，自动执行 `hexo init` 初始化博客
- 默认安装常用 hexo 插件：admin、deployer-git、generator-feed、generator-sitemap、wordcount 等

### F2：包管理
- 使用 cnpm（淘宝镜像）加速中国区 npm 安装
- 支持通过 `/app/requirements.txt` 文件在启动时自动安装额外插件

### F3：用户自定义
- 支持通过 `/app/userRun.sh` 脚本在容器启动时执行自定义命令
- `/app/userRun.sh` 可被宿主机挂载覆盖，方便用户定制

### F4：SSH 密钥管理
- 首次启动时自动生成 SSH 密钥对
- 写入 github.com 和 gitlab.com 的 known_hosts
- 密钥持久化到 `/app/.ssh`，重启不丢失

### F5：Git 配置
- 通过环境变量 `GIT_USER`、`GIT_EMAIL` 配置 git 全局用户

### F6：进程管理
- 使用 pm2 管理 hexo server 进程，支持自动重启
- 通过环境变量 `HEXO_SERVER_PORT` 配置监听端口（默认 4000）

### F7：多架构支持
- 同时构建 linux/amd64 和 linux/arm64 架构镜像
- 通过 GitHub Actions 自动构建并推送到 Docker Hub

## 非功能需求

| 需求 | 说明 |
|------|------|
| 镜像体积 | 基于 node:20-slim，尽量精简 |
| 启动速度 | 首次启动（空卷）需初始化博客，后续启动秒级 |
| 易用性 | 一条命令创建容器，零配置启动 |
| 可观测性 | 启动日志输出关键步骤，pm2 提供进程状态查询 |
