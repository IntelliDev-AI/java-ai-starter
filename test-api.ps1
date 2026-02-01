# Java AI Chat API PowerShell 测试脚本

$Port = 8080
$Host = "localhost"

Write-Host "🧪 测试 Java AI Chat API" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# 测试健康检查
Write-Host "`n1. 测试健康检查..." -ForegroundColor Green
$statusUrl = "http://${Host}:${Port}/api/v1/status"
try {
    $response = Invoke-RestMethod -Uri $statusUrl -Method Get
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "错误: $_" -ForegroundColor Red
}

# 测试聊天功能
Write-Host "`n2. 测试聊天功能..." -ForegroundColor Green
$chatUrl = "http://${Host}:${Port}/api/v1/chat"
$body = @{
    message = "你好，请用中文简单介绍一下你自己"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post -Body $body -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "错误: $_" -ForegroundColor Red
}

# 测试复杂问题
Write-Host "`n3. 测试复杂问题..." -ForegroundColor Green
$body2 = @{
    message = "用100字简单说明人工智能的发展历史"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $chatUrl -Method Post -Body $body2 -ContentType "application/json"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "错误: $_" -ForegroundColor Red
}

Write-Host "`n✅ 测试完成" -ForegroundColor Green
Write-Host "`n📋 手动测试命令:" -ForegroundColor Yellow
Write-Host "  # 状态检查" -ForegroundColor Gray
Write-Host "  Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/status' -Method Get" -ForegroundColor White
Write-Host "`n  # 聊天测试" -ForegroundColor Gray
Write-Host "  `$body = @{message = '你的问题'} | ConvertTo-Json" -ForegroundColor White
Write-Host "  Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/chat' -Method Post -Body `$body -ContentType 'application/json'" -ForegroundColor White