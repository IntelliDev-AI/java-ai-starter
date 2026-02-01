#!/bin/bash
# 修复权限脚本

echo "🔧 修复Java AI Starter项目权限"
echo "==============================="

# 检查当前用户
echo "当前用户: $(whoami)"
echo "当前目录: $(pwd)"

# 检查项目目录
if [ ! -d "logs" ]; then
    echo "❌ logs目录不存在"
    mkdir -p logs
    echo "✅ 已创建logs目录"
fi

# 修复目录权限
echo "修复目录权限..."
find . -type d -exec chmod 755 {} \;
echo "✅ 目录权限已修复"

# 修复文件权限
echo "修复文件权限..."
find . -type f -exec chmod 644 {} \;

# 修复可执行文件
echo "修复可执行文件权限..."
find . -name "*.sh" -type f -exec chmod +x {} \;
find . -name "*.jar" -type f -exec chmod +x {} \;

# 修复特定文件
echo "修复特定文件权限..."
chmod 755 logs 2>/dev/null
chmod 644 logs/application.log 2>/dev/null

# 检查权限
echo ""
echo "📋 权限检查:"
echo "logs目录: $(ls -ld logs)"
echo "日志文件: $(ls -l logs/application.log 2>/dev/null || echo '日志文件不存在')"

# 测试读取
echo ""
echo "🧪 测试读取日志:"
if [ -f "logs/application.log" ]; then
    echo "最后3行日志:"
    tail -3 logs/application.log
    echo "✅ 日志读取成功"
else
    echo "⚠️  日志文件不存在，但目录权限已修复"
fi

echo ""
echo "✅ 权限修复完成"
echo ""
echo "📋 现在可以运行:"
echo "  tail -f logs/application.log"
echo "  ./view-logs.sh tail"