#!/bin/bash
# 日志查看工具

LOG_FILE="logs/application.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ 日志文件不存在: $LOG_FILE"
    exit 1
fi

case "$1" in
    "tail"|"-f")
        echo "📊 实时查看日志 (Ctrl+C退出)"
        echo "=============================="
        tail -f "$LOG_FILE"
        ;;
        
    "errors"|"-e")
        echo "⚠️  错误和警告日志"
        echo "=================="
        grep -E "ERROR|WARN" "$LOG_FILE" | tail -50
        ;;
        
    "api"|"-a")
        echo "🔄 API请求日志"
        echo "=============="
        grep "收到聊天请求" "$LOG_FILE" | tail -20
        ;;
        
    "today"|"-t")
        echo "📅 今日日志"
        echo "=========="
        grep "$(date +%Y-%m-%d)" "$LOG_FILE"
        ;;
        
    "stats"|"-s")
        echo "📈 日志统计"
        echo "=========="
        echo "总行数: $(wc -l < "$LOG_FILE")"
        echo "INFO级别: $(grep -c "INFO" "$LOG_FILE")"
        echo "WARN级别: $(grep -c "WARN" "$LOG_FILE")"
        echo "ERROR级别: $(grep -c "ERROR" "$LOG_FILE")"
        echo "API请求: $(grep -c "收到聊天请求" "$LOG_FILE")"
        echo "成功响应: $(grep -c "请求成功" "$LOG_FILE")"
        ;;
        
    "clear"|"-c")
        echo "🧹 清空日志文件"
        echo "=============="
        > "$LOG_FILE"
        echo "✅ 日志已清空"
        ;;
        
    "help"|"-h"|"")
        echo "📋 日志查看工具"
        echo "=============="
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  tail, -f    实时查看日志"
        echo "  errors, -e  查看错误和警告"
        echo "  api, -a     查看API请求日志"
        echo "  today, -t   查看今日日志"
        echo "  stats, -s   查看日志统计"
        echo "  clear, -c   清空日志文件"
        echo "  help, -h    显示帮助"
        ;;
        
    *)
        # 显示最后N行
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            echo "📄 最后 $1 行日志"
            echo "================"
            tail -n "$1" "$LOG_FILE"
        else
            echo "❌ 未知选项: $1"
            echo "使用: $0 help 查看帮助"
        fi
        ;;
esac