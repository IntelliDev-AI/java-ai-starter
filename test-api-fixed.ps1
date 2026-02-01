# Java AI Chat API PowerShell 测试脚本（修复编码问题）

$Port = 8080
$Host = "localhost"

Write-Host "🧪 测试 Java AI Chat API（修复编码）" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# 设置正确的编码
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# 测试健康检查
Write-Host "`n1. 测试健康检查..." -ForegroundColor Green
$statusUrl = "http://${Host}:${Port}/api/v1/status"
try {
    $response = Invoke-RestMethod -Uri $statusUrl -Method Get
    Write-Host "✅ 状态检查成功" -ForegroundColor Green
    Write-Host "服务: $($response.service)" -ForegroundColor White
    Write-Host "状态: $($response.status)" -ForegroundColor White
    Write-Host "模型: $($response.model)" -ForegroundColor White
    Write-Host "API配置: $($response.api_configured)" -ForegroundColor White
    Write-Host "基础URL: $($response.base_url)" -ForegroundColor White
} catch {
    Write-Host "❌ 错误: $_" -ForegroundColor Red
}

# 测试聊天功能
Write-Host "`n2. 测试聊天功能..." -ForegroundColor Green
$chatUrl = "http://${Host}:${Port}/api/v1/chat"
$body = @{
    message = "你好，请用中文简单介绍一下你自己"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ 聊天测试成功" -ForegroundColor Green
    Write-Host "`n🤖 AI回复：" -ForegroundColor Yellow
    Write-Host $response.message -ForegroundColor White
    Write-Host "`n📊 使用统计：" -ForegroundColor Yellow
    Write-Host "模型: $($response.model)" -ForegroundColor White
    Write-Host "成功: $($response.success)" -ForegroundColor White
    Write-Host "总Token数: $($response.tokens_used.total_tokens)" -ForegroundColor White
    Write-Host "提示Token: $($response.tokens_used.prompt_tokens)" -ForegroundColor White
    Write-Host "回复Token: $($response.tokens_used.completion_tokens)" -ForegroundColor White
} catch {
    Write-Host "❌ 错误: $_" -ForegroundColor Red
}

# 测试复杂问题
Write-Host "`n3. 测试复杂问题..." -ForegroundColor Green
$body2 = @{
    message = "用100字简单说明人工智能的发展历史"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post -Body $body2 -ContentType "application/json"
    Write-Host "✅ 复杂问题测试成功" -ForegroundColor Green
    Write-Host "`n🤖 AI回复：" -ForegroundColor Yellow
    Write-Host $response.message -ForegroundColor White
} catch {
    Write-Host "❌ 错误: $_" -ForegroundColor Red
}

Write-Host "`n✅ 测试完成" -ForegroundColor Green
Write-Host "`n📋 快速测试命令：" -ForegroundColor Yellow
Write-Host "  # 简单测试" -ForegroundColor Gray
Write-Host "  `$r = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/chat' -Method Post -Body (@{message='你好'} | ConvertTo-Json) -ContentType 'application/json'" -ForegroundColor White
Write-Host "  `$r.message" -ForegroundColor White