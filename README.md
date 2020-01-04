[![Docker Pulls](https://img.shields.io/docker/pulls/spurin/hexo.svg)](https://hub.docker.com/r/spurin/hexo/)
[![](https://images.microbadger.com/badges/version/spurin/hexo.svg)](https://microbadger.com/images/spurin/hexo "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/spurin/hexo.svg)](https://microbadger.com/images/spurin/hexo "Get your own image badge on microbadger.com")
[![Build Status](https://img.shields.io/docker/cloud/build/spurin/hexo.svg)](https://hub.docker.com/r/spurin/hexo/)

Hexo
============

Dockerfile for [Hexo](https://hexo.io/) with [Hexo Admin](https://github.com/jaredly/hexo-admin)

The image is available directly from [Docker Hub](https://hub.docker.com/r/spurin/hexo/)

## Getting Started

Create a new blog container, substitute *domain.com* for your domain and specify your blog location with -v target:/app, specify your git user and email address (for deployment):

```
docker create --name=hexo-domain.com \
-e HEXO_SERVER_PORT=4000 \
-e GIT_USER="Your Name" \
-e GIT_EMAIL="your.email@domain.tld" \
-v /blog/domain.com:/app \
-p 4000:4000 \
spurin/hexo
```

If a blog is not configured in /app (locally as /blog/domain.com) already, it will be created and Hexo-Admin will be installed into the blog as the container is started

```
docker start hexo-domain.com
```

## Accessing the container

Should you wish to perform further configuration, i.e. installing custom themes, this should be viable from the app specific volume, either directly or via the container (changes to the app volume are persistent).  Accessing the container -

```
docker exec -it hexo-domain.com bash
```

## Deployment keys for use with Github/Gitlab

Deployment keys are configured as part of the initial app configuration, see the .ssh directory within your app volume or, view the logs upon startup for the SSH public key

```
docker logs --follow hexo-domain.com
```

### Installing a theme

Each theme will vary but for example, a theme such as [Hueman](https://github.com/ppoffice/hexo-theme-hueman), clone the repository to the themes directory within the app volume

```
cd /app
git clone https://github.com/ppoffice/hexo-theme-hueman.git themes/hueman
```

Update _config.yml in your app folder, and change theme accordingly

```
theme: hueman
```

Enable the default configuration

```
mv themes/hueman/_config.yml.example themes/hueman/_config.yml
```

Exit the container

```
exit
```

And restart the container

```
docker restart hexo-domain.com
```

## Accessing Hexo

Access the default hexo blog interface at http://< ip_address >:4000

## Accessing Hexo-Admin

Access Hexo-Admin at http://< ip_address >:4000/admin

## Generating Content

```
docker exec -it hexo-domain.com hexo generate
```

## Deploying Generated Content

```
docker exec -it hexo-domain.com hexo deploy
```

## Adding hexo plugins

If you wish to add specific hexo plugins, add them to a requirements.txt file to your app volume, for example (app/requirements.txt) -

```
hexo-generator-json-content
```

During startup, if the requirements.txt file exists, requirements are auto installed
