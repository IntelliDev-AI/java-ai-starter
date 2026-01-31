#!/bin/bash
set -e

echo "🚀 启动 Java AI Starter 应用"

# 检查必要的环境变量
if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "sk-demo-key" ]; then
    echo "⚠️  警告: OPENAI_API_KEY 未设置或为默认值"
    echo "   请设置有效的 OpenAI API Key"
    echo "   临时使用示例模式..."
fi

# 设置JVM参数
if [ -z "$JAVA_OPTS" ]; then
    export JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
fi

# 添加Spring Boot Actuator配置
export JAVA_OPTS="$JAVA_OPTS -Dmanagement.endpoints.web.exposure.include=health,info,metrics,prometheus"
export JAVA_OPTS="$JAVA_OPTS -Dmanagement.endpoint.health.show-details=always"
export JAVA_OPTS="$JAVA_OPTS -Dmanagement.metrics.export.prometheus.enabled=true"

# 日志配置
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.name=/app/logs/application.log"
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.max-size=10MB"
export JAVA_OPTS="$JAVA_OPTS -Dlogging.file.max-history=10"

echo "📊 环境配置:"
echo "  - Spring Profile: ${SPRING_PROFILES_ACTIVE:-default}"
echo "  - OpenAI Model: ${OPENAI_MODEL:-gpt-3.5-turbo}"
echo "  - Server Port: ${SERVER_PORT:-8080}"
echo "  - JVM Options: $JAVA_OPTS"

# 等待数据库就绪（如果配置了数据库）
if [ "$SPRING_PROFILES_ACTIVE" = "docker" ] || [ "$SPRING_PROFILES_ACTIVE" = "production" ]; then
    echo "⏳ 检查依赖服务..."
    
    # 这里可以添加等待数据库、Redis等服务的逻辑
    # 例如: wait-for-it.sh postgres:5432 --timeout=30
fi

# 启动应用
echo "🎯 启动应用程序..."
exec java $JAVA_OPTS -jar app.jar "$@"
