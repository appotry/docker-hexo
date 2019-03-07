[![Docker Pulls](https://img.shields.io/docker/pulls/spurin/hexo.svg)](https://hub.docker.com/r/spurin/hexo/)
[![](https://images.microbadger.com/badges/version/spurin/hexo.svg)](https://microbadger.com/images/spurin/hexo "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/spurin/hexo.svg)](https://microbadger.com/images/spurin/hexo "Get your own image badge on microbadger.com")
[![Build Status](https://img.shields.io/docker/cloud/build/spurin/hexo.svg)](https://hub.docker.com/r/spurin/hexo/)

Hexo
============

Dockerfile for [Hexo](https://hexo.io/) with [Hexo Admin](https://github.com/jaredly/hexo-admin)

The image is available directly from [Docker Hub](https://hub.docker.com/r/spurin/hexo/)

## Getting Started

Create a new blog container, substitute *domain.com* for your domain and specify your blog location with -v target:/app:

```
docker create --name=hexo-domain.com \
-e HEXO_SERVER_PORT=4000 \
-v /blog/domain.com:/app \
-p 4000:4000 \
spurin/hexo
```

If a blog is not configured in /app (locally as /blog/domain.com) already, it will be created and Hexo-Admin will be installed into the blog as the container is started

```
docker start hexo-domain.com
```


## Accessing the container

Should you wish to perform further configuration, i.e. installing custom themes or setting up deploy keys, access the Docker container for further configuration

```
docker exec -it hexo-domain.com bash
```

## Examples, when inside the container

### Setup deployment keys for use with Github/Gitlab

Should you wish to deploy your site to an external repository, you may need to have SSH keys configured, whilst in the container, execute the following

```
ssh-keygen
```

After either accepting the defaults, or configuring accordingly, cat the contents of the generated public key, i.e -

```
cat ~/.ssh/id_rsa.pub
```
Using the public key as desired


### Install a theme

Each theme will vary but for example, a theme such as [Hueman](https://github.com/ppoffice/hexo-theme-hueman), clone the repository

```
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
