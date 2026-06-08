[![Docker Pulls](https://img.shields.io/docker/pulls/bloodstar/hexo.svg)](https://hub.docker.com/r/bloodstar/hexo/)
[![Docker Image Version](https://img.shields.io/docker/v/bloodstar/hexo)](https://hub.docker.com/r/bloodstar/hexo/)
[![Build Status](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml/badge.svg)](https://github.com/appotry/docker-hexo/actions/workflows/Build%20Image.yml)

# docker-hexo

**صورة Docker لبيئة مدونة Hexo** — لا حاجة لتثبيت Node.js / npm / Hexo محلياً.

منشورة على Docker Hub：[bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)

🇬🇧 [English](./README.en.md) · 🇨🇳 [简体中文](./README.md) · 🇭🇰 [繁體中文](./README.zh-TW.md) · 🇯🇵 [日本語](./README.ja.md) · 🇰🇷 [한국어](./README.ko.md)
🇪🇸 [Español](./README.es.md) · 🇫🇷 [Français](./README.fr.md) · 🇩🇪 [Deutsch](./README.de.md) · 🇵🇹 [Português](./README.pt.md) · 🇷🇺 [Русский](./README.ru.md) · 🇸🇦 [العربية](./README.ar.md)

> لماذا نبني مدونة مستقلة خاصة بك؟
> - بطاقة تعريف شخصية!
> - حرية كاملة في التعبير، دون رقابة من الغرباء أو الشركات.

---

## بداية سريعة

### باستخدام docker CLI

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

عند التشغيل الأول، إذا كان `/app` فارغاً، يقوم الحاوية تلقائياً بتشغيل `hexo init` وتثبيت الإضافات الشائعة.

### باستخدام docker compose

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

## متغيرات البيئة

| المتغير | القيمة الافتراضية | الوصف |
|---------|-------------------|-------|
| `HEXO_SERVER_PORT` | `4000` | منفذ استماع خادم Hexo |
| `GIT_USER` | — | اسم مستخدم Git العام |
| `GIT_EMAIL` | — | بريد إلكتروني عام لـ Git |

## مفاتيح SSH

**يقوم Docker بإنشاء مفاتيح SSH تلقائياً** في `/app/.ssh`. أضف المفتاح العام إلى GitHub أو منصات أخرى للنشر.

```bash
# عرض المفتاح العام
docker exec hexo cat /app/.ssh/id_rsa.pub
```

[شرح إضافة مفتاح SSH إلى GitHub](https://docs.github.com/ar/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## الدخول إلى Docker

```bash
docker exec -it hexo bash
```

ادخل إلى الحاوية لتنفيذ أي أوامر hexo.

## تكوين القالب

لكل شخص أذواق مختلفة. إليك بعض القوالب الموصى بها：

- [Matery](https://github.com/blinkfox/hexo-theme-matery)
- [Fluid](https://github.com/fluid-dev/hexo-theme-fluid)
- [Butterfly](https://github.com/jerryc127/hexo-theme-butterfly)
- [Next](https://theme-next.js.org/)

بعد تحميل قالب، قم بتكوينه وفقاً للتعليمات، ثم نفّذ `hexo g` للتوليد. قم بزيارة `http://[docker IP]:4000` لرؤية موقعك.

```bash
cd /app
git clone https://github.com/المستخدم/hexo-theme-xxx.git themes/xxx
```

قم بتحرير `/app/_config.yml`، وضبط `theme: xxx`، ثم نفّذ `hexo g` لإعادة التوليد.

## السكربت المخصص للمستخدم

أضف أوامر التكوين التلقائي وتثبيت الإضافات التي تعمل عند بدء تشغيل Docker.

قم بتحرير `/app/userRun.sh`：

```bash
#!/bin/bash

echo "add User CMD here!"

echo "=====User CMD Start!====="
# اختصار سريع لتسجيل الدخول إلى GitHub
alias github='eval "$(/usr/bin/ssh-agent -s)";/usr/bin/ssh-add ~/.ssh/id_rsa'
# إعادة تشغيل خادم pm2 الداخلي
alias repm2='pm2 restart /hexo_run.js'

#### مرآة Debian الصينية (قم بتعليقها إذا كانت شبكتك سريعة)
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

#### إعدادات npm
npm config ls -l

mkdir -p /app/.cache/npm
npm config set cache "/app/.cache/npm"
npm config set registry https://registry.npmjs.org/

#### استمرارية السجل
rm -rfv ~/.bash_history
ln -s /app/.bash_history ~/.bash_history

#### إعدادات ssh
chmod 600 /app/.ssh/id_rsa
chmod 644 /app/.ssh/id_rsa.pub
chmod 700 /app/.ssh
rm -rfv ~/.ssh
ln -s /app/.ssh ~/.ssh

#### تثبيت إضافات npm
npm install --save \
    hexo-admin \
    hexo-include-markdown \
    hexo-douban-card-new \
    hexo-github-card \
    hexo-bilibili-card-new \
    hexo-feed

echo "=====User CMD end!====="
```

إذا كانت الشبكة بطيئة، قم بإعداد وكيل قبل الطلبات الشبكية：

```bash
export http_proxy=http://192.168.0.100:1089;export https_proxy=http://192.168.0.100:1089

# استخدام اسم مضيف Docker للوكيل (موصى به)
export http_proxy=http://xray:1089;export https_proxy=http://xray:1089
```

### requirements.txt

أضف ملف `requirements.txt` إلى مجلد مدونتك (حزمة npm واحدة في كل سطر). يتم تثبيت الحزم تلقائياً عند بدء التشغيل：

```txt
hexo-generator-json-content
hexo-generator-feed
```

## الأوامر الشائعة

| الإجراء | الأمر |
|---------|-------|
| الدخول إلى الحاوية | `docker exec -it hexo bash` |
| عرض السجلات | `docker logs --follow hexo` |
| إعادة تشغيل pm2 | `docker exec hexo pm2 restart /hexo_run.js` |
| إعادة تشغيل الحاوية | `docker restart hexo` |
| إنشاء الملفات الثابتة | `docker exec hexo hexo g` |
| النشر إلى خادم بعيد | `docker exec hexo hexo d` |
| مقال جديد | `docker exec hexo hexo new post "عنوان المقال"` |
| صفحة جديدة | `docker exec hexo hexo new page "music"` |
| مسح الذاكرة المخبأة | `docker exec hexo hexo clean` |

## اختصارات سريعة

أضف هذه الاختصارات إلى ملف `~/.bashrc` أو `~/.zshrc` لاستخدام أوامر hexo دون كتابة `docker exec` في كل مرة：

```bash
# اختصارات حاوية hexo
alias hexo='docker exec -it hexo hexo'
alias hexo-shell='docker exec -it hexo bash'
alias hexo-logs='docker logs --follow hexo'
alias hexo-restart='docker exec hexo pm2 restart /hexo_run.js'
alias hexo-reboot='docker restart hexo'

# hexo new post "عنواني"
# hexo g
# hexo d
# hexo clean
```

قم بتشغيل `source ~/.bashrc` لتفعيلها، ثم استخدم مباشرة：

```bash
hexo new post "مقالي الجديد"
hexo g
hexo d
hexo-shell
```

## المعاينة المباشرة

يدعم Hexo إعادة التحميل التلقائي عند تغيير الملفات. بعد تحرير مقال أو قالب، قم بتحديث المتصفح لرؤية التغييرات.

إذا لم يتم تطبيق التغييرات، فقد يكون ذاكرة التخزين المؤقت لـ node قديمة. أعد تشغيل خدمة الويب：

```bash
# إعادة تشغيل pm2
pm2 restart /hexo_run.js

# إعادة تشغيل Docker hexo
docker restart hexo
```

## الدروس الكاملة

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
- [وثائق Hexo](https://hexo.io/ar/docs/)
- [API Hexo](https://hexo.io/ar/api/)
- [إضافات Hexo](https://hexo.io/plugins/)

## التوثيق

| المستند | الوصف |
|---------|-------|
| [AGENTS.md](./AGENTS.md) | اتفاقيات AI، الأوامر، معايير الهندسة |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | البنية، المكونات، تدفق البيانات |
| [docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md) | المتطلبات الوظيفية وغير الوظيفية |
| [docs/TESTING.md](./docs/TESTING.md) | استراتيجية الاختبار، التحقق من بناء Docker |
| [docs/CHANGELOG.md](./docs/CHANGELOG.md) | تاريخ الإصدارات |

## الموارد

- [وثائق Hexo](https://hexo.io/ar/docs/)
- [Docker Hub — bloodstar/hexo](https://hub.docker.com/r/bloodstar/hexo)
- المشروع الأصلي：[spurin/docker-hexo](https://github.com/spurin/docker-hexo)
