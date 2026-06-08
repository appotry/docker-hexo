[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Image Docker pour environnement de blog Hexo** — zéro configuration, pas besoin d'installer Node.js / npm / Hexo localement.

Publiée sur Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> Pourquoi créer son propre blog indépendant ?
> - Une carte de visite personnelle !
> - Une liberté d'expression totale, sans censure de la part d'étrangers ou d'entreprises.

---

## Démarrage Rapide

### Avec docker CLI

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

Au premier démarrage, si `/app` est vide, le conteneur exécute automatiquement `hexo init` et installe les plugins courants.

### Avec docker compose

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

## Variables d'Environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `HEXO_SERVER_PORT` | `4000` | Port d'écoute du serveur Hexo |
| `GIT_USER` | — | Nom d'utilisateur Git global |
| `GIT_EMAIL` | — | Email Git global |

## Clés SSH

**Docker génère automatiquement des clés SSH** dans `/app/.ssh`. Ajoutez la clé publique à GitHub ou d'autres plateformes pour le déploiement.

```bash
# Voir la clé publique
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[Tutoriel sur les clés SSH GitHub](https://docs.github.com/fr/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Entrer dans Docker

```bash
docker exec -it hexo bash
```

Entrez dans le conteneur pour exécuter toutes les commandes hexo.

## Configuration du Thème

Les goûts de chacun sont différents. Voici quelques thèmes recommandés :

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

Après avoir téléchargé un thème, configurez-le selon les instructions, puis exécutez `hexo g` pour générer. Visitez `http://[docker IP]:4000` pour voir votre site.

```bash
cd /app
git clone https://github.com/utilisateur/hexo-theme-xxx.git themes/xxx
```

Modifiez `/app/_config.yml`, définissez `theme: xxx`, puis exécutez `hexo g` pour régénérer.

## Script Personnalisé Utilisateur

Ajoutez des commandes de configuration automatique et d'installation de plugins qui s'exécutent au démarrage de Docker.

Modifiez `/app/userRun.sh` :

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Alias rapide pour la connexion GitHub
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Redémarrer le serveur pm2 interne
alias repm2='pm2 restart /hexo_run.js'

#### Miroir Debian Chine (commenter si votre réseau est rapide)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### Configuration npm
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### Persistance de l'historique
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### Configuration ssh
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### Installation des plugins npm
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

Si le réseau est lent, configurez un proxy avant les requêtes réseau :

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Utilisation du nom d'hôte Docker pour le proxy (recommandé)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Ajoutez un fichier `requirements.txt` à votre volume de blog (un paquet npm par ligne). Les paquets sont installés automatiquement au démarrage :

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Commandes Courantes

| Action | Commande |
|--------|----------|
| Entrer dans le conteneur | `docker exec -it hexo bash` |
| Voir les logs | `docker logs --follow hexo` |
| Redémarrer pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| Redémarrer le conteneur | `docker restart hexo` |
| Générer les fichiers statiques | `docker exec hexo hexo g` |
| Déployer vers le remote | `docker exec hexo hexo d` |
| Nouvel article | `docker exec hexo hexo new post "Titre de l'article"` |
| Nouvelle page | `docker exec hexo hexo new page "music"` |
| Vider le cache | `docker exec hexo hexo clean` |

## Aliases Rapides

Ajoutez ces alias à votre `~/.bashrc` ou `~/.zshrc` pour utiliser les commandes hexo sans taper `docker exec` à chaque fois :

```bash
# Raccourcis du conteneur hexo
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "Mon Titre"
# hexo g
# hexo d
# hexo clean
```

Exécutez `source ~/.bashrc` pour les activer, puis utilisez directement :

```bash
hexo new post "Mon Nouvel Article"
hexo g
hexo d
hexo-shell
```

## Aperçu en Direct

Hexo supporte le rechargement automatique des modifications de fichiers. Après avoir modifié un article ou un thème, actualisez simplement le navigateur.

Si les changements ne s'appliquent pas, le cache node est peut-être obsolète. Redémarrez le service web :

```bash
# Redémarrer pm2
pm2 restart /hexo_run.js

# Redémarrer Docker hexo
docker restart hexo
```

## Tutoriels Complets

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
- [Documentation Hexo](https://hexo.io/fr/docs/)
- [API Hexo](https://hexo.io/fr/api/)
- [Plugins Hexo](https://hexo.io/plugins/)

## Documentation

| Document | Description |
|----------|-------------|
| [AGENTS.md](./AGENTS.md) | Conventions AI, commandes, standards d'ingénierie |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Architecture, composants, flux de données |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Exigences fonctionnelles et non fonctionnelles |
| [docs/TESTING.md](./docs/TESTING.md) | Stratégie de test, vérification de build Docker |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | Historique des versions |

## Ressources

- [Documentation Hexo](https://hexo.io/fr/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Projet upstream：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
