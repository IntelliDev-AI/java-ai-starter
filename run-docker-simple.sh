#!/bin/bash
# 简单的Docker运行脚本

echo "🚀 启动Java AI Starter (简单Docker模式)"

# 检查是否已有容器在运行
if docker ps | grep -q "java-ai-simple"; then
    echo "停止现有容器..."
    docker stop java-ai-simple
    docker rm java-ai-simple
fi

# 使用现有jar文件运行
echo "构建Docker镜像..."
docker build -t java-ai-simple:latest .

echo "启动容器..."
docker run -d \
  --name java-ai-simple \
  -p 8080:8080 \
  -e AI_API_KEY=${AI_API_KEY:-} \
  -e AI_MODEL=deepseek-chat \
  -e AI_BASE_URL=https://api.deepseek.com \
  java-ai-simple:latest

echo "✅ 容器已启动"
echo "📊 访问地址: http://localhost:8080"
echo "🔍 查看日志: docker logs -f java-ai-simple"
echo "🛑 停止容器: docker stop java-ai-simple"