#!/bin/bash
# Docker部署脚本

set -e

echo "🚀 Java AI Starter Docker部署"
echo "=============================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker已安装${NC}"
}

# 检查环境文件
check_env() {
    if [ ! -f ".env.docker" ]; then
        echo -e "${YELLOW}⚠️  未找到.env.docker文件${NC}"
        echo "创建默认环境文件..."
        cat > .env.docker << EOF
# Docker环境配置
AI_API_KEY=sk-1899062c03f640f090129c4692ccc26f
AI_BASE_URL=https://api.deepseek.com
AI_MODEL=deepseek-chat
AI_MAX_TOKENS=1000
AI_TIMEOUT=30000

SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=docker

# 数据库配置（可选）
# DB_HOST=postgres
# DB_PORT=5432
# DB_PASSWORD=ai_password

# Redis配置（可选）
# REDIS_HOST=redis
# REDIS_PORT=6379
EOF
        echo -e "${GREEN}✅ 已创建.env.docker文件${NC}"
    fi
    
    # 加载环境变量（排除包含特殊字符的行）
    if [ -f ".env.docker" ]; then
        echo "加载环境变量..."
        # 只加载简单的KEY=VALUE行，排除包含JVM参数的行
        while IFS= read -r line; do
            # 跳过注释和空行
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            # 跳过包含JVM参数的行
            [[ "$line" =~ .*=.*-Xmx.* ]] && continue
            [[ "$line" =~ .*=.*-Xms.* ]] && continue
            [[ "$line" =~ .*=.*-XX:.* ]] && continue
            
            # 导出有效的环境变量
            export "$line" 2>/dev/null || echo "跳过: $line"
        done < .env.docker
    fi
}

# 构建Docker镜像
build_image() {
    echo -e "${BLUE}🔨 构建Docker镜像...${NC}"
    docker build -t java-ai-starter:latest .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker镜像构建成功${NC}"
    else
        echo -e "${RED}❌ Docker镜像构建失败${NC}"
        exit 1
    fi
}

# 运行Docker容器
run_container() {
    echo -e "${BLUE}🐳 启动Docker容器...${NC}"
    
    # 停止并删除现有容器
    if docker ps -a | grep -q "java-ai-starter"; then
        echo "停止现有容器..."
        docker stop java-ai-starter 2>/dev/null || true
        docker rm java-ai-starter 2>/dev/null || true
    fi
    
    # 运行新容器
    docker run -d \
        --name java-ai-starter \
        --restart unless-stopped \
        -p ${SERVER_PORT:-8080}:8080 \
        -e AI_API_KEY="${AI_API_KEY}" \
        -e AI_BASE_URL="${AI_BASE_URL:-https://api.deepseek.com}" \
        -e AI_MODEL="${AI_MODEL:-deepseek-chat}" \
        -e AI_MAX_TOKENS="${AI_MAX_TOKENS:-1000}" \
        -e AI_TIMEOUT="${AI_TIMEOUT:-30000}" \
        -e SPRING_PROFILES_ACTIVE="${SPRING_PROFILES_ACTIVE:-docker}" \
        -e SERVER_PORT=8080 \
        -v $(pwd)/logs:/app/logs \
        -v $(pwd)/config:/app/config \
        java-ai-starter:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker容器启动成功${NC}"
    else
        echo -e "${RED}❌ Docker容器启动失败${NC}"
        exit 1
    fi
}

# 检查容器状态
check_status() {
    echo -e "${BLUE}🔍 检查容器状态...${NC}"
    
    sleep 3
    
    # 检查容器是否运行
    if docker ps | grep -q "java-ai-starter"; then
        echo -e "${GREEN}✅ 容器正在运行${NC}"
    else
        echo -e "${RED}❌ 容器未运行${NC}"
        docker logs java-ai-starter --tail 20
        exit 1
    fi
    
    # 检查健康状态
    echo "等待应用启动..."
    sleep 5
    
    # 测试API
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "尝试 $attempt/$max_attempts..."
        if curl -s http://localhost:${SERVER_PORT:-8080}/api/v1/ping > /dev/null 2>&1; then
            echo -e "${GREEN}✅ API响应正常${NC}"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo -e "${RED}❌ API未响应${NC}"
            docker logs java-ai-starter --tail 30
            exit 1
        fi
        
        sleep 5
        ((attempt++))
    done
}

# 显示部署信息
show_info() {
    local port=${SERVER_PORT:-8080}
    
    echo ""
    echo -e "${GREEN}🎉 部署完成！${NC}"
    echo "========================"
    echo "📊 部署信息:"
    echo "  - 容器名称: java-ai-starter"
    echo "  - 主机端口: $port"
    echo "  - 容器端口: 8080"
    echo "  - 镜像标签: java-ai-starter:latest"
    echo ""
    echo "🌐 访问地址:"
    echo "  - http://localhost:$port"
    echo ""
    echo "📋 测试命令:"
    echo "  curl http://localhost:$port/api/v1/ping"
    echo "  curl -X POST http://localhost:$port/api/v1/chat/text \\"
    echo "    -H \"Content-Type: application/json\" \\"
    echo "    -d '{\"message\":\"你好\"}'"
    echo ""
    echo "🔧 管理命令:"
    echo "  # 查看日志"
    echo "  docker logs -f java-ai-starter"
    echo ""
    echo "  # 进入容器"
    echo "  docker exec -it java-ai-starter sh"
    echo ""
    echo "  # 停止容器"
    echo "  docker stop java-ai-starter"
    echo ""
    echo "  # 删除容器"
    echo "  docker rm java-ai-starter"
    echo ""
    echo "  # 删除镜像"
    echo "  docker rmi java-ai-starter:latest"
}

# 主函数
main() {
    check_docker
    check_env
    build_image
    run_container
    check_status
    show_info
}

# 执行主函数
main "$@"