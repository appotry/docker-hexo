#!/bin/bash
set -e

IMAGE_NAME="bloodstar/hexo"
CONTAINER_NAME="hexo-test"
TEST_BLOG_DIR="/tmp/hexo-test-blog"
PORT=4000

echo "=== Docker Build Verification ==="

# 1. 构建镜像
echo "Building image..."
docker build -t "$IMAGE_NAME" .

# 2. 验证镜像存在
docker images "$IMAGE_NAME" | grep -q "hexo" || { echo "FAIL: Image not found"; exit 1; }
echo "PASS: Image built successfully"

# 3. 创建测试容器
echo "Creating test container..."
docker create --name="$CONTAINER_NAME" \
  -e HEXO_SERVER_PORT="$PORT" \
  -e GIT_USER="test" \
  -e GIT_EMAIL="test@test.com" \
  -v "$TEST_BLOG_DIR:/app" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME"

docker start "$CONTAINER_NAME"

# 4. 等待初始化完成
echo "Waiting for startup..."
sleep 10

# 5. 验证 HTTP 响应
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "PASS: HTTP server responds 200"
else
  echo "FAIL: HTTP server returned $HTTP_CODE"
  docker logs "$CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
  rm -rf "$TEST_BLOG_DIR"
  exit 1
fi

# 6. 验证 pm2 进程
PM2_STATUS=$(docker exec "$CONTAINER_NAME" pm2 list 2>/dev/null | grep -c "online" || echo "0")
if [ "$PM2_STATUS" -ge 1 ]; then
  echo "PASS: pm2 process is online"
else
  echo "FAIL: pm2 process not online"
  docker logs "$CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
  rm -rf "$TEST_BLOG_DIR"
  exit 1
fi

# 7. 清理
echo "Cleaning up..."
docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
rm -rf "$TEST_BLOG_DIR"

echo "=== All tests passed ==="
