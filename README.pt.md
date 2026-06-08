[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Imagem Docker para ambiente de blog Hexo** — Configuração zero, sem necessidade de instalar Node.js / npm / Hexo localmente.

Publicada no Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> Por que construir seu próprio blog independente?
> - Um cartão de visita pessoal!
> - Total liberdade de expressão, sem censura por parte de estranhos ou empresas.

---

## Início Rápido

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

Na primeira inicialização, se `/app` estiver vazio, o contêiner executa automaticamente `hexo init` e instala os plugins comuns.

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

## Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `HEXO_SERVER_PORT` | `4000` | Porta do servidor Hexo |
| `GIT_USER` | — | Nome de usuário global do Git |
| `GIT_EMAIL` | — | Email global do Git |

## Chaves SSH

**O Docker gera automaticamente chaves SSH** em `/app/.ssh`. Adicione a chave pública ao GitHub ou outras plataformas para implantação.

```bash
# Ver chave pública
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[Tutorial de chave SSH do GitHub](https://docs.github.com/pt/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Entrar no Docker

```bash
docker exec -it hexo bash
```

Entre no contêiner para executar qualquer comando hexo.

## Configuração de Tema

Cada pessoa tem gostos diferentes. Aqui estão alguns temas recomendados：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

Após baixar um tema, configure-o conforme as instruções e execute `hexo g` para gerar. Visite `http://[docker IP]:4000` para ver seu site.

```bash
cd /app
git clone https://github.com/usuario/hexo-theme-xxx.git themes/xxx
```

Edite `/app/_config.yml`, defina `theme: xxx`, depois execute `hexo g` para regenerar.

## Script Personalizado do Usuário

Adicione comandos de configuração automática e instalação de plugins que executam ao iniciar o Docker.

Edite `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# Alias rápido para login no GitHub
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# Reiniciar servidor pm2 interno
alias repm2='pm2 restart /hexo_run.js'

#### Espelho Debian China (comente se sua rede for rápida)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### Configuração npm
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### Persistência do histórico
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### Configuração ssh
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### Instalação de plugins npm
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

Se a rede estiver lenta, configure um proxy antes das requisições de rede：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Usando nome de host Docker para proxy (recomendado)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

Adicione um arquivo `requirements.txt` ao volume do seu blog (um pacote npm por linha). Os pacotes são instalados automaticamente na inicialização：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## Comandos Comuns

| Ação | Comando |
|------|---------|
| Entrar no contêiner | `docker exec -it hexo bash` |
| Ver logs | `docker logs --follow hexo` |
| Reiniciar pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| Reiniciar contêiner | `docker restart hexo` |
| Gerar arquivos estáticos | `docker exec hexo hexo g` |
| Implantar remoto | `docker exec hexo hexo d` |
| Novo artigo | `docker exec hexo hexo new post "Título do Artigo"` |
| Nova página | `docker exec hexo hexo new page "music"` |
| Limpar cache | `docker exec hexo hexo clean` |

## Aliases Rápidos

Adicione estes aliases ao seu `~/.bashrc` ou `~/.zshrc` para usar comandos hexo sem digitar `docker exec` toda vez：

```bash
# Atalhos do contêiner hexo
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "Meu Título"
# hexo g
# hexo d
# hexo clean
```

Execute `source ~/.bashrc` para ativá-los, então use diretamente：

```bash
hexo new post "Meu Novo Artigo"
hexo g
hexo d
hexo-shell
```

## Visualização ao Vivo

Hexo suporta recarga automática em alterações de arquivos. Após editar um artigo ou tema, basta atualizar o navegador.

Se as alterações não forem aplicadas, o cache do node pode estar desatualizado. Reinicie o serviço web：

```bash
# Reiniciar pm2
pm2 restart /hexo_run.js

# Reiniciar Docker hexo
docker restart hexo
```

## Tutoriais Completos

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
- [Documentação do Hexo](https://hexo.io/pt-br/docs/)
- [API do Hexo](https://hexo.io/pt-br/api/)
- [Plugins do Hexo](https://hexo.io/plugins/)

## Documentação

| Documento | Descrição |
|-----------|-------------|
| [AGENTS.md](./AGENTS.md) | Convenções AI, comandos, padrões de engenharia |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Arquitetura, componentes, fluxo de dados |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | Requisitos funcionais e não funcionais |
| [docs/TESTING.md](./docs/TESTING.md) | Estratégia de teste, verificação de build Docker |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | Histórico de versões |

## Recursos

- [Documentação do Hexo](https://hexo.io/pt-br/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- Projeto upstream：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
