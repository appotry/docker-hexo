# 架构说明

## 总体概览

docker-hexo 是一个单阶段 Docker 镜像，将 Hexo 博客环境、依赖工具链、进程管理打包为开箱即用的容器。

## 组件关系

```
Dockerfile (node:20-slim)
├── 系统层: git, openssh, gh, locales, build-essential
├── Node 层: pm2, hexo-cli, cnpm, nrm, gulp
└── 应用层: entrypoint.sh, hexo_run.js, userRun.sh
         ↓
entrypoint.sh (容器入口)
├── 初始化 hexo 博客（若 /app 为空）
├── 安装 requirements.txt 插件
├── 生成 SSH 密钥（若 /app/.ssh 为空）
├── 配置 Git 全局用户
├── 执行 /app/userRun.sh（用户自定义脚本）
└── pm2 start /hexo_run.js
         ↓
hexo_run.js (pm2 管理)
└── child_process.exec → hexo server -p ${HEXO_SERVER_PORT}
```

## 数据流

```
宿主机卷 (/path/to/blog)  ←→  容器 /app/
                                     │
                             entrypoint.sh 检查 /app 内容
                                     │
                             空 → hexo init + cnpm install
                             有 → 跳过初始化
                                     │
                             执行 userRun.sh（若存在）
                                     │
                             pm2 → hexo server → HTTP :4000
```

## 关键设计决策

| 决策 | 说明 |
|------|------|
| 单阶段构建 | 保持简单，Hexo 运行本身需要全部依赖，多阶段无收益 |
| cnpm 包管理器 | 淘宝 npm 镜像，中国区加速，替代 npm |
| pm2 进程管理 | 保持 hexo server 稳定运行，支持优雅重启 |
| 无 USER 指令 | 默认 root 运行（entrypoint 需 root 权限做 SSH 密钥生成、Git 配置、apt 操作等），用户可通过 userRun.sh 自定义 |
| HEALTHCHECK | 每 30 秒检查 hexo server HTTP 200，30 秒启动宽限，3 次失败认定不健康 |

## 构建与部署

详见 `TESTING.md` 和 CI 工作流 `.github/workflows/Build Image.yml`。
