[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**Hexo 블로그 환경의 Docker 이미지** — Node.js / npm / Hexo 설치 불필요, 바로 사용 가능.

Docker Hub에서 제공：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

[English](./README.en.md) · [简体中文](./README.md) · [繁體中文](./README.zh-TW.md) · [日本語](./README.ja.md) · [한국어](./README.ko.md)
[Español](./README.es.md) · [Français](./README.fr.md) · [Deutsch](./README.de.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [العربية](./README.ar.md)

> 왜 개인 블로그를 직접 만들어야 할까요?
> - 자기 소개를 위한 명함입니다!
> - 외부나 회사의 검열, 삭제, 계정 정지 없는 최대의 표현의 자유!

---

## 빠른 시작

### docker CLI 사용

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

최초 시작 시 `/app`이 비어 있으면 컨테이너가 자동으로 `hexo init`을 실행하여 블로그를 초기화하고 일반적인 플러그인을 설치합니다.

### docker compose 사용

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

## 환경 변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `HEXO_SERVER_PORT` | `4000` | Hexo 서버 수신 포트 |
| `GIT_USER` | — | Git 전역 사용자 이름 |
| `GIT_EMAIL` | — | Git 전역 이메일 |

## SSH 키

**Docker가 자동으로 SSH 키를 생성**합니다 (`/app/.ssh` 디렉토리). 공개 키를 GitHub 등 플랫폼에 추가하여 배포에 사용하세요.

```bash
# 공개키 보기
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[GitHub SSH 키 추가 방법](https://docs.github.com/ko/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## Docker 접속

```bash
docker exec -it hexo bash
```

컨테이너 내에서 hexo 명령어를 실행할 수 있습니다.

## 테마 설정

취향은 사람마다 다릅니다. 다음은 추천 테마입니다：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

테마를 다운로드한 후 각 테마의 지침에 따라 설정하고 `hexo g`로 빌드하세요. `http://[docker IP]:4000`에서 확인할 수 있습니다.

```bash
cd /app
git clone https://github.com/사용자/hexo-theme-xxx.git themes/xxx
```

`/app/_config.yml`을 편집하여 `theme: xxx`를 설정하고 `hexo g`로 재생성합니다.

## 사용자 정의 스크립트

Docker 시작 시 실행할 자동 설정 및 플러그인 설치 명령을 추가할 수 있습니다.

`/app/userRun.sh` 편집：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# GitHub 로그인 앨리어스
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# 내부 pm2 서버 재시작
alias repm2='pm2 restart /hexo_run.js'

#### Debian 중국 미러 (네트워크가 빠르면 주석 처리)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm 설정
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### history 영속화
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh 설정
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm 플러그인 설치
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

네트워크가 느린 경우 프록시를 설정하세요：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# Docker 호스트 이름 사용 (권장)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

블로그 볼륨에 `requirements.txt` 파일을 추가하세요 (한 줄에 하나의 패키지). 시작 시 자동 설치됩니다：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## 자주 사용하는 명령어

| 작업 | 명령어 |
|------|--------|
| 컨테이너 접속 | `docker exec -it hexo bash` |
| 로그 확인 | `docker logs --follow hexo` |
| pm2 재시작 | `docker exec hexo pm2 restart /hexo_run.js` |
| 컨테이너 재시작 | `docker restart hexo` |
| 정적 파일 생성 | `docker exec hexo hexo g` |
| 원격 배포 | `docker exec hexo hexo d` |
| 새 글 작성 | `docker exec hexo hexo new post "글 제목"` |
| 새 페이지 작성 | `docker exec hexo hexo new page "music"` |
| 캐시 삭제 | `docker exec hexo hexo clean` |

## 빠른 별칭

`~/.bashrc` 또는 `~/.zshrc`에 다음을 추가하면 `docker exec` 없이 hexo 명령어를 직접 사용할 수 있습니다：

```bash
# hexo 컨테이너 단축키
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "제목"
# hexo g
# hexo d
# hexo clean
```

`source ~/.bashrc` 실행 후 직접 사용 가능：

```bash
hexo new post "새 글"
hexo g
hexo d
hexo-shell
```

## 실시간 미리보기

Hexo는 파일 변경을 감지하여 자동으로 새로고침합니다. 글 또는 테마를 편집한 후 브라우저를 새로고침하면 바로 반영됩니다.

변경 사항이 적용되지 않으면 node 캐시가 원인일 수 있습니다. 다음 방법으로 웹 서비스를 다시 시작하세요：

```bash
# pm2 재시작
pm2 restart /hexo_run.js

# Docker 재시작
docker restart hexo
```

## 전체 튜토리얼

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
- [Hexo 문서](https://hexo.io/ko/docs/)
- [Hexo API](https://hexo.io/ko/api/)
- [Hexo 플러그인](https://hexo.io/plugins/)

## 문서

| 문서 | 설명 |
|------|------|
| [AGENTS.md](./AGENTS.md) | AI 작업 규칙, 명령어, 엔지니어링 표준 |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | 아키텍처, 구성 요소, 데이터 흐름 |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | 기능 및 비기능 요구사항 |
| [docs/TESTING.md](./docs/TESTING.md) | 테스트 전략, Docker 빌드 검증 |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | 버전 변경 이력 |

## 관련 자료

- [Hexo 문서](https://hexo.io/ko/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- 업스트림 프로젝트：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
