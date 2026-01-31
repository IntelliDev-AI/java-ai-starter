#!/bin/bash
# 更新GitHub仓库Topics

# 注意：需要GitHub PAT（个人访问令牌）
# 请先设置环境变量：export GITHUB_TOKEN=你的令牌

REPO="IntelliDev-AI/java-ai-starter"
TOPICS='["java","spring-boot","openai","ai","starter-template","spring","boot","java-ai","api-template"]'

echo "更新仓库Topics..."
echo "仓库: $REPO"
echo "Topics: $TOPICS"

# 使用GitHub API更新Topics
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.mercy-preview+json" \
  -d "{\"names\": $TOPICS}" \
  "https://api.github.com/repos/$REPO/topics" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Topics更新成功！"
else
    echo "❌ Topics更新失败，可能需要手动设置"
    echo ""
    echo "请手动在GitHub页面设置："
    echo "1. 访问 https://github.com/IntelliDev-AI/java-ai-starter"
    echo "2. 点击右侧 'About' 区域"
    echo "3. 点击齿轮图标 ⚙️"
    echo "4. 在 'Topics' 输入框中添加："
    echo "   java, spring-boot, openai, ai, starter-template"
fi
