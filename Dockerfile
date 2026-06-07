FROM node:20-slim

LABEL maintainer="andycrusoe@gmail.com"
LABEL repository="https://github.com/appotry/docker-hexo"
LABEL homepage="https://blog.17lai.site"

ENV HEXO_SERVER_PORT=4000
ENV GIT_USER="appotry"
ENV GIT_EMAIL="andycrusoe@gmail.com"
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gpg ca-certificates && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git git-lfs vim net-tools lsof procps locales \
        openssl openssh-client jq wget dos2unix build-essential autoconf automake \
        gettext libtool pkg-config libpng-dev gnupg2 \
        gh && \
    sed -i '/zh_CN.UTF-8/s/^# //' /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    npm config set registry https://registry.npmmirror.com && \
    npm install -g gulp pm2 nrm npm-check hexo-cli cnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'hexo' > /etc/hostname && \
    echo 'export PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\\$ "' >> /etc/profile && \
    echo "alias ll='ls -laFh'" >> /etc/profile && \
    echo "alias ls='/bin/ls -F --color=auto'" >> /etc/profile && \
    echo "欢迎使用Hexo Docker 开源集成开发环境"  >> /etc/motd && \
    echo "Github: https://github.com/appotry/docker-hexo"  >> /etc/motd && \
    echo "Dockerhub: https://hub.docker.com/r/bloodstar/hexo"  >> /etc/motd && \
    echo "作者使用教程： https://blog.17lai.site/posts/40300608"  >> /etc/motd && \
    echo "祝您使用愉快！"  >> /etc/motd

WORKDIR /app

EXPOSE ${HEXO_SERVER_PORT}

COPY entrypoint.sh /entrypoint.sh
COPY userRun.sh /userRun.sh
COPY hexo_run.js /hexo_run.js

RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
