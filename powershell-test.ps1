# PowerShell AI聊天API测试脚本 - 无乱码版本

Write-Host "🤖 AI聊天API测试" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

# 测试纯文本端点
Write-Host "`n1. 测试纯文本端点 (推荐)" -ForegroundColor Green
$questions = @(
    "你好，请用中文介绍一下你自己",
    "今天天气怎么样？",
    "讲一个简短的笑话",
    "用一句话说明什么是人工智能"
)

foreach ($q in $questions) {
    Write-Host "`n提问: $q" -ForegroundColor Yellow
    $body = @{message = $q} | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/chat/text" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        Write-Host "回答: $response" -ForegroundColor White
    } catch {
        Write-Host "错误: $_" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

# 测试状态检查
Write-Host "`n2. 测试API状态" -ForegroundColor Green
try {
    $status = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/status" -Method Get -ErrorAction Stop
    Write-Host "✅ API状态正常" -ForegroundColor Green
    Write-Host "   服务: $($status.service)" -ForegroundColor White
    Write-Host "   状态: $($status.status)" -ForegroundColor White
    Write-Host "   模型: $($status.model)" -ForegroundColor White
    Write-Host "   API配置: $($status.api_configured)" -ForegroundColor White
} catch {
    Write-Host "❌ 状态检查失败: $_" -ForegroundColor Red
}

# 交互模式
Write-Host "`n3. 交互模式 (输入'退出'结束)" -ForegroundColor Green
while ($true) {
    $userInput = Read-Host "`n你的问题"
    if ($userInput -eq "退出" -or $userInput -eq "exit") {
        break
    }
    
    $body = @{message = $userInput} | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/chat/text" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        Write-Host "`n🤖 AI: $response" -ForegroundColor Cyan
    } catch {
        Write-Host "错误: $_" -ForegroundColor Red
    }
}

Write-Host "`n✅ 测试完成" -ForegroundColor Green
Write-Host "`n📋 快速命令参考:" -ForegroundColor Yellow
Write-Host "  # 一句话测试" -ForegroundColor Gray
Write-Host "  Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/chat/text' -Method Post -Body (@{message='你好'} | ConvertTo-Json) -ContentType 'application/json'" -ForegroundColor White
Write-Host "`n  # 使用curl.exe" -ForegroundColor Gray
Write-Host "  curl.exe -s -X POST http://localhost:8080/api/v1/chat/text -H 'Content-Type: application/json' -d '{\"message\":\"你好\"}'" -ForegroundColor White