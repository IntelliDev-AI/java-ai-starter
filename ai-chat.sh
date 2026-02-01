#!/bin/bash
# 简单的AI聊天脚本

API_URL="http://localhost:8080/api/v1/chat/text"

# 如果没有参数，显示帮助
if [ $# -eq 0 ]; then
    echo "使用方法:"
    echo "  $0 \"你的问题\"          # 提问一个问题"
    echo "  $0 -i                  # 交互模式"
    echo "  $0 -s                  # 检查API状态"
    echo "  $0 -h                  # 显示帮助"
    exit 0
fi

case "$1" in
    -i|--interactive)
        echo "🤖 AI聊天交互模式 (输入'退出'结束)"
        echo "================================="
        while true; do
            echo -n "你: "
            read question
            if [ "$question" = "退出" ] || [ "$question" = "exit" ]; then
                echo "再见！"
                break
            fi
            
            echo -n "AI: "
            curl -s -X POST "$API_URL" \
                -H "Content-Type: application/json" \
                -d "{\"message\": \"$question\"}"
            echo ""
        done
        ;;
        
    -s|--status)
        echo "🔍 检查API状态..."
        curl -s http://localhost:8080/api/v1/status | python3 -c "
import json, sys
data = json.load(sys.stdin)
print('✅ 服务:', data['service'])
print('📊 状态:', data['status'])
print('🤖 模型:', data['model'])
print('🔑 API配置:', data['api_configured'])
print('🌐 基础URL:', data['base_url'])
"
        ;;
        
    -h|--help)
        echo "AI聊天客户端"
        echo "命令:"
        echo "  -i, --interactive   交互模式"
        echo "  -s, --status        检查API状态"
        echo "  -h, --help          显示帮助"
        echo "  其他任何文本        提问问题"
        ;;
        
    *)
        # 直接提问
        question="$*"
        echo "提问: $question"
        echo -n "回答: "
        curl -s -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "{\"message\": \"$question\"}"
        echo ""
        ;;
esac