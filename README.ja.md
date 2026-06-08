[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Hexo ブログ環境の Docker イメージ** — Node.js / npm / Hexo のインストール不要、すぐに使えます。

Docker Hub で公開：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> なぜ自分だけの独立したブログサイトを構築すべきなのか？
> - 自己紹介の名刺代わり！
> - 外部や企業による検閲・削除・アカウント停止のない、最大限の言論の自由！

---

## クイックスタート

### docker CLI を使う

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

初回起動時、`/app` が空の場合、コンテナは自動的に `hexo init` を実行し、ブログを初期化して一般的なプラグインをインストールします。

### docker compose を使う

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

## 環境変数

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `HEXO_SERVER_PORT` | `4000` | Hexo サーバー listen ポート |
| `GIT_USER` | — | Git グローバルユーザー名 |
| `GIT_EMAIL` | — | Git グローバルメールアドレス |

## SSH 鍵

**Docker が自動的に SSH 鍵を生成**します（`/app/.ssh` ディレクトリ）。公開鍵を GitHub などのプラットフォームに追加してデプロイに使用します。

```bash
# 公開鍵を表示
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub SSH 鍵の追加方法](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Docker に入る

```bash
docker exec -it hexo bash
```

コンテナ内で hexo コマンドを実行できます。

## テーマ設定

好みは人それぞれです。以下はおすすめのテーマです：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

テーマをダウンロードしたら、各テーマの指示に従って設定し、`hexo g` でビルドします。`http://[docker IP]:4000` で確認できます。

```bash
cd /app
git clone https://github.com/user/hexo-theme-xxx.git themes/xxx
```

`/app/_config.yml` を編集して `theme: xxx` を設定し、`hexo g` で再生成します。

## ユーザーカスタムスクリプト

Docker 起動時に実行する自動設定やプラグインインストールコマンドを追加できます。

`/app/userRun.sh` を編集：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# GitHub ログインエイリアス
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# pm2 サーバー再起動
alias repm2='pm2 restart /hexo_run.js'

#### Debian 中国ミラー（ネットワークが速ければコメントアウト）
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm 設定
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### history 永続化
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh 設定
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm プラグインインストール
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

ネットワークが遅い場合は、プロキシを設定してください：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Docker ホスト名を使用（推奨）
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

ブログボリュームに `requirements.txt` を追加（1行1パッケージ）。起動時に自動インストールされます：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## よく使うコマンド

| 操作 | コマンド |
|------|---------|
| コンテナに入る | `docker exec -it hexo bash` |
| ログを確認 | `docker logs --follow hexo` |
| pm2 再起動 | `docker exec hexo pm2 restart /hexo_run.js` |
| コンテナ再起動 | `docker restart hexo` |
| 静的ファイル生成 | `docker exec hexo hexo g` |
| リモートデプロイ | `docker exec hexo hexo d` |
| 新規記事作成 | `docker exec hexo hexo new post "記事タイトル"` |
| 新規ページ作成 | `docker exec hexo hexo new page "music"` |
| キャッシュ削除 | `docker exec hexo hexo clean` |

## クイックエイリアス

`~/.bashrc` または `~/.zshrc` に以下を追加すると、`docker exec` を省略できます：

```bash
# hexo コンテナショートカット
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "タイトル"
# hexo g
# hexo d
# hexo clean
```

`source ~/.bashrc` で有効化後、直接使用できます：

```bash
hexo new post "新しい記事"
hexo g
hexo d
hexo-shell
```

## ライブプレビュー

Hexo はファイル変更を検出して自動リロードします。記事やテーマを編集後、ブラウザをリフレッシュするだけで反映されます。

反映されない場合は node キャッシュが原因かもしれません。以下の方法で Web サービスを再起動してください：

```bash
# pm2 再起動
pm2 restart /hexo_run.js

# Docker 再起動
docker restart hexo
```

## 完全なチュートリアル

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
- [Hexo ドキュメント](https://hexo.io/ja/docs/)
- [Hexo API](https://hexo.io/ja/api/)
- [Hexo プラグイン](https://hexo.io/plugins/)

## ドキュメント

| 文書 | 内容 |
|------|------|
| [AGENTS.md](./AGENTS.md) | AI 作業約定、コマンド、エンジニアリング標準 |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | アーキテクチャ、コンポーネント、データフロー |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | 機能要件と非機能要件 |
| [docs/TESTING.md](./docs/TESTING.md) | テスト戦略、Docker ビルド検証 |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | バージョン履歴 |

## 関連リソース

- [Hexo ドキュメント](https://hexo.io/ja/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- アップストリーム：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
