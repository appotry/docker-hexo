[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Docker image for Hexo blog environment** — zero-config, no need to install Node.js / npm / Hexo locally.

Published on Docker Hub: [bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> Why build your own independent blog?
> - A personal showcase!
> - Full freedom of speech, no censorship by outsiders or companies.

---

## Quick Start

### Using docker CLI

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

On first start, if `/app` is empty, the container automatically runs `hexo init` and installs common plugins.

### Using docker compose

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

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HEXO_SERVER_PORT` | `4000` | Hexo server listening port |
| `GIT_USER` | — | Git global username |
| `GIT_EMAIL` | — | Git global email |

## SSH Keys

**Docker automatically generates SSH keys** in `/app/.ssh`. Add the public key to GitHub or other platforms for deployment.

```bash
# View public key
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub SSH key tutorial](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Enter Docker

```bash
docker exec -it hexo bash
```

Enter the container to run any hexo commands.

## Theme Configuration

Everyone has different tastes. Here are some recommended themes:

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

After downloading a theme, configure it as instructed, then run `hexo g` to generate. Visit `http://[docker IP]:4000` to see your site.

```bash
cd /app
git clone https://github.com/user/hexo-theme-xxx.git themes/xxx
```

Edit `/app/_config.yml`, set `theme: xxx`, then run `hexo g` to regenerate.

## User Custom Script

Add auto-configuration and auto-plugin installation commands that run when Docker starts.

Edit `/app/userRun.sh`:

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Quick GitHub login alias
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Restart internal pm2 server
alias repm2='pm2 restart /hexo_run.js'

#### Debian China mirror (comment if your network is fast)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm config
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### history persistence
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh config
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm plugin installation
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

If network access is slow, set up a proxy before network requests:

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Using docker hostname for proxy (recommended)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Add a `requirements.txt` file to your blog volume (one npm package per line). Packages are auto-installed on startup:

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Common Commands

| Action | Command |
|--------|---------|
| Enter container | `docker exec -it hexo bash` |
| View logs | `docker logs --follow hexo` |
| Restart pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| Restart container | `docker restart hexo` |
| Generate static files | `docker exec hexo hexo g` |
| Deploy to remote | `docker exec hexo hexo d` |
| New post | `docker exec hexo hexo new post "Post Title"` |
| New page | `docker exec hexo hexo new page "music"` |
| Clean cache | `docker exec hexo hexo clean` |

## Quick Aliases

Add these to your `~/.bashrc` or `~/.zshrc` to run hexo commands without typing `docker exec` every time:

```bash
# hexo container shortcuts
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "My Title"
# hexo g
# hexo d
# hexo clean
```

Run `source ~/.bashrc` to activate, then use directly:

```bash
hexo new post "My New Post"
hexo g
hexo d
hexo-shell
```

## Live Preview

Hexo supports live reload on file changes. After editing a post or theme, simply refresh the browser.

If changes don't take effect, the node cache may be stale. Restart the web service:

```bash
# Restart pm2
pm2 restart /hexo_run.js

# Restart hexo docker
docker restart hexo
```

## Full Tutorials

- [Hexo Docker Environment & Basic Configuration](https://blog.17lai.site/posts/40300608/)
- [Hexo Blog Customization](https://blog.17lai.site/posts/4d8a0b22/)
- [Hexo Blog Network Optimization](https://blog.17lai.site/posts/9b056c86/)
- [Hexo Blog Deployment Guide](https://blog.17lai.site/posts/5311b619/)
- [Hexo Blog Personalization](https://blog.17lai.site/posts/4a2050e2/)
- [Hexo Blog FAQ](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown & Plugin Testing](https://blog.17lai.site/posts/cf0f47fd/)
- [Hexo Blog Post Writing Guide](https://blog.17lai.site/posts/253706ff/)
- [Embed ECharts Charts in Hexo](https://blog.17lai.site/posts/217ccdc1/)
- [Embed PPT in Hexo with nodeppt](https://blog.17lai.site/posts/546887ac/)
- [Vercel Advanced Deployment](https://blog.17lai.site/posts/e922fac8/)
- [Hexo Documentation](https://hexo.io/docs/)
- [Hexo API](https://hexo.io/api/)
- [Hexo Plugins](https://hexo.io/plugins/)

## Documentation

| Document | Description |
|----------|-------------|
| [AGENTS.md](./AGENTS.md) | AI conventions, commands, engineering standards |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Architecture, components, data flow |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Functional and non-functional requirements |
| [docs/TESTING.md](./docs/TESTING.md) | Test strategy, Docker build verification |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | Version history |

## Resources

- [Hexo Documentation](https://hexo.io/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Upstream project: [spurin/docker-hexo](https://github.com/spurin/docker-hexo)
