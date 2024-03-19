#!/bin/bash

#echo "***** Starting server on port ${HEXO_SERVER_PORT} *****" 
#hexo server -d -p ${HEXO_SERVER_PORT}

pm2 start /hexo_run.js

echo "***** stop hexo server run:  pm2 stop /hexo_run.js  *****" 
echo "***** start hexo server run:  pm2 start /hexo_run.js  *****" 


cnpm config set registry https://registry.npmmirror.com/

if [ "$(ls -A /app)" ]; then 
    echo "***** App directory exists and has content, continuing *****"; 
else 
    echo "***** App directory is empty, initialising with hexo and hexo-admin *****" 
    hexo init 
    cnpm install 
    cnpm install --save \
        hexo-generator-searchdb \
        hexo-admin \
        hexo-deployer-git \
        hexo-generator-feed \
        hexo-wordcount \
        hexo-filter-github-emojis \
        hexo-generator-sitemap \
        hexo-admonition \
        hexo-generator-index \
        gulp-clean-css gulp-uglify gulp-htmlmin gulp-htmlclean 
        
    #cnpm install hexo-generator-index-pin-top --save 
    #cnpm install hexo-offline --save 
    #cnpm install hexo-web-push-notification --save 
    #cnpm install highlight.js --save 
    #echo "install live2d and model weier" 
    #cnpm uninstall fsevents 
    #cnpm install fsevents --save 
    #echo "Please install browser plugin liveReload !" 
    #cnpm install livereload bufferutil utf-8-validate --save 
    #cnpm install hexo-helper-live2d --save 
    #cnpm install live2d-widget-model-lwet --save 
    #cnpm install livereload bufferutil utf-8-validate --save
    #echo "install hexo-theme-matery" 
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

if [ ! -f /app/userRun.sh ]; then 
    echo "cp userRun.sh"
    cp /userRun.sh /app/userRun.sh; 
    chmod +x /app/userRun.sh;
    /app/userRun.sh; 
else 
    echo "run userRun.sh"
    /app/userRun.sh; 
fi
pm2 logs hexo_run
