#!/bin/bash
# API 测试脚本

PORT=${1:-8080}
HOST=${2:-localhost}

echo "🧪 测试 Java AI Chat API"
echo "========================"

# 测试健康检查
echo "1. 测试健康检查..."
curl -s "http://$HOST:$PORT/api/v1/status" | python3 -m json.tool

echo ""
echo "2. 测试聊天功能..."
curl -s -X POST "http://$HOST:$PORT/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "你好，请用中文简单介绍一下你自己"}' | python3 -m json.tool

echo ""
echo "3. 测试复杂问题..."
curl -s -X POST "http://$HOST:$PORT/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "用100字简单说明人工智能的发展历史"}' | python3 -m json.tool

echo ""
echo "✅ 测试完成"