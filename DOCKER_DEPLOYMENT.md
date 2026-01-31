# 🐳 Java AI Starter - Docker部署指南

## 📋 概述

本文档提供Java AI Starter项目的完整Docker部署指南。使用Docker可以快速、一致地在任何环境中部署应用。

## 🚀 快速开始

### 1. 环境要求
- Docker 20.10+
- Docker Compose 2.0+
- 至少2GB可用内存
- DeepSeek API Key

### 2. 一键部署
```bash
# 克隆项目
git clone https://github.com/IntelliDev-AI/java-ai-starter.git
cd java-ai-starter

# 运行部署脚本
./docker-deploy.sh
```

### 3. 手动部署
```bash
# 复制环境配置
cp .env.docker .env
# 编辑.env文件，配置你的API Key

# 构建并启动
docker-compose up -d

# 查看状态
docker-compose ps
```

## 🔧 详细部署步骤

### 步骤1：配置环境变量
```bash
# 从模板创建.env文件
cp .env.docker .env

# 编辑.env文件，至少配置以下项：
nano .env

# 必须配置：
AI_API_KEY=你的DeepSeek_API_Key

# 可选配置：
HOST_PORT=8080          # 主机端口
AI_MODEL=deepseek-chat  # AI模型
AI_BASE_URL=https://api.deepseek.com  # API地址
```

### 步骤2：构建Docker镜像
```bash
# 使用部署脚本
./docker-deploy.sh build

# 或手动构建
docker-compose build
```

### 步骤3：启动服务
```bash
# 启动主应用（推荐）
./docker-deploy.sh start

# 或启动完整服务栈
docker-compose up -d java-ai-app postgres redis
```

### 步骤4：验证部署
```bash
# 检查容器状态
docker-compose ps

# 测试健康检查
curl http://localhost:8080/api/health

# 测试AI功能
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好，Docker部署成功了吗？"}'
```

## 🐳 Docker配置详解

### 1. Dockerfile结构
```
Dockerfile
├── 多阶段构建
│   ├── 阶段1: maven构建 (JDK 17)
│   └── 阶段2: 运行环境 (JRE 17)
├── 非root用户运行
├── 健康检查配置
├── 时区设置 (Asia/Shanghai)
└── 资源限制优化
```

### 2. docker-compose.yml服务
```yaml
services:
  java-ai-app:     # 主应用服务
    build: .       # 从当前目录构建
    ports:         # 端口映射
      - "8080:8080"
    environment:   # 环境变量
      - AI_API_KEY
    volumes:       # 数据卷
      - ./logs:/app/logs
    healthcheck:   # 健康检查
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
  
  postgres:       # PostgreSQL数据库 (可选)
    image: postgres:15-alpine
  
  redis:          # Redis缓存 (可选)
    image: redis:7-alpine
  
  nginx:          # Nginx反向代理 (可选)
    image: nginx:alpine
  
  prometheus:     # 监控系统 (可选)
    image: prom/prometheus
  
  grafana:        # 监控面板 (可选)
    image: grafana/grafana
```

### 3. 环境变量配置
| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `AI_API_KEY` | (必填) | DeepSeek API Key |
| `AI_MODEL` | `deepseek-chat` | AI模型名称 |
| `AI_BASE_URL` | `https://api.deepseek.com` | API地址 |
| `AI_TIMEOUT` | `30000` | 请求超时(毫秒) |
| `AI_MAX_TOKENS` | `1000` | 最大token数 |
| `HOST_PORT` | `8080` | 主机映射端口 |
| `DB_PASSWORD` | `ai_password` | 数据库密码 |
| `GRAFANA_PASSWORD` | `admin` | Grafana管理员密码 |

## 📊 部署模式

### 1. 开发模式
```bash
# 使用热部署，便于开发调试
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### 2. 生产模式
```bash
# 使用生产配置，包含监控和备份
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 3. 单容器模式
```bash
# 仅运行主应用
docker run -p 8080:8080 \
  -e AI_API_KEY=你的key \
  -v ./logs:/app/logs \
  intellidev/java-ai-starter:latest
```

## 🔧 运维管理

### 1. 常用命令
```bash
# 查看容器状态
docker-compose ps

# 查看应用日志
docker-compose logs -f java-ai-app

# 进入容器
docker-compose exec java-ai-app sh

# 重启服务
docker-compose restart java-ai-app

# 停止服务
docker-compose down

# 清理所有资源
docker-compose down -v --rmi all
```

### 2. 数据管理
```bash
# 备份数据库
docker-compose exec postgres pg_dump -U ai_user ai_starter > backup.sql

# 恢复数据库
cat backup.sql | docker-compose exec -T postgres psql -U ai_user ai_starter

# 查看日志文件
tail -f logs/application.log

# 清理日志
docker-compose exec java-ai-app find /app/logs -name "*.log" -mtime +7 -delete
```

### 3. 监控和告警
```bash
# 访问监控面板
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)

# 查看应用指标
curl http://localhost:8080/actuator/metrics

# 健康检查详情
curl http://localhost:8080/actuator/health
```

## 🐛 故障排除

### 常见问题1：端口冲突
```bash
# 检查端口占用
sudo lsof -i :8080

# 修改端口
# 在.env文件中修改 HOST_PORT=8081
```

### 常见问题2：API Key错误
```bash
# 检查环境变量
docker-compose exec java-ai-app env | grep AI_API_KEY

# 测试API连接
docker-compose exec java-ai-app curl -X POST https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer $AI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"test"}]}'
```

### 常见问题3：内存不足
```bash
# 查看容器资源使用
docker stats

# 调整内存限制
# 在docker-compose.yml中增加：
# java-ai-app:
#   deploy:
#     resources:
#       limits:
#         memory: 1G
```

### 常见问题4：构建失败
```bash
# 清理构建缓存
docker system prune -a

# 重新构建
docker-compose build --no-cache

# 查看详细错误
docker-compose build --progress=plain
```

## 🔒 安全建议

### 1. 生产环境安全
```bash
# 使用密钥管理服务
# 而不是在.env文件中明文存储API Key

# 配置网络隔离
docker network create --internal ai-internal-network

# 启用TLS/SSL
# 配置Nginx SSL证书
```

### 2. 访问控制
```bash
# 配置防火墙
sudo ufw allow 8080/tcp

# 使用反向代理认证
# 配置Nginx Basic Auth

# 限制API访问频率
# 在应用层或Nginx层配置限流
```

### 3. 定期维护
```bash
# 更新镜像
docker-compose pull
docker-compose up -d

# 安全扫描
docker scan intellidev/java-ai-starter

# 备份数据
# 设置定期备份任务
```

## 📈 性能优化

### 1. 资源优化
```yaml
# 在docker-compose.yml中配置资源限制
java-ai-app:
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 1G
      reservations:
        cpus: '0.5'
        memory: 512M
```

### 2. 网络优化
```yaml
# 配置自定义网络
networks:
  ai-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### 3. 存储优化
```yaml
# 使用本地卷提高IO性能
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      device: /data/postgres
      o: bind
```

## 🔗 相关资源

- [Docker官方文档](https://docs.docker.com/)
- [Docker Compose文档](https://docs.docker.com/compose/)
- [DeepSeek API文档](https://platform.deepseek.com/api-docs)
- [Spring Boot Docker指南](https://spring.io/guides/gs/spring-boot-docker/)
- [项目GitHub仓库](https://github.com/IntelliDev-AI/java-ai-starter)

## 💡 最佳实践

### 开发阶段
- 使用`.env.docker`作为模板，不提交`.env`文件
- 在Dockerfile中使用多阶段构建减少镜像大小
- 配置合适的`.dockerignore`文件

### 测试阶段
- 使用Docker Compose测试完整服务栈
- 配置CI/CD流水线自动构建和测试
- 进行安全扫描和漏洞检查

### 生产阶段
- 使用私有镜像仓库
- 配置监控和告警
- 定期更新基础镜像和安全补丁
- 实施备份和灾难恢复计划

---

**🎉 部署成功！** 现在你可以通过 http://localhost:8080 访问Java AI Starter应用了。

如需进一步帮助，请参考项目文档或提交Issue。