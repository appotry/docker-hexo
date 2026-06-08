[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# bloodstar/hexo

**Hexo blog environment Docker image** — zero-config, no need to install Node.js / npm / Hexo locally.

Source repository: [github.com/appotry/docker-hexo](https://github.com/appotry/docker-hexo) — issues, PRs, docs, multi-language README

---

## Quick Start

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

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HEXO_SERVER_PORT` | `4000` | Hexo server listening port |
| `GIT_USER` | — | Git global username |
| `GIT_EMAIL` | — | Git global email |

## SSH Keys

SSH keys are auto-generated at `/app/.ssh` on first start. Add the public key to GitHub for deployment.

```bash
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub SSH key tutorial](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## User Customization

### userRun.sh

Create `/app/userRun.sh` in your blog volume to run custom commands on container startup.

```bash
#!/bin/bash
cnpm install --save hexo-generator-search hexo-related-popular-posts
```

### requirements.txt

Add a `requirements.txt` file to your blog volume (one npm package per line). Packages auto-install on startup:

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
| New post | `docker exec hexo hexo new post "My Title"` |
| New page | `docker exec hexo hexo new page "music"` |
| Clean cache | `docker exec hexo hexo clean` |

## Documentation

| Document | Description | Link |
|----------|-------------|------|
| English README | Full English documentation | [README.en.md](https://github.com/appotry/docker-hexo/blob/master/README.en.md) |
| 中文文档 | 完整中文说明 | [README.md](https://github.com/appotry/docker-hexo/blob/master/README.md) |
| 繁體中文 | 完整繁體中文說明 | [README.zh-TW.md](https://github.com/appotry/docker-hexo/blob/master/README.zh-TW.md) |
| 日本語 | 日本語ドキュメント | [README.ja.md](https://github.com/appotry/docker-hexo/blob/master/README.ja.md) |
| 한국어 | 한국어 문서 | [README.ko.md](https://github.com/appotry/docker-hexo/blob/master/README.ko.md) |
| Architecture | Components & data flow | [docs/ARCHITECTURE.md](https://github.com/appotry/docker-hexo/blob/master/docs/ARCHITECTURE.md) |
| Requirements | Functional & non-functional | [docs/REQUIREMENTS.md](https://github.com/appotry/docker-hexo/blob/master/docs/REQUIREMENTS.md) |
| Testing | Test strategy & verification | [docs/TESTING.md](https://github.com/appotry/docker-hexo/blob/master/docs/TESTING.md) |
| Changelog | Version history | [docs/CHANGELOG.md](https://github.com/appotry/docker-hexo/blob/master/docs/CHANGELOG.md) |

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable build |
| `node20` | Latest build based on Node.js 20 |
| `{hexo-ver}-node20` | Specific hexo + node version (e.g. `7.3.0-node20`) |

## Resources

- [GitHub Repository](https://github.com/appotry/docker-hexo) — source code, issues, PRs
- [Multi-language README](https://github.com/appotry/docker-hexo#readme) — 11 languages supported
- [Hexo Documentation](https://hexo.io/docs/)
- Upstream project: [spurin/docker-hexo](https://github.com/spurin/docker-hexo)
