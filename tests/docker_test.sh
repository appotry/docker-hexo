#!/bin/bash
set -e

IMAGE_NAME="bloodstar/hexo"
CONTAINER_NAME="hexo-test"
TEST_BLOG_DIR="/tmp/hexo-test-blog"
PORT=4000
REPORT_DIR="test-reports"
REPORT_FILE="${REPORT_DIR}/report-$(date +%Y%m%d-%H%M%S).md"
PASS_COUNT=0
FAIL_COUNT=0

mkdir -p "$REPORT_DIR"

report() {
  echo "$1" >> "$REPORT_FILE"
}

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "PASS" ]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "PASS: $desc"
    report "- [x] **$desc** ✅ PASS"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "FAIL: $desc"
    report "- [ ] **$desc** ❌ FAIL"
  fi
}

# Init report
cat > "$REPORT_FILE" <<EOF
# Test Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Image:** ${IMAGE_NAME}
**OS:** $(uname -srm)

## Results

EOF

echo "=== Docker Build Verification ==="

# 1. Build
echo "Building image..."
BUILD_OUT=$(docker build -t "$IMAGE_NAME" . 2>&1) && check "Docker image build" "PASS" || check "Docker image build" "FAIL"

# 2. Image info
IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "{{.Size}}" 2>/dev/null)
IMAGE_CREATED=$(docker images "$IMAGE_NAME" --format "{{.CreatedAt}}" 2>/dev/null)
report ""
report "## Image Info"
report ""
report "| Item | Value |"
report "|------|-------|"
report "| Size | ${IMAGE_SIZE} |"
report "| Created | ${IMAGE_CREATED} |"

# 3. Create test container
echo "Creating test container..."
docker create --name="$CONTAINER_NAME" \
  -e HEXO_SERVER_PORT="$PORT" \
  -e GIT_USER="test" \
  -e GIT_EMAIL="test@test.com" \
  -v "$TEST_BLOG_DIR:/app" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME" > /dev/null 2>&1

docker start "$CONTAINER_NAME" > /dev/null 2>&1

# 4. Wait for init
echo "Waiting for startup..."
sleep 15

# 5. HTTP test
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  check "HTTP server responds 200" "PASS"
else
  check "HTTP server responds 200 (got $HTTP_CODE)" "FAIL"
fi

# 6. pm2 check
PM2_STATUS=$(docker exec "$CONTAINER_NAME" pm2 list 2>/dev/null | grep -c "online" || echo "0")
if [ "$PM2_STATUS" -ge 1 ]; then
  check "pm2 process is online" "PASS"
else
  check "pm2 process is online" "FAIL"
fi

# 7. Version info
report ""
report "## Environment"
report ""
report "| Software | Version |"
report "|----------|---------|"

# node version
NODE_VER=$(docker exec "$CONTAINER_NAME" node -v 2>/dev/null || echo "N/A")
report "| Node.js | ${NODE_VER} |"

# npm version
NPM_VER=$(docker exec "$CONTAINER_NAME" npm -v 2>/dev/null || echo "N/A")
report "| npm | ${NPM_VER} |"

# git version
GIT_VER=$(docker exec "$CONTAINER_NAME" git --version 2>/dev/null | awk '{print $3}' || echo "N/A")
report "| Git | ${GIT_VER} |"

# Cleanup
echo "Cleaning up..."
docker stop "$CONTAINER_NAME" > /dev/null 2>&1
docker rm "$CONTAINER_NAME" > /dev/null 2>&1
chmod -R 777 "$TEST_BLOG_DIR" 2>/dev/null || true
rm -rf "$TEST_BLOG_DIR" 2>/dev/null || true

# Summary
TOTAL=$((PASS_COUNT + FAIL_COUNT))
report ""
report "## Summary"
report ""
report "| Status | Count |"
report "|--------|-------|"
report "| Total | ${TOTAL} |"
report "| ✅ Passed | ${PASS_COUNT} |"
if [ "$FAIL_COUNT" -gt 0 ]; then
  report "| ❌ Failed | ${FAIL_COUNT} |"
  report ""
  report "**Result:** ❌ FAILED"
else
  report "| ✅ Failed | 0 |"
  report ""
  report "**Result:** ✅ ALL TESTS PASSED"
fi

echo ""
echo "=== Report saved to ${REPORT_FILE} ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
