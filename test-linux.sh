#!/bin/bash
# Linux终端测试脚本

echo "🤖 AI聊天API测试 (Linux)"
echo "========================"

# 测试纯文本端点
echo -e "\n1. 测试纯文本端点:"
curl -s -X POST http://localhost:8080/api/v1/chat/text \
  -H "Content-Type: application/json" \
  -d '{"message": "你好，请用中文介绍一下你自己"}'

echo -e "\n\n2. 测试JSON端点:"
curl -s -X POST http://localhost:8080/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "今天天气怎么样？"}' | python3 -c "
import json, sys
data = json.load(sys.stdin)
print('AI回复:', data['message'])
print('模型:', data['model'])
print('Token使用:', data['tokens_used']['total_tokens'])
"

echo -e "\n3. 测试API状态:"
curl -s http://localhost:8080/api/v1/status | python3 -c "
import json, sys
data = json.load(sys.stdin)
print('服务:', data['service'])
print('状态:', data['status'])
print('模型:', data['model'])
print('API配置:', data['api_configured'])
"

# 交互模式
echo -e "\n4. 交互模式 (输入'退出'结束):"
while true; do
    echo -n "你的问题: "
    read user_input
    
    if [ "$user_input" = "退出" ] || [ "$user_input" = "exit" ]; then
        break
    fi
    
    echo -n "AI回复: "
    curl -s -X POST http://localhost:8080/api/v1/chat/text \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"$user_input\"}"
    echo ""
done

echo -e "\n✅ 测试完成"
echo -e "\n📋 快速命令参考:"
echo "  # 纯文本聊天"
echo "  curl -X POST http://localhost:8080/api/v1/chat/text \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"message\": \"你的问题\"}'"
echo ""
echo "  # JSON格式聊天"
echo "  curl -X POST http://localhost:8080/api/v1/chat \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"message\": \"你的问题\"}' | python3 -m json.tool"