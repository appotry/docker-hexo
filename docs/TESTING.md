# 测试策略

本项目是 Docker 镜像，测试重点是构建验证和运行时验证。

## 构建验证

```bash
# 构建镜像
docker build -t bloodstar/hexo .

# 验证构建成功
docker images bloodstar/hexo
# 应看到刚刚构建的镜像
```

## 运行时验证

```bash
# 创建并启动测试容器
docker create --name=hexo-test \
  -e HEXO_SERVER_PORT=4000 \
  -e GIT_USER="test" \
  -e GIT_EMAIL="test@test.com" \
  -v /tmp/hexo-test-blog:/app \
  -p 4000:4000 \
  bloodstar/hexo

docker start hexo-test

# 等待启动
sleep 5

# 验证 hexo server 是否响应
curl -s -o /dev/null -w "%{http_code}" http://localhost:4000
# 应返回 200

# 验证容器内 pm2 进程
docker exec hexo-test pm2 list
# 应显示 hexo_run 进程状态为 online

# 快速清理
docker stop hexo-test && docker rm hexo-test && rm -rf /tmp/hexo-test-blog
```

## CI 行为

CI 工作流（`.github/workflows/Build Image.yml`）不会运行上述测试，仅执行多架构构建并推送。如需在 CI 中加入测试，需添加测试步骤。

## 自动化测试脚本

参见 `tests/docker_test.sh`。
