#!/bin/bash
set -e

echo "🚀 启动 Java AI Starter 应用 (Docker)"

# 检查必要的环境变量
if [ -z "$AI_API_KEY" ] || [ "$AI_API_KEY" = "your_ai_api_key_here" ]; then
    echo "⚠️  警告: AI_API_KEY 未设置或为默认值"
    echo "   请设置有效的 AI API Key"
    echo "   当前运行在演示模式"
    export AI_ENABLED=false
else
    echo "✅ AI_API_KEY 已配置"
    export AI_ENABLED=true
fi

# 设置JVM参数
if [ -z "$JAVA_OPTS" ]; then
    export JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
fi

# 添加Spring Boot Actuator配置
export JAVA_OPTS="$JAVA_OPTS -Dmanagement.endpoints.web.exposure.include=health,info,metrics"
export JAVA_OPTS="$JAVA_OPTS -Dmanagement.endpoint.health.show-details=always"

# 日志配置
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.name=/app/logs/application.log"
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.max-size=10MB"
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.max-history=10"
export JAVA_OPTS="$JAVA_OPTS -Dlogging.pattern.console='%d{yyyy-MM-dd HH:mm:ss} - %msg%n'"

# 应用配置
export JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-docker}"
export JAVA_OPTS="$JAVA_OPTS -Dai.enabled=${AI_ENABLED:-true}"
export JAVA_OPTS="$JAVA_OPTS -Dai.api-key=${AI_API_KEY:-}"
export JAVA_OPTS="$JAVA_OPTS -Dai.model=${AI_MODEL:-deepseek-chat}"
export JAVA_OPTS="$JAVA_OPTS -Dai.base-url=${AI_BASE_URL:-https://api.deepseek.com}"
export JAVA_OPTS="$JAVA_OPTS -Dai.timeout=${AI_TIMEOUT:-30000}"
export JAVA_OPTS="$JAVA_OPTS -Dai.max-tokens=${AI_MAX_TOKENS:-1000}"
export JAVA_OPTS="$JAVA_OPTS -Dserver.port=${SERVER_PORT:-8080}"

echo "📊 环境配置:"
echo "  - Spring Profile: ${SPRING_PROFILES_ACTIVE:-docker}"
echo "  - AI Enabled: ${AI_ENABLED:-true}"
echo "  - AI Model: ${AI_MODEL:-deepseek-chat}"
echo "  - Server Port: ${SERVER_PORT:-8080}"
echo "  - JVM Options: $JAVA_OPTS"

# 等待数据库就绪（如果配置了数据库）
if [ -n "$DB_HOST" ] && [ -n "$DB_PORT" ]; then
    echo "⏳ 等待数据库服务就绪..."
    while ! nc -z $DB_HOST $DB_PORT; do
        sleep 1
    done
    echo "✅ 数据库连接就绪"
fi

# 启动应用
echo "🎯 启动应用程序..."
exec java $JAVA_OPTS -jar app.jar "$@"