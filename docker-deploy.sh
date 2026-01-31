#!/bin/bash
# Java AI Starter Docker部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Java AI Starter Docker部署工具${NC}"
echo "======================================"

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker未安装${NC}"
        echo "请先安装Docker："
        echo "  Ubuntu: sudo apt-get install docker.io"
        echo "  CentOS: sudo yum install docker"
        echo "  macOS: https://docs.docker.com/desktop/install/mac-install/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker Compose未安装${NC}"
        echo "尝试使用docker compose插件..."
        if ! docker compose version &> /dev/null; then
            echo -e "${RED}❌ Docker Compose未找到${NC}"
            echo "请安装Docker Compose："
            echo "  https://docs.docker.com/compose/install/"
            exit 1
        fi
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
    
    echo -e "${GREEN}✅ Docker环境检查通过${NC}"
}

# 检查环境配置
check_env() {
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️  未找到.env文件${NC}"
        echo "正在从模板创建.env文件..."
        if [ -f ".env.docker" ]; then
            cp .env.docker .env
            echo -e "${YELLOW}📝 请编辑.env文件，配置你的API Key和其他参数${NC}"
            echo "重要：修改 AI_API_KEY=你的DeepSeek_API_Key"
            exit 1
        else
            echo -e "${RED}❌ 未找到环境模板文件${NC}"
            exit 1
        fi
    fi
    
    # 检查API Key是否配置
    if grep -q "AI_API_KEY=your_deepseek_api_key_here" .env || \
       grep -q "AI_API_KEY=$" .env || \
       ! grep -q "AI_API_KEY=" .env; then
        echo -e "${YELLOW}⚠️  AI_API_KEY未配置或为默认值${NC}"
        echo "应用将以演示模式运行"
        read -p "是否继续？(y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "请编辑.env文件配置AI_API_KEY后重新运行"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ 环境配置检查通过${NC}"
}

# 构建Docker镜像
build_image() {
    echo -e "${BLUE}🔨 构建Docker镜像...${NC}"
    $DOCKER_COMPOSE build --no-cache
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker镜像构建成功${NC}"
    else
        echo -e "${RED}❌ Docker镜像构建失败${NC}"
        exit 1
    fi
}

# 启动服务
start_services() {
    echo -e "${BLUE}🚀 启动服务...${NC}"
    
    local services="java-ai-app"
    
    read -p "是否启动完整服务栈（包含数据库、Redis、监控）？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        services="java-ai-app postgres redis"
        echo -e "${YELLOW}📊 将启动完整服务栈${NC}"
    else
        echo -e "${YELLOW}📊 仅启动主应用${NC}"
    fi
    
    $DOCKER_COMPOSE up -d $services
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 服务启动成功${NC}"
    else
        echo -e "${RED}❌ 服务启动失败${NC}"
        exit 1
    fi
}

# 检查服务状态
check_status() {
    echo -e "${BLUE}📊 检查服务状态...${NC}"
    
    sleep 5
    
    echo "容器状态："
    $DOCKER_COMPOSE ps
    
    echo ""
    echo -e "${YELLOW}⏳ 等待应用启动...${NC}"
    
    # 等待应用健康检查
    for i in {1..30}; do
        if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 应用启动成功！${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    echo ""
    echo -e "${BLUE}🔗 服务访问信息：${NC}"
    echo "主应用：http://localhost:8080"
    echo "健康检查：http://localhost:8080/api/health"
    echo "测试接口：http://localhost:8080/api/test"
    
    if $DOCKER_COMPOSE ps | grep -q "postgres"; then
        echo "数据库：localhost:5432 (用户: ai_user, 数据库: ai_starter)"
    fi
    
    if $DOCKER_COMPOSE ps | grep -q "redis"; then
        echo "Redis：localhost:6379"
    fi
}

# 停止服务
stop_services() {
    echo -e "${YELLOW}🛑 停止服务...${NC}"
    $DOCKER_COMPOSE down
    echo -e "${GREEN}✅ 服务已停止${NC}"
}

# 查看日志
view_logs() {
    echo -e "${BLUE}📋 查看应用日志：${NC}"
    $DOCKER_COMPOSE logs -f java-ai-app
}

# 清理资源
cleanup() {
    echo -e "${YELLOW}🧹 清理Docker资源...${NC}"
    
    read -p "是否删除所有容器和镜像？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $DOCKER_COMPOSE down -v --rmi all
        echo -e "${GREEN}✅ 所有Docker资源已清理${NC}"
    else
        $DOCKER_COMPOSE down
        echo -e "${GREEN}✅ 容器已停止${NC}"
    fi
}

# 显示菜单
show_menu() {
    echo ""
    echo -e "${BLUE}请选择操作：${NC}"
    echo "1) 完整部署（检查环境 + 构建 + 启动）"
    echo "2) 仅构建Docker镜像"
    echo "3) 启动服务"
    echo "4) 停止服务"
    echo "5) 查看日志"
    echo "6) 检查服务状态"
    echo "7) 清理Docker资源"
    echo "8) 退出"
    echo ""
}

# 主函数
main() {
    check_docker
    
    case $1 in
        "build")
            check_env
            build_image
            ;;
        "start")
            check_env
            start_services
            check_status
            ;;
        "stop")
            stop_services
            ;;
        "logs")
            view_logs
            ;;
        "status")
            check_status
            ;;
        "clean")
            cleanup
            ;;
        "full")
            check_env
            build_image
            start_services
            check_status
            ;;
        *)
            while true; do
                show_menu
                read -p "请输入选项 [1-8]: " choice
                
                case $choice in
                    1)
                        check_env
                        build_image
                        start_services
                        check_status
                        ;;
                    2)
                        check_env
                        build_image
                        ;;
                    3)
                        check_env
                        start_services
                        check_status
                        ;;
                    4)
                        stop_services
                        ;;
                    5)
                        view_logs
                        ;;
                    6)
                        check_status
                        ;;
                    7)
                        cleanup
                        ;;
                    8)
                        echo "退出部署工具"
                        exit 0
                        ;;
                    *)
                        echo "无效选项"
                        ;;
                esac
            done
            ;;
    esac
}

# 运行主函数
main "$@"