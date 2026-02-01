#!/bin/bash
# 手动部署脚本 - 上传已构建的前端文件

set -e

echo "🚀 手动部署前端文件到服务器..."

SERVER_IP="81.70.234.241"
PRIVATE_KEY="/home/zhuyinhang/tenxunyunfuwuqimiyao/beijinshili.pem"
FRONTEND_DIR="/home/zhuyinhang/.openclaw/workspace/java-ai-starter/frontend"
BUILD_DIR="$FRONTEND_DIR/dist"

# 检查构建文件
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ 构建目录不存在: $BUILD_DIR"
    echo "请先运行: cd $FRONTEND_DIR && npm run build"
    exit 1
fi

# 检查文件数量
FILE_COUNT=$(find "$BUILD_DIR" -type f | wc -l)
if [ "$FILE_COUNT" -lt 3 ]; then
    echo "❌ 构建文件太少: $FILE_COUNT 个文件"
    echo "构建可能不完整"
    exit 1
fi

echo "✅ 找到 $FILE_COUNT 个构建文件"

# 上传到服务器
echo "📤 上传文件到服务器 $SERVER_IP..."
scp -i "$PRIVATE_KEY" -r "$BUILD_DIR/"* root@"$SERVER_IP":/usr/share/nginx/html/ 2>/dev/null || {
    echo "❌ 文件上传失败"
    exit 1
}

# 设置权限
echo "🔧 设置服务器文件权限..."
ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no root@"$SERVER_IP" "
    chown -R nginx:nginx /usr/share/nginx/html
    chmod -R 755 /usr/share/nginx/html
    echo '✅ 文件权限设置完成'
"

# 重启Nginx
echo "🔄 重启Nginx服务..."
ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no root@"$SERVER_IP" "
    if nginx -t; then
        systemctl restart nginx
        echo '✅ Nginx重启成功'
    else
        echo '❌ Nginx配置测试失败'
        exit 1
    fi
"

# 测试部署
echo "🧪 测试部署..."
sleep 2

echo "🌐 部署完成！"
echo "   前端访问: http://$SERVER_IP"
echo "   后端API: http://$SERVER_IP:8080/api/v1"
echo ""
echo "📋 测试命令:"
echo "   curl http://$SERVER_IP/health"
echo "   curl http://$SERVER_IP:8080/api/v1/ping"
echo ""
echo "🔍 查看日志:"
echo "   ssh -i $PRIVATE_KEY root@$SERVER_IP 'journalctl -u nginx -f'"