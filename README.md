[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![](https://images.microbadger.com/badges/version/bloodstar/hexo.svg)](https://microbadger.com/images/bloodstar/hexo "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/bloodstar/hexo.svg)](https://microbadger.com/images/bloodstar/hexo "Get your own image badge on microbadger.com")
[![Build Status](https://img.shields.io/docker/cloud/build/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)

## 开始使用

### Docker 版 hexo 环境一键部署

> 博主开源定制，推荐使用！省去您大量环境配置时间。

- [docker-hub](https://hub.docker.com/r/bloodstar/hexo)
- [Github-hexo](https://github.com/appotry/docker-hexo)
- 效果演示 <a title="My Blog Site" target="_blank" href="https://blog.17lai.site/"><img src="https://img.shields.io/badge/%E5%A4%9C%E6%B3%95%E4%B9%8B%E4%B9%A6%E5%8D%9A%E5%AE%A2%20(blog)-blog.17lai.site-orange" /></a>

使用推荐Docker来搭配本文，阅读使用，将更省事，方便，快捷。hexo环境一键搞定！

[![夜法之书博客](https://cimg1.17lai.fun/data/2023/03/14/20230314054551.webp)](https://blog.17lai.site/)

#### Docker一键安装

```bash
docker create --name=hexo \
-e HEXO_SERVER_PORT=4000 \
-e GIT_USER="17lai" \
-e GIT_EMAIL="17lai@domain.tld" \
-v /mnt/blog.17lai.site:/app \
-p 4000:4000 \
bloodstar/hexo
```
#### docker compose 

> 推荐使用 docker compose 来管理docker

```yaml
version: '3'
services:

  hexo:
    container_name: hexo
    image: bloodstar/hexo:latest
    hostname: hexo
    ports:
      - "7800:4000"
    volumes:
      - ${USERDIR}/hexo/blog:/app
    env_file:
      - .env  # 部分公用环境变量放到这里，以是的多个docker之间共享环境变量
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - GIT_USER="appotry"
      - GIT_EMAIL="andycrusoe@gmail.com"
      
      # 主要为了内部npm网络访问顺利
      # - HTTP_PROXY=http://192.168.0.100:1089
      # - HTTPS_PROXY=http://192.168.0.100:1089
    restart: always
```

#### 环境变量


| 环境变量         | 作用                                |
| ---------------- | ----------------------------------- |
| HEXO_SERVER_PORT | pm2 http 服务器运行端口，默认是4000 |
| GIT_USER         | git 环境变量用户名                  |
| GIT_EMAIL        | git 环境变量邮箱                    |


#### ssh key 部署

**Docker会自动随机生成ssh key** 在 /app/.ssh 目录下面。自动部署请把ssh key添加到github 等平台。

[Github详细教程](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

> 1. 将**SSH** 公钥复制到剪贴板。 ...
> 2. 在任何页面的右上角，单击您的个人资料照片，然后单击Settings（设置）。
> 3. 在用户设置侧边栏中，单击**SSH** and GPG keys（**SSH** 和GPG 密钥）。
> 4. 单击New **SSH** key（新**SSH** 密钥）或Add **SSH** key（添加**SSH** 密钥）。

#### 进入docker

```bash
docker exec -it hexo bash
```

然后就可以正常运行hexo的各种命令了，是不是非常简单？ 快来试试吧。

#### 常用命令

```bash
hexo server #启动本地服务器，用于预览主题。Hexo 会监视文件变动并自动更新，除修改站点配置文件外,无须重启服务器,直接刷新网页即可生效。
hexo server -s #以静态模式启动
hexo server -p 4000 #更改访问端口 (默认端口为 5000，’ctrl + c’关闭 server)
hexo server -i IP地址 #自定义 IP
hexo clean #清除缓存 ,网页正常情况下可以忽略此条命令,执行该指令后,会删掉站点根目录下的 public 文件夹
hexo g #生成静态网页 (执行 $ hexo g后会在站点根目录下生成 public 文件夹, hexo 会将”/blog/source/“ 下面的.md 后缀的文件编译为.html 后缀的文件,存放在”/blog/public/ “ 路径下)
hexo d #自动生成网站静态文件，并将本地数据部署到设定的仓库(如 github)
hexo init 文件夹名称 #初始化 XX 文件夹名称
npm update hexo -g#升级
npm install hexo -g #安装
node -v #查看 node.js 版本号
npm -v #查看 npm 版本号
git --version #查看 git 版本号
hexo -v #查看 hexo 版本号
hexo new page “music” #新增页面music
hexo new post “文章名称” #新增文章
```

更详细教程戳这里 [Hexo入门篇](https://blog.17lai.site/posts/40300608/#Hexo%E5%85%A5%E9%97%A8%E7%AF%87)


#### 用户自动运行脚本

> 用户可以在这里添加自动配置，自动安装插件，等各种启动docker运行的命令。

```bash
vi /app/userRun.sh
```

`/app/userRun.sh` 示例

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# 快速添加登录github秘钥
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# 重启内部pm2 服务器
alias repm2='pm2 restart /hexo_run.js'

#### debian 中国区加速
# 如果网络速度快，可以注释
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### npm 配置
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm" 
# npm config set userconfig "/app/.npmrc"
# npm config set registry https://registry.npmmirror.com

npm config set registry https://registry.npmjs.org/

#### history 持久化
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### ssh 配置
#### 避免 "Are you sure you want to continue connecting (yes/no)? yes"
chmod 600 /app/.ssh/id_rsa 
chmod 644 /app/.ssh/id_rsa.pub 
chmod 700 /app/.ssh 
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### npm 插件安装
# 这里用户可以修改自定义安装
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed 

echo "=====User CMD end!====="

```

设置代理
```bash
# 如果网络访问不顺利，可以在访问网络之前添加代理

# 命令行使用代理的方法
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# 使用docker host name 来访问代理，不用IP
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### **完整使用教程**

- [Hexo Docker环境与Hexo基础配置篇](https://blog.17lai.site/posts/40300608/)
- [hexo博客自定义修改篇](https://blog.17lai.site/posts/4d8a0b22/)
- [hexo博客网络优化篇](https://blog.17lai.site/posts/9b056c86/)
- [hexo博客增强部署篇](https://blog.17lai.site/posts/5311b619/)
- [hexo博客个性定制篇](https://blog.17lai.site/posts/4a2050e2/)
- [hexo博客常见问题篇](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown以及各种插件功能测试](https://blog.17lai.site/posts/cf0f47fd/)
- [hexo博客博文撰写篇之完美笔记大攻略终极完全版](https://blog.17lai.site/posts/253706ff/)
- [在 Hexo 博客中插入 ECharts 动态图表](https://blog.17lai.site/posts/217ccdc1/)
- [使用nodeppt给hexo博客嵌入PPT演示](https://blog.17lai.site/posts/546887ac/)
- [Vercel部署高级用法教程](https://blog.17lai.site/posts/e922fac8/)
- [Hexo中文文档](https://hexo.io/zh-cn/docs/)
- [HexoAPI](https://hexo.io/zh-cn/api/)
- [Hexo插件](https://hexo.io/plugins/)

## **Hexo 中文化环境配置**
附加安装一大堆使用插件，并且下载Matery主题

Github: [appotry/docker-hexo](https://github.com/appotry/docker-hexo)

Docker Hub: [bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

Edit From: [spurin/docker-hexo](https://github.com/spurin/docker-hexo)

Dockerfile for [Hexo](https://hexo.io/) with [Hexo Admin](https://github.com/jaredly/hexo-admin)

The image is available directly from [Docker Hub](https://hub.docker.com/r/bloodstar/hexo/)

A tutorial is available at [spurin.com](https://spurin.com/2020/01/04/Creating-a-Blog-Website-with-Docker-Hexo-Github-Free-Hosting-and-HTTPS/)

Latest update locks the node version to 13-slim rather than slim (which at the time of writing is 14), whilst Hexo appears to work for most areas, there is at present an outstanding issue that prevents the `hexo deploy` working with 14.  See [Hexo 4275]( https://github.com/hexojs/hexo/issues/4275)

## Getting Started

Create a new blog container, substitute *domain.com* for your domain and specify your blog location with -v target:/app, specify your git user and email address (for deployment):

```bash
docker create --name=hexo-domain.com \
-e HEXO_SERVER_PORT=4000 \
-e GIT_USER="Your Name" \
-e GIT_EMAIL="your.email@domain.tld" \
-v /blog/domain.com:/app \
-p 4000:4000 \
bloodstar/hexo
```

If a blog is not configured in /app (locally as /blog/domain.com) already, it will be created and Hexo-Admin will be installed into the blog as the container is started

```bash
docker start hexo-domain.com
```

## Accessing the container

Should you wish to perform further configuration, i.e. installing custom themes, this should be viable from the app specific volume, either directly or via the container (changes to the app volume are persistent).  Accessing the container -

```bash
docker exec -it hexo-domain.com bash
```

## Deployment keys for use with Github/Gitlab

Deployment keys are configured as part of the initial app configuration, see the .ssh directory within your app volume or, view the logs upon startup for the SSH public key

```bash
docker logs --follow hexo-domain.com
```

### Installing a theme

Each theme will vary but for example, a theme such as [Hueman](https://github.com/ppoffice/hexo-theme-hueman), clone the repository to the themes directory within the app volume

```bash
cd /app
git clone https://github.com/ppoffice/hexo-theme-hueman.git themes/hueman
```

Update _config.yml in your app folder, and change theme accordingly

```bash
theme: hueman
```

Enable the default configuration

```bash
mv themes/hueman/_config.yml.example themes/hueman/_config.yml
```

Exit the container

```bash
exit
```

And restart the container

```bash
docker restart hexo-domain.com
```

## Accessing Hexo

Access the default hexo blog interface at http://< ip_address >:4000

## Accessing Hexo-Admin

Access Hexo-Admin at http://< ip_address >:4000/admin

## Generating Content

```bash
docker exec -it hexo-domain.com hexo generate
```

## Deploying Generated Content

```bash
docker exec -it hexo-domain.com hexo deploy
```

## Adding hexo plugins

If you wish to add specific hexo plugins, add them to a requirements.txt file to your app volume, for example (app/requirements.txt) -

```bash
hexo-generator-json-content
```

During startup, if the requirements.txt file exists, requirements are auto installed
