FROM node:lts-slim

MAINTAINER appotry <andycrusoe@gmail.com>

# Set the server port as an environmental
ENV HEXO_SERVER_PORT=4000

# Set the git username and email
ENV GIT_USER="andy"
ENV GIT_EMAIL="andycrusoe@gmail.com"

# Install requirements
RUN apt-get update && \
    apt-get install git curl vim procps locales -y && \
    locale-gen zh_CN && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 && \
    apt-get install yarn -y && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install -g pm2 && \
    npm install -g hexo-cli && \
    npm install livereload bufferutil utf-8-validate -g && \
    npm install -g cnpm --registry=https://registry.npm.taobao.org && \
    apt-get clean 

ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8

# Set workdir
WORKDIR /app

# Expose Server Port
EXPOSE ${HEXO_SERVER_PORT}

# Build a base server and configuration if it doesnt exist, then start
# CMD \
#   if [ "$(ls -A /app)" ]; then \
#     echo "***** App directory exists and has content, continuing *****"; \
#   else \
#     echo "***** App directory is empty, initialising with hexo and hexo-admin *****" && \
#     hexo init && \
#     npm install && \
#     npm install --save hexo-admin && \
#     npm install hexo-generator-search --save && \
#     npm install hexo-deployer-git --save && \
#     npm install hexo-generator-feed --save && \
#     npm install hexo-generator-searchdb --save && \
#     npm install hexo-wordcount --save && \
#     npm install hexo-permalink-pinyin --save && \
#     npm install hexo-filter-github-emojis --save && \
#     npm install hexo-generator-sitemap --save && \
#     npm install hexo-generator-baidu-sitemap --save && \
#     npm install hexo-admonition --save && \
#     npm install hexo-baidu-url-submit --save && \
#     npm install hexo-related-popular-posts --save && \
#     npm uninstall hexo-generator-index --save && \
#     npm install hexo-generator-index-pin-top --save && \
#     npm i hexo-web-push-notification --save && \
#     npm install highlight.js --save && \
#     echo "install live2d and model weier" && \
#     npm uninstall fsevents && \
#     npm install fsevents --save && \
#     echo "Please install browser plugin liveReload !" && \
#     npm install livereload bufferutil utf-8-validate --save && \
#     npm install hexo-helper-live2d --save && \
#     npm install live2d-widget-model-lwet --save && \
#     echo "install hexo-theme-matery" && \
#     git clone https://github.com/blinkfox/hexo-theme-matery.git /app/themes/matery; \
#   fi; \
#   if [ ! -f /app/requirements.txt ]; then \
#     echo "***** App directory contains no requirements.txt file, continuing *****"; \
#   else \
#     echo "***** App directory contains a requirements.txt file, installing npm requirements *****"; \
#     cat /app/requirements.txt | xargs npm --prefer-offline install --save; \
#   fi; \
#   if [ "$(ls -A /app/.ssh 2>/dev/null)" ]; then \
#     echo "***** App .ssh directory exists and has content, continuing *****"; \
#   else \
#     echo "***** App .ssh directory is empty, initialising ssh key and configuring known_hosts for common git repositories (github/gitlab) *****" && \
#     rm -rf ~/.ssh/* && \
#     ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P "" && \
#     ssh-keyscan github.com > ~/.ssh/known_hosts 2>/dev/null && \
#     ssh-keyscan gitlab.com >> ~/.ssh/known_hosts 2>/dev/null && \
#     cp -r ~/.ssh /app; \
#   fi; \
#   echo "***** Running git config, user = ${GIT_USER}, email = ${GIT_EMAIL} *****" && \
#   git config --global user.email ${GIT_EMAIL} && \
#   git config --global user.name ${GIT_USER} && \
#   echo "***** Copying .ssh from App directory and setting permissions *****" && \
#   cp -r /app/.ssh ~/ && \
#   chmod 600 ~/.ssh/id_rsa && \
#   chmod 600 ~/.ssh/id_rsa.pub && \
#   chmod 700 ~/.ssh && \
#   echo "***** Contents of public ssh key (for deploy) - *****" && \
#   cat ~/.ssh/id_rsa.pub && \
#   echo "***** Starting server on port ${HEXO_SERVER_PORT} *****" && \
#   hexo server -d -p ${HEXO_SERVER_PORT}

COPY entrypoint.sh /entrypoint.sh
COPY useRun.sh /useRun.sh
COPY hexo_run.js /hexo_run.js

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]