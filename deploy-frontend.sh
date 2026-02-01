#!/bin/bash
# 前端部署脚本

set -e  # 遇到错误退出

echo "🚀 开始部署Java AI Starter前端..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 服务器信息
SERVER_IP="81.70.234.241"
PRIVATE_KEY="/home/zhuyinhang/tenxunyunfuwuqimiyao/beijinshili.pem"
FRONTEND_DIR="/home/zhuyinhang/.openclaw/workspace/java-ai-starter/frontend"

# 检查必要文件
check_prerequisites() {
    echo -e "${BLUE}🔍 检查前置条件...${NC}"
    
    if [ ! -f "$PRIVATE_KEY" ]; then
        echo -e "${RED}❌ 私钥文件不存在: $PRIVATE_KEY${NC}"
        exit 1
    fi
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        echo -e "${RED}❌ 前端目录不存在: $FRONTEND_DIR${NC}"
        exit 1
    fi
    
    chmod 600 "$PRIVATE_KEY"
    echo -e "${GREEN}✅ 前置条件检查通过${NC}"
}

# 构建前端
build_frontend() {
    echo -e "${BLUE}🔨 构建前端项目...${NC}"
    
    cd "$FRONTEND_DIR"
    
    # 检查是否已安装依赖
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}📦 安装依赖...${NC}"
        npm install --no-optional --silent
    fi
    
    echo -e "${YELLOW}🏗️  构建生产版本...${NC}"
    npm run build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 前端构建成功${NC}"
        echo -e "${BLUE}📁 构建文件位置: $FRONTEND_DIR/dist${NC}"
    else
        echo -e "${RED}❌ 前端构建失败${NC}"
        exit 1
    fi
}

# 部署到服务器
deploy_to_server() {
    echo -e "${BLUE}🚚 部署到服务器 $SERVER_IP...${NC}"
    
    # 检查服务器连接
    echo -e "${YELLOW}🔗 测试服务器连接...${NC}"
    ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no root@"$SERVER_IP" "echo '✅ 服务器连接成功'" || {
        echo -e "${RED}❌ 服务器连接失败${NC}"
        exit 1
    }
    
    # 上传构建文件
    echo -e "${YELLOW}📤 上传前端文件...${NC}"
    scp -i "$PRIVATE_KEY" -r "$FRONTEND_DIR/dist/"* root@"$SERVER_IP":/usr/share/nginx/html/ 2>/dev/null || {
        echo -e "${RED}❌ 文件上传失败${NC}"
        exit 1
    }
    
    # 设置文件权限
    echo -e "${YELLOW}🔧 设置文件权限...${NC}"
    ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no root@"$SERVER_IP" "
        chown -R nginx:nginx /usr/share/nginx/html
        chmod -R 755 /usr/share/nginx/html
    "
    
    # 重启Nginx
    echo -e "${YELLOW}🔄 重启Nginx服务...${NC}"
    ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no root@"$SERVER_IP" "
        nginx -t && systemctl restart nginx
    "
    
    echo -e "${GREEN}✅ 部署完成${NC}"
}

# 测试部署
test_deployment() {
    echo -e "${BLUE}🧪 测试部署...${NC}"
    
    # 等待Nginx重启
    sleep 2
    
    # 测试健康检查
    echo -e "${YELLOW}📊 测试健康检查...${NC}"
    HEALTH_CHECK=$(curl -s "http://$SERVER_IP/health" || echo "FAILED")
    if [ "$HEALTH_CHECK" = "healthy" ]; then
        echo -e "${GREEN}✅ 健康检查通过${NC}"
    else
        echo -e "${YELLOW}⚠️  健康检查未配置或返回: $HEALTH_CHECK${NC}"
    fi
    
    # 测试后端API
    echo -e "${YELLOW}🔗 测试后端API连接...${NC}"
    API_CHECK=$(curl -s "http://$SERVER_IP:8080/api/v1/ping" || echo "FAILED")
    if [[ "$API_CHECK" == *"pong"* ]]; then
        echo -e "${GREEN}✅ 后端API连接正常${NC}"
    else
        echo -e "${YELLOW}⚠️  后端API连接测试返回: $API_CHECK${NC}"
    fi
    
    # 显示访问信息
    echo -e "${BLUE}🌐 部署信息:${NC}"
    echo -e "   前端访问: ${GREEN}http://$SERVER_IP${NC}"
    echo -e "   后端API: ${GREEN}http://$SERVER_IP:8080/api/v1${NC}"
    echo -e "   健康检查: ${GREEN}http://$SERVER_IP/health${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}    Java AI Starter 前端部署脚本    ${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_prerequisites
    build_frontend
    deploy_to_server
    test_deployment
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}🎉 前端部署完成！${NC}"
    echo -e "${YELLOW}📋 下一步:${NC}"
    echo -e "   1. 访问 http://$SERVER_IP 测试前端"
    echo -e "   2. 检查聊天功能是否正常"
    echo -e "   3. 查看服务器日志: ssh root@$SERVER_IP 'journalctl -u nginx -f'"
    echo -e "${BLUE}========================================${NC}"
}

# 执行主函数
main "$@"