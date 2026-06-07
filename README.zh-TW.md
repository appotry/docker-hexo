[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Hexo 部落格環境的 Docker 映像** — 開箱即用，無需安裝 Node.js / npm / Hexo。

映像發佈於 Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

[English](./README.en.md) · [简体中文](./README.md) · [繁體中文](./README.zh-TW.md) · [日本語](./README.ja.md) · [한국어](./README.ko.md)
[Español](./README.es.md) · [Français](./README.fr.md) · [Deutsch](./README.de.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [العربية](./README.ar.md)

> 為什麼推薦每個人都自建一個獨立部落格網站？
> - 一個自我展示的名片！
> - 最大的言論自由，不被任何外人以及公司審查刪帖封號！

---

## 快速開始

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

首次啟動時，若 `/app` 為空，容器會自動執行 `hexo init` 初始化部落格並安裝常用插件。

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

## 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `HEXO_SERVER_PORT` | `4000` | Hexo 伺服器監聽埠 |
| `GIT_USER` | — | Git 全域使用者名稱 |
| `GIT_EMAIL` | — | Git 全域信箱 |

## SSH 金鑰

**Docker 會自動隨機產生 SSH 金鑰** 在 `/app/.ssh` 目錄。自動部署請把 SSH Key 新增到 GitHub 等平台。

```bash
# 檢視公鑰
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub 新增 SSH Key 詳細教學](https://docs.github.com/zh-tw/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## 進入 Docker

```bash
docker exec -it hexo bash
```

進入容器後，就可以正常執行 hexo 的各種命令了。

## 設定主題

不同人的審美不一樣，這裡推薦幾個主題：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

下載好主題後，按照不同主題的使用說明設定對應的設定檔，然後編譯專案 `hexo g`，編譯完之後就可以透過瀏覽器訪問 `http://[docker IP]:4000` 看到網頁了。

```bash
cd /app
git clone https://github.com/使用者/hexo-theme-xxx.git themes/xxx
```

編輯 `/app/_config.yml`，修改 `theme: xxx`，然後 `hexo g` 重新產生。

## 使用者自動執行指令碼

使用者可以在這裡新增自動設定、自動安裝插件等啟動 Docker 時執行的命令。

編輯 `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# 快速新增登入github密鑰
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# 重啟內部pm2 伺服器
alias repm2='pm2 restart /hexo_run.js'

#### debian 中國區加速
# 如果網路速度快，可以註解
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm 設定
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### history 持久化
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh 設定
#### 避免 "Are you sure you want to continue connecting (yes/no)? yes"
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm 插件安裝
# 這裡使用者可以修改自訂安裝
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

如果網路訪問不順利，可在訪問網路之前新增代理：

```bash
# 命令列使用代理的方法
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# 使用docker host name 來訪問代理，不用IP。更推薦這種方式，使用 docker 內部的 dns 尋找目標
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

在部落格磁碟區中加入 `requirements.txt`，每行一個 npm 套件名稱，啟動時自動安裝：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## 常用命令

| 操作 | 命令 |
|------|------|
| 進入容器 | `docker exec -it hexo bash` |
| 檢視日誌 | `docker logs --follow hexo` |
| 重啟 pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| 重啟容器 | `docker restart hexo` |
| 產生靜態檔案 | `docker exec hexo hexo g` |
| 部署到遠端 | `docker exec hexo hexo d` |
| 新增文章 | `docker exec hexo hexo new post "文章標題"` |
| 新增頁面 | `docker exec hexo hexo new page "music"` |
| 清除快取 | `docker exec hexo hexo clean` |

## 快捷別名

在宿主機 `~/.bashrc` 或 `~/.zshrc` 中加入以下別名，可直接執行 hexo 命令而無需先 `docker exec`：

```bash
# hexo 容器快捷操作
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "標題"
# hexo g
# hexo d
# hexo clean
```

加入後執行 `source ~/.bashrc` 生效，之後可直接使用：

```bash
hexo new post "我的新文章"
hexo g
hexo d
hexo-shell
```

## 即時預覽修改

Hexo 支援即時預覽修改效果，文章主題的修改，都可以透過 Web 服務立刻看到效果。

如果你發現了修改沒有立刻生效，可能是 node 快取還在，可以使用下面方法重啟 Web 服務：

```bash
# 重啟 pm2
pm2 restart /hexo_run.js

# 重啟 hexo docker
docker restart hexo
```

## 完整使用教學

- [Hexo Docker環境與Hexo基礎配置篇](https://blog.17lai.site/posts/40300608/)
- [hexo部落格自定義修改篇](https://blog.17lai.site/posts/4d8a0b22/)
- [hexo部落格網路最佳化篇](https://blog.17lai.site/posts/9b056c86/)
- [hexo部落格增強部署篇](https://blog.17lai.site/posts/5311b619/)
- [hexo部落格個性定製篇](https://blog.17lai.site/posts/4a2050e2/)
- [hexo部落格常見問題篇](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown以及各種插件功能測試](https://blog.17lai.site/posts/cf0f47fd/)
- [hexo部落格博文撰寫篇之完美筆記大攻略終極完全版](https://blog.17lai.site/posts/253706ff/)
- [在 Hexo 部落格中插入 ECharts 動態圖表](https://blog.17lai.site/posts/217ccdc1/)
- [使用nodeppt給hexo部落格嵌入PPT演示](https://blog.17lai.site/posts/546887ac/)
- [Vercel部署高階用法教學](https://blog.17lai.site/posts/e922fac8/)
- [Hexo中文文件](https://hexo.io/zh-tw/docs/)
- [HexoAPI](https://hexo.io/zh-tw/api/)
- [Hexo插件](https://hexo.io/plugins/)

## 文件導覽

| 文件 | 內容 |
|------|------|
| [AGENTS.md](./AGENTS.md) | AI 工作約定、命令、工程規範 |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | 架構說明、元件關係、資料流 |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | 功能與非功能需求 |
| [docs/TESTING.md](./docs/TESTING.md) | 測試策略、Docker 建置驗證 |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | 版本變更歷史 |

## 相關資源

- [Hexo 官方文件](https://hexo.io/zh-tw/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- 上游專案：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
