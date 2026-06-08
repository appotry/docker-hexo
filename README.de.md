[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Docker-Image für Hexo-Blog-Umgebungen** — Keine Installation von Node.js / npm / Hexo erforderlich, sofort einsatzbereit.

Veröffentlicht auf Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> Warum ein eigenes unabhängiges Blog erstellen?
> - Eine persönliche Visitenkarte!
> - Volle Meinungsfreiheit, ohne Zensur durch Außenstehende oder Unternehmen.

---

## Schnellstart

### Mit docker CLI

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

Beim ersten Start, wenn `/app` leer ist, führt der Container automatisch `hexo init` aus und installiert die gängigsten Plugins.

### Mit docker compose

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

## Umgebungsvariablen

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `HEXO_SERVER_PORT` | `4000` | Hexo-Server-Port |
| `GIT_USER` | — | Git-Benutzername (global) |
| `GIT_EMAIL` | — | Git-E-Mail (global) |

## SSH-Schlüssel

**Docker generiert automatisch SSH-Schlüssel** in `/app/.ssh`. Fügen Sie den öffentlichen Schlüssel zu GitHub oder anderen Plattformen für die Bereitstellung hinzu.

```bash
# Öffentlichen Schlüssel anzeigen
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub SSH-Schlüssel-Tutorial](https://docs.github.com/de/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Docker betreten

```bash
docker exec -it hexo bash
```

Betreten Sie den Container, um alle hexo-Befehle auszuführen.

## Theme-Konfiguration

Jeder hat einen anderen Geschmack. Hier sind einige empfohlene Themes：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

Nach dem Herunterladen eines Themes konfigurieren Sie es gemäß den Anweisungen und führen Sie `hexo g` aus. Besuchen Sie `http://[docker IP]:4000`, um Ihre Seite zu sehen.

```bash
cd /app
git clone https://github.com/benutzer/hexo-theme-xxx.git themes/xxx
```

Bearbeiten Sie `/app/_config.yml`, setzen Sie `theme: xxx`, dann führen Sie `hexo g` zum Neugenerieren aus.

## Benutzerdefiniertes Skript

Fügen Sie Auto-Konfigurations- und Auto-Plugin-Installationsbefehle hinzu, die beim Docker-Start ausgeführt werden.

Bearbeiten Sie `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Schnelles GitHub-Login-Alias
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Internen pm2-Server neustarten
alias repm2='pm2 restart /hexo_run.js'

#### Debian China-Mirror (auskommentieren, wenn Netzwerk schnell ist)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm-Konfiguration
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### History-Persistenz
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh-Konfiguration
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm-Plugin-Installation
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

Bei langsamer Netzwerkverbindung konfigurieren Sie einen Proxy vor Netzwerkanfragen：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Verwendung des Docker-Hostnamens für Proxy (empfohlen)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Fügen Sie eine `requirements.txt`-Datei zu Ihrem Blog-Volume hinzu (ein npm-Paket pro Zeile). Die Pakete werden beim Start automatisch installiert：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Häufige Befehle

| Aktion | Befehl |
|--------|--------|
| In Container einsteigen | `docker exec -it hexo bash` |
| Logs anzeigen | `docker logs --follow hexo` |
| pm2 neustarten | `docker exec hexo pm2 restart /hexo_run.js` |
| Container neustarten | `docker restart hexo` |
| Statische Dateien generieren | `docker exec hexo hexo g` |
| Remote bereitstellen | `docker exec hexo hexo d` |
| Neuen Beitrag erstellen | `docker exec hexo hexo new post "Beitragstitel"` |
| Neue Seite erstellen | `docker exec hexo hexo new page "music"` |
| Cache leeren | `docker exec hexo hexo clean` |

## Schnell-Alias

Fügen Sie diese Aliase zu Ihrer `~/.bashrc` oder `~/.zshrc` hinzu, um hexo-Befehle ohne `docker exec` auszuführen：

```bash
# hexo-Container-Verknüpfungen
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "Mein Titel"
# hexo g
# hexo d
# hexo clean
```

Führen Sie `source ~/.bashrc` aus, um sie zu aktivieren, dann direkt verwenden：

```bash
hexo new post "Mein neuer Beitrag"
hexo g
hexo d
hexo-shell
```

## Live-Vorschau

Hexo unterstützt automatisches Neuladen bei Dateiänderungen. Nach Bearbeitung eines Beitrags oder Themes einfach den Browser aktualisieren.

Wenn Änderungen nicht wirken, ist der Node-Cache möglicherweise veraltet. Starten Sie den Webdienst neu：

```bash
# pm2 neustarten
pm2 restart /hexo_run.js

# Docker hexo neustarten
docker restart hexo
```

## Vollständige Tutorials

- [Hexo Docker環境與Hexo基礎配置篇](https://blog.17lai.site/posts/40300608/)
- [hexo博客自定義修改篇](https://blog.17lai.site/posts/4d8a0b22/)
- [hexo博客網絡優化篇](https://blog.17lai.site/posts/9b056c86/)
- [hexo博客增強部署篇](https://blog.17lai.site/posts/5311b619/)
- [hexo博客個性定製篇](https://blog.17lai.site/posts/4a2050e2/)
- [hexo博客常見問題篇](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown以及各種插件功能測試](https://blog.17lai.site/posts/cf0f47fd/)
- [hexo博客博文撰寫篇之完美筆記大攻略終極完全版](https://blog.17lai.site/posts/253706ff/)
- [在 Hexo 博客中插入 ECharts 動態圖表](https://blog.17lai.site/posts/217ccdc1/)
- [使用nodeppt給hexo博客嵌入PPT演示](https://blog.17lai.site/posts/546887ac/)
- [Vercel部署高級用法教程](https://blog.17lai.site/posts/e922fac8/)
- [Hexo-Dokumentation](https://hexo.io/de/docs/)
- [Hexo-API](https://hexo.io/de/api/)
- [Hexo-Plugins](https://hexo.io/plugins/)

## Dokumentation

| Dokument | Beschreibung |
|----------|--------------|
| [AGENTS.md](./AGENTS.md) | KI-Konventionen, Befehle, Engineering-Standards |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Architektur, Komponenten, Datenfluss |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Funktionale und nicht-funktionale Anforderungen |
| [docs/TESTING.md](./docs/TESTING.md) | Teststrategie, Docker-Build-Verifikation |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | Versionsverlauf |

## Ressourcen

- [Hexo-Dokumentation](https://hexo.io/de/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Upstream-Projekt：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
