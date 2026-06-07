[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Imagen Docker para entornos de blog Hexo** — Configuración cero, sin necesidad de instalar Node.js / npm / Hexo localmente.

Publicada en Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

[English](./README.en.md) · [简体中文](./README.md) · [繁體中文](./README.zh-TW.md) · [日本語](./README.ja.md) · [한국어](./README.ko.md)
[Español](./README.es.md) · [Français](./README.fr.md) · [Deutsch](./README.de.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [العربية](./README.ar.md)

> ¿Por qué construir tu propio blog independiente?
> - ¡Una tarjeta de presentación personal!
> - Total libertad de expresión, sin censura por parte de externos o empresas.

---

## Inicio Rápido

### Usando docker CLI

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

En el primer inicio, si `/app` está vacío, el contenedor ejecuta automáticamente `hexo init` e instala los plugins comunes.

### Usando docker compose

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

## Variables de Entorno

| Variable | Por defecto | Descripción |
|----------|-------------|-------------|
| `HEXO_SERVER_PORT` | `4000` | Puerto del servidor Hexo |
| `GIT_USER` | — | Nombre de usuario global de Git |
| `GIT_EMAIL` | — | Correo electrónico global de Git |

## Claves SSH

**Docker genera automáticamente claves SSH** en `/app/.ssh`. Añade la clave pública a GitHub u otras plataformas para el despliegue.

```bash
# Ver clave pública
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[Tutorial de claves SSH de GitHub](https://docs.github.com/es/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Entrar a Docker

```bash
docker exec -it hexo bash
```

Entra al contenedor para ejecutar cualquier comando de hexo.

## Configuración de Temas

Cada persona tiene gustos diferentes. Aquí hay algunos temas recomendados：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

Después de descargar un tema, configúralo según las instrucciones y ejecuta `hexo g` para generar. Visita `http://[docker IP]:4000` para ver tu sitio.

```bash
cd /app
git clone https://github.com/usuario/hexo-theme-xxx.git themes/xxx
```

Edita `/app/_config.yml`, establece `theme: xxx`, luego ejecuta `hexo g` para regenerar.

## Script Personalizado de Usuario

Añade comandos de configuración automática e instalación de plugins que se ejecuten al iniciar Docker.

Edita `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Alias rápido para login en GitHub
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Reiniciar servidor pm2 interno
alias repm2='pm2 restart /hexo_run.js'

#### Espejo Debian China (comentar si tu red es rápida)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### Configuración npm
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### Persistencia de history
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### Configuración ssh
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### Instalación de plugins npm
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

Si la red es lenta, configura un proxy antes de las solicitudes de red：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Usando nombre de host Docker para el proxy (recomendado)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Añade un archivo `requirements.txt` a tu volumen del blog (un paquete npm por línea). Los paquetes se instalan automáticamente al iniciar：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Comandos Comunes

| Acción | Comando |
|--------|---------|
| Entrar al contenedor | `docker exec -it hexo bash` |
| Ver logs | `docker logs --follow hexo` |
| Reiniciar pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| Reiniciar contenedor | `docker restart hexo` |
| Generar archivos estáticos | `docker exec hexo hexo g` |
| Desplegar a remoto | `docker exec hexo hexo d` |
| Nuevo artículo | `docker exec hexo hexo new post "Título del Artículo"` |
| Nueva página | `docker exec hexo hexo new page "music"` |
| Limpiar caché | `docker exec hexo hexo clean` |

## Alias Rápidos

Añade estos alias a tu `~/.bashrc` o `~/.zshrc` para usar comandos hexo sin escribir `docker exec` cada vez：

```bash
# Accesos directos del contenedor hexo
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "Mi Título"
# hexo g
# hexo d
# hexo clean
```

Ejecuta `source ~/.bashrc` para activarlos, luego usa directamente：

```bash
hexo new post "Mi Nuevo Artículo"
hexo g
hexo d
hexo-shell
```

## Vista Previa en Vivo

Hexo soporta recarga automática al detectar cambios. Después de editar un artículo o tema, simplemente actualiza el navegador.

Si los cambios no se reflejan, el caché de node puede estar desactualizado. Reinicia el servicio web：

```bash
# Reiniciar pm2
pm2 restart /hexo_run.js

# Reiniciar Docker hexo
docker restart hexo
```

## Tutoriales Completos

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
- [Documentación de Hexo](https://hexo.io/es/docs/)
- [API de Hexo](https://hexo.io/es/api/)
- [Plugins de Hexo](https://hexo.io/plugins/)

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [AGENTS.md](./AGENTS.md) | Convenciones AI, comandos, estándares de ingeniería |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Arquitectura, componentes, flujo de datos |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Requisitos funcionales y no funcionales |
| [docs/TESTING.md](./docs/TESTING.md) | Estrategia de pruebas, verificación de build Docker |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | Historial de versiones |

## Recursos

- [Documentación de Hexo](https://hexo.io/es/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Proyecto upstream：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
