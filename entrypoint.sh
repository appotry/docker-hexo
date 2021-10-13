#!/bin/bash

cnpm config set registry https://registry.cnpm.taobao.org

if [ "$(ls -A /app)" ]; then 
    echo "***** App directory exists and has content, continuing *****"; 
else 
    echo "***** App directory is empty, initialising with hexo and hexo-admin *****" 
    hexo init 
    cnpm install 
    cnpm install --save hexo-admin 
    cnpm install hexo-generator-search --save 
    cnpm install hexo-deployer-git --save 
    cnpm install hexo-generator-feed --save 
    cnpm install hexo-generator-searchdb --save 
    cnpm install hexo-wordcount --save 
    cnpm install hexo-permalink-pinyin --save 
    cnpm install hexo-filter-github-emojis --save 
    cnpm install hexo-generator-sitemap --save 
    cnpm install hexo-generator-baidu-sitemap --save 
    cnpm install hexo-admonition --save 
    #cnpm install hexo-baidu-url-submit --save 
    cnpm install hexo-related-popular-posts --save 
    cnpm install hexo-generator-index --save
    #cnpm install hexo-generator-index-pin-top --save 
    #cnpm i hexo-web-push-notification --save 
    #cnpm install highlight.js --save 
    echo "install live2d and model weier" 
    #cnpm uninstall fsevents 
    #cnpm install fsevents --save 
    echo "Please install browser plugin liveReload !" 
    cnpm install livereload bufferutil utf-8-validate --save 
    cnpm install hexo-helper-live2d --save 
    cnpm install live2d-widget-model-lwet --save 
    echo "install hexo-theme-matery" 
    #git clone https://github.com/blinkfox/hexo-theme-matery.git /app/themes/matery; 
fi; 

if [ ! -f /app/requirements.txt ]; then 
    echo "***** App directory contains no requirements.txt file, continuing *****"; 
else 
    echo "***** App directory contains a requirements.txt file, installing cnpm requirements *****"; 
    cat /app/requirements.txt | xargs cnpm --prefer-offline install --save; 
fi; 

if [ "$(ls -A /app/.ssh 2>/dev/null)" ]; then 
    echo "***** App .ssh directory exists and has content, continuing *****"; 
else 
    echo "***** App .ssh directory is empty, initialising ssh key and configuring known_hosts for common git repositories (github/gitlab) *****" 
    rm -rf ~/.ssh/* 
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P "" 
    ssh-keyscan github.com > ~/.ssh/known_hosts 2>/dev/null 
    ssh-keyscan gitlab.com >> ~/.ssh/known_hosts 2>/dev/null 
    cp -r ~/.ssh /app; 
fi; 

echo "***** Running git config, user = ${GIT_USER}, email = ${GIT_EMAIL} *****" 
git config --global user.email ${GIT_EMAIL} 
git config --global user.name ${GIT_USER} 
echo "***** Copying .ssh from App directory and setting permissions *****" 
cp -r /app/.ssh ~/ 
chmod 600 ~/.ssh/id_rsa 
chmod 600 ~/.ssh/id_rsa.pub 
chmod 700 ~/.ssh 
echo "***** Contents of public ssh key (for deploy) - *****" 
cat ~/.ssh/id_rsa.pub 

if [ ! -f /app/useRun.sh ]; then 
    echo "cp useRun.sh"
    cp /useRun.sh /app/useRun.sh; 
    chmod +x /app/useRun.sh;
    /app/useRun.sh; 
else 
    echo "run useRun.sh"
    /app/useRun.sh; 
fi

#echo "***** Starting server on port ${HEXO_SERVER_PORT} *****" 
#hexo server -d -p ${HEXO_SERVER_PORT}

pm2-runtime start /hexo_run.js

#echo "***** stop hexo server run:  pm2 stop /hexo_run.js  *****" 
#echo "***** start hexo server run:  pm2 start /hexo_run.js  *****" 



