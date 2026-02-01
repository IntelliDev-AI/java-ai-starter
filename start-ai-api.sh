#!/bin/bash
# Java AI Chat API 启动脚本

echo "🚀 启动 Java AI Chat API"
echo "=============================="

# 检查环境变量
if [ -f .env ]; then
    echo "📁 加载环境变量..."
    export $(grep -v '^#' .env | xargs)
fi

# 检查API Key
if [ -z "$AI_API_KEY" ] || [ "$AI_API_KEY" = "your_ai_api_key_here" ]; then
    echo "❌ 错误: AI_API_KEY 未配置或为默认值"
    echo "请在 .env 文件中设置有效的 AI API Key"
    exit 1
fi

echo "✅ API Key 已配置"
echo "📊 配置信息:"
echo "  - 模型: ${AI_MODEL:-deepseek-chat}"
echo "  - 基础URL: ${AI_BASE_URL:-https://api.deepseek.com}"
echo "  - 端口: ${SERVER_PORT:-8080}"
echo "  - 最大Token: ${AI_MAX_TOKENS:-1000}"

# 构建项目
echo "🔨 构建项目..."
mvn clean package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "❌ 构建失败"
    exit 1
fi

echo "✅ 构建成功"

# 启动应用
echo "🎯 启动应用..."
echo "🌐 访问地址: http://localhost:${SERVER_PORT:-8080}"
echo "📝 测试命令:"
echo "  curl http://localhost:${SERVER_PORT:-8080}/api/v1/status"
echo "  curl -X POST http://localhost:${SERVER_PORT:-8080}/api/v1/chat \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"message\": \"你好，介绍一下你自己\"}'"
echo ""
echo "📋 按 Ctrl+C 停止应用"

# 运行应用
java -jar target/java-ai-starter-*.jar