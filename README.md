[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Hexo 博客环境的 Docker 镜像** — 开箱即用，无需安装 Node.js / npm / Hexo。

镜像发布到 Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

[English](./README.en.md) · [简体中文](./README.md) · [繁體中文](./README.zh-TW.md) · [日本語](./README.ja.md) · [한국어](./README.ko.md)
[Español](./README.es.md) · [Français](./README.fr.md) · [Deutsch](./README.de.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [العربية](./README.ar.md)

> 为什么推荐每个人都自建一个独立博客网站？
> - 一个自我展示的名片！
> - 最大的言论自由，不被任何外人以及公司审查删帖封号！

---

## 快速开始

### 使用 docker CLI

```bash
docker create --name=hexo \
  -e HEXO_SERVER_PORT=4000 \
  -e GIT_USER="yourname" \
  -e GIT_EMAIL="you@example.com" \
  -v /path/to/blog:/app \
  -p 4000:4000 \
  bloodstar/hexo

docker start hexo
```

首次启动时，若 `/app` 为空，容器会自动执行 `hexo init` 初始化博客并安装常用插件。

### 使用 docker compose

```yaml
services:
  hexo:
    container_name: hexo
    image: bloodstar/hexo:latest
    hostname: hexo
    ports:
      - "7800:4000"
    volumes:
      - /path/to/blog:/app
    environment:
      - HEXO_SERVER_PORT=4000
      - GIT_USER=yourname
      - GIT_EMAIL=you@example.com
      - TZ=Asia/Shanghai
    restart: always
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `HEXO_SERVER_PORT` | `4000` | Hexo 服务器监听端口 |
| `GIT_USER` | — | Git 全局用户名 |
| `GIT_EMAIL` | — | Git 全局邮箱 |

## SSH 密钥

**Docker 会自动随机生成 SSH 密钥** 在 `/app/.ssh` 目录下面。自动部署请把 SSH Key 添加到 GitHub 等平台。

```bash
# 查看公钥
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub 添加 SSH Key 详细教程](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## 进入 Docker

```bash
docker exec -it hexo bash
```

进入容器后，就可以正常运行 hexo 的各种命令了。

## 配置主题

不同人的审美不一样，喜欢不同的主题，这里推荐几个主题：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

下载好主题后，按照不同主题的使用说明，配置对应的配置文件，然后编译项目 `hexo g`，编译完之后，就可以通过浏览器访问 `http://[docker IP]:4000` 看到网页了。

```bash
cd /app
git clone https://github.com/用户名/hexo-theme-xxx.git themes/xxx
```

编辑 `/app/_config.yml`，修改 `theme: xxx`，然后 `hexo g` 重新生成。

## 用户自动运行脚本

用户可以在这里添加自动配置、自动安装插件等启动 Docker 时运行的命令。

编辑 `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# 快速添加登录github秘钥
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# 重启内部pm2 服务器
alias repm2='pm2 restart /hexo_run.js'

#### debian 中国区加速
# 如果网络速度快，可以注释
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm 配置
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### history 持久化
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh 配置
#### 避免 "Are you sure you want to continue connecting (yes/no)? yes"
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm 插件安装
# 这里用户可以修改自定义安装
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

如果网络访问不顺利，可在访问网络之前添加代理：

```bash
# 命令行使用代理的方法
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# 使用docker host name 来访问代理，不用IP。更推荐这种方式，使用 docker 内部的 dns 寻找目标
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

在博客卷中添加 `requirements.txt`，每行一个 npm 包名，启动时自动安装：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## 常用命令

| 操作 | 命令 |
|------|------|
| 进入容器 | `docker exec -it hexo bash` |
| 查看日志 | `docker logs --follow hexo` |
| 重启 pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| 重启容器 | `docker restart hexo` |
| 生成静态文件 | `docker exec hexo hexo g` |
| 部署到远程 | `docker exec hexo hexo d` |
| 新建文章 | `docker exec hexo hexo new post "文章标题"` |
| 新建页面 | `docker exec hexo hexo new page "music"` |
| 清理缓存 | `docker exec hexo hexo clean` |

## 快捷别名

在宿主机 `~/.bashrc` 或 `~/.zshrc` 中添加以下别名，可直接运行 hexo 命令而无需先 `docker exec`：

```bash
# hexo 容器快捷操作
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "标题"
# hexo g
# hexo d
# hexo clean
```

添加后执行 `source ~/.bashrc` 生效，之后可直接使用：

```bash
hexo new post "我的新文章"
hexo g
hexo d
hexo-shell
```

## 实时预览修改

Hexo 支持实时预览修改效果，文章主题的修改，都可以通过 Web 服务立刻看到效果。

如果你发现了修改没有立刻生效，可能是 node 缓存还在，可以使用下面方法重启 Web 服务：

```bash
# 重启 pm2
pm2 restart /hexo_run.js

# 重启 hexo docker
docker restart hexo
```

## 完整使用教程

- [Hexo Docker环境与Hexo基础配置篇](https://blog.17lai.site/posts/40300608/)
- [hexo博客自定义修改篇](https://blog.17lai.site/posts/4d8a0b22/)
- [hexo博客网络优化篇](https://blog.17lai.site/posts/9b056c86/)
- [hexo博客增强部署篇](https://blog.17lai.site/posts/5311b619/)
- [hexo博客个性定制篇](https://blog.17lai.site/posts/4a2050e2/)
- [hexo博客常见问题篇](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown以及各种插件功能测试](https://blog.17lai.site/posts/cf0f47fd/)
- [hexo博客博文撰写篇之完美笔记大攻略终极完全版](https://blog.17lai.site/posts/253706ff/)
- [在 Hexo 博客中插入 ECharts 动态图表](https://blog.17lai.site/posts/217ccdc1/)
- [使用nodeppt给hexo博客嵌入PPT演示](https://blog.17lai.site/posts/546887ac/)
- [Vercel部署高级用法教程](https://blog.17lai.site/posts/e922fac8/)
- [Hexo中文文档](https://hexo.io/zh-cn/docs/)
- [HexoAPI](https://hexo.io/zh-cn/api/)
- [Hexo插件](https://hexo.io/plugins/)

## 文档导航

| 文档 | 内容 |
|------|------|
| [AGENTS.md](./AGENTS.md) | AI 工作约定、命令、工程化规范 |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | 架构说明、组件关系、数据流 |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | 功能与非功能需求 |
| [docs/TESTING.md](./docs/TESTING.md) | 测试策略、Docker 构建验证方法 |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | 版本变更历史 |

## 相关资源

- [Hexo 官方文档](https://hexo.io/zh-cn/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- 上游项目：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
