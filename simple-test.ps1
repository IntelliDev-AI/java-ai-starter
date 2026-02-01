# 最简单的测试脚本

# 测试聊天
$body = @{message = "你好，请用中文介绍一下你自己"} | ConvertTo-Json
$response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/chat" -Method Post -Body $body -ContentType "application/json"

Write-Host "=" * 50
Write-Host "🤖 AI回复：" -ForegroundColor Yellow
Write-Host $response.message
Write-Host "=" * 50
Write-Host ""
Write-Host "📊 统计信息：" -ForegroundColor Cyan
Write-Host "模型: $($response.model)"
Write-Host "成功: $($response.success)"
Write-Host "总Token: $($response.tokens_used.total_tokens)"
Write-Host "时间戳: $(Get-Date -Date '1970-01-01').AddMilliseconds($response.timestamp)"