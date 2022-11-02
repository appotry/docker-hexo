[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![](https://images.microbadger.com/badges/version/bloodstar/hexo.svg)](https://microbadger.com/images/bloodstar/hexo "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/bloodstar/hexo.svg)](https://microbadger.com/images/bloodstar/hexo "Get your own image badge on microbadger.com")
[![Build Status](https://img.shields.io/docker/cloud/build/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)

## 开始使用

### Docker 版 hexo 环境一键部署

> 博主开源定制，推荐使用！省去您大量环境配置时间。

- [docker-hub](https://hub.docker.com/r/bloodstar/hexo)
- [Github-hexo](https://github.com/appotry/docker-hexo)

使用推荐Docker来搭配本文，阅读使用，将更省事，方便，快捷。hexo环境一键搞定！

#### Docker一键安装

```yaml
docker create --name=hexo \
-e HEXO_SERVER_PORT=4000 \
-e GIT_USER="17lai" \
-e GIT_EMAIL="17lai@domain.tld" \
-v /mnt/blog.17lai.site:/app \
-p 4000:4000 \
bloodstar/hexo
```

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

#### 用户自动运行脚本

> 用户可以在这里添加自动配置，自动安装插件，等各种启动docker运行的命令。

```bash
vi /app/userRun.sh
```

### **完整使用教程**

- [Hexo Docker环境与Hexo基础配置篇](https://blog.17lai.site/posts/40300608/)
- [hexo博客自定义修改篇](https://blog.17lai.site/posts/4d8a0b22/)
- [hexo博客网络优化篇](https://blog.17lai.site/posts/9b056c86/)
- [hexo博客增强部署篇](https://blog.17lai.site/posts/5311b619/)
- [hexo博客个性定制篇](https://blog.17lai.site/posts/4a2050e2/)
- [hexo博客常见问题篇](https://blog.17lai.site/posts/84b4059a/)
- [Hexo Markdown以及各种插件功能测试](https://blog.17lai.site/posts/cf0f47fd/)
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
