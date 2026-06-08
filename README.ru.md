[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Docker-образ для среды блога Hexo** — нулевая настройка, не требуется установка Node.js / npm / Hexo.

Опубликовано на Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> Зачем создавать свой собственный независимый блог?
> - Личная визитная карточка!
> - Полная свобода слова, без цензуры со стороны посторонних или компаний.

---

## Быстрый Старт

### Использование docker CLI

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

При первом запуске, если `/app` пуст, контейнер автоматически выполняет `hexo init` и устанавливает стандартные плагины.

### Использование docker compose

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

## Переменные Окружения

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `HEXO_SERVER_PORT` | `4000` | Порт сервера Hexo |
| `GIT_USER` | — | Глобальное имя пользователя Git |
| `GIT_EMAIL` | — | Глобальный email Git |

## SSH-ключи

**Docker автоматически генерирует SSH-ключи** в `/app/.ssh`. Добавьте открытый ключ на GitHub или другие платформы для развертывания.

```bash
# Просмотр открытого ключа
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[Инструкция по SSH-ключам GitHub](https://docs.github.com/ru/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Вход в Docker

```bash
docker exec -it hexo bash
```

Войдите в контейнер для выполнения любых команд hexo.

## Настройка Темы

У каждого свои вкусы. Вот несколько рекомендуемых тем：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

После загрузки темы настройте её в соответствии с инструкциями и выполните `hexo g` для сборки. Перейдите по адресу `http://[docker IP]:4000`, чтобы увидеть свой сайт.

```bash
cd /app
git clone https://github.com/пользователь/hexo-theme-xxx.git themes/xxx
```

Отредактируйте `/app/_config.yml`, установите `theme: xxx`, затем выполните `hexo g` для перегенерации.

## Пользовательский Скрипт

Добавьте команды автоматической настройки и установки плагинов, выполняемые при запуске Docker.

Отредактируйте `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Быстрый алиас для входа в GitHub
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Перезапуск внутреннего сервера pm2
alias repm2='pm2 restart /hexo_run.js'

#### Зеркало Debian China (закомментируйте, если сеть быстрая)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### Настройка npm
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### Сохранение истории
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### Настройка ssh
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### Установка npm-плагинов
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

Если сеть медленная, настройте прокси перед сетевыми запросами：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Использование имени хоста Docker для прокси (рекомендуется)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Добавьте файл `requirements.txt` в том вашего блога (один npm-пакет на строку). Пакеты автоматически устанавливаются при запуске：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Часто Используемые Команды

| Действие | Команда |
|----------|---------|
| Войти в контейнер | `docker exec -it hexo bash` |
| Просмотр логов | `docker logs --follow hexo` |
| Перезапуск pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| Перезапуск контейнера | `docker restart hexo` |
| Генерация статических файлов | `docker exec hexo hexo g` |
| Развертывание на удаленный сервер | `docker exec hexo hexo d` |
| Новая запись | `docker exec hexo hexo new post "Заголовок записи"` |
| Новая страница | `docker exec hexo hexo new page "music"` |
| Очистка кэша | `docker exec hexo hexo clean` |

## Быстрые Алиасы

Добавьте эти алиасы в ваш `~/.bashrc` или `~/.zshrc`, чтобы использовать команды hexo без постоянного ввода `docker exec`：

```bash
# Быстрые команды контейнера hexo
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "Мой заголовок"
# hexo g
# hexo d
# hexo clean
```

Выполните `source ~/.bashrc` для активации, затем используйте напрямую：

```bash
hexo new post "Моя новая запись"
hexo g
hexo d
hexo-shell
```

## Живой Предпросмотр

Hexo поддерживает автоматическую перезагрузку при изменении файлов. После редактирования записи или темы просто обновите браузер.

Если изменения не применяются, возможно, кэш node устарел. Перезапустите веб-сервис：

```bash
# Перезапуск pm2
pm2 restart /hexo_run.js

# Перезапуск Docker hexo
docker restart hexo
```

## Полные Руководства

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
- [Документация Hexo](https://hexo.io/ru/docs/)
- [API Hexo](https://hexo.io/ru/api/)
- [Плагины Hexo](https://hexo.io/plugins/)

## Документация

| Документ | Описание |
|----------|---------|
| [AGENTS.md](./AGENTS.md) | AI-соглашения, команды, стандарты разработки |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Архитектура, компоненты, потоки данных |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Функциональные и нефункциональные требования |
| [docs/TESTING.md](./docs/TESTING.md) | Стратегия тестирования, проверка сборки Docker |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | История версий |

## Ресурсы

- [Документация Hexo](https://hexo.io/ru/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Вышестоящий проект：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
