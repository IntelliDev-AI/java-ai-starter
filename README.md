# Java AI Starter

<!-- 仓库统计徽章 -->
[![GitHub stars](https://img.shields.io/github/stars/IntelliDev-AI/java-ai-starter?style=for-the-badge)](https://github.com/IntelliDev-AI/java-ai-starter/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/IntelliDev-AI/java-ai-starter?style=for-the-badge)](https://github.com/IntelliDev-AI/java-ai-starter/network)
[![GitHub issues](https://img.shields.io/github/issues/IntelliDev-AI/java-ai-starter?style=for-the-badge)](https://github.com/IntelliDev-AI/java-ai-starter/issues)
[![GitHub license](https://img.shields.io/github/license/IntelliDev-AI/java-ai-starter?style=for-the-badge)](https://github.com/IntelliDev-AI/java-ai-starter/blob/main/LICENSE)

<!-- 技术栈徽章 -->
[![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)](https://java.com)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)](https://spring.io/projects/spring-boot)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)

<!-- GitHub Actions状态 -->
[![CI/CD Pipeline](https://github.com/IntelliDev-AI/java-ai-starter/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/IntelliDev-AI/java-ai-starter/actions/workflows/ci-cd.yml)

Spring Boot + OpenAI 快速启动模板，专为Java开发者设计的AI应用基础框架。

## 🎯 项目特点
- **开箱即用**：预配置Spring Boot + OpenAI集成
- **生产就绪**：统一异常处理、日志、配置管理
- **模块化设计**：易于扩展和维护
- **完整文档**：从开发到部署的完整指南

## 🚀 快速开始

### 环境要求
- JDK 11+
- Maven 3.6+
- OpenAI API Key

### 1. 克隆项目
```bash
git clone https://github.com/IntelliDev-AI/java-ai-starter.git
cd java-ai-starter
```

### 2. 配置环境
```bash
# 复制环境配置模板
cp .env.example .env

# 编辑 .env 文件，添加你的配置
# OPENAI_API_KEY=你的API密钥
# OPENAI_MODEL=gpt-3.5-turbo
```

### 3. 运行项目
```bash
# 使用Maven
./mvnw spring-boot:run

# 或打包运行
./mvnw clean package
java -jar target/java-ai-starter-0.0.1.jar
```

### 4. 测试API
```bash
# 测试健康检查
curl http://localhost:8080/health

# 测试AI对话
curl -X POST http://localhost:8080/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

## 🏗️ 项目结构
```
java-ai-starter/
├── src/main/java/com/intellidev/
│   ├── config/          # 配置类
│   ├── controller/      # 控制器
│   ├── service/         # 业务逻辑
│   ├── client/          # 外部客户端（OpenAI）
│   ├── model/           # 数据模型
│   └── exception/       # 异常处理
├── src/main/resources/
│   ├── application.yml  # 主配置
│   └── templates/       # 模板文件
├── src/test/           # 测试代码
├── docs/               # 项目文档
└── scripts/            # 部署脚本
```

## 📖 核心功能

### 1. OpenAI集成
- 自动配置API客户端
- 支持流式响应
- 错误重试机制
- 请求限流控制

### 2. Web API
- RESTful API设计
- 统一响应格式
- 参数验证
- Swagger文档

### 3. 工具类
- 文本处理工具
- 文件上传处理
- 缓存管理
- 任务调度

### 4. 监控和日志
- 健康检查端点
- 请求日志
- 性能监控
- 错误追踪

## 🔧 配置说明

### 主要配置项
```yaml
# application.yml
openai:
  api-key: ${OPENAI_API_KEY}
  model: ${OPENAI_MODEL:gpt-3.5-turbo}
  timeout: 30000
  max-tokens: 1000

server:
  port: 8080

spring:
  application:
    name: java-ai-starter
```

### 环境变量
```bash
# .env.example
OPENAI_API_KEY=你的OpenAI API密钥
OPENAI_MODEL=gpt-3.5-turbo
SERVER_PORT=8080
LOG_LEVEL=INFO
```

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
./mvnw test

# 运行特定测试类
./mvnw test -Dtest=AIServiceTest

# 生成测试报告
./mvnw surefire-report:report
```

### 测试覆盖率
```bash
# 生成覆盖率报告
./mvnw jacoco:report
```

## 📦 部署

### Docker部署
```bash
# 构建镜像
docker build -t intellidev/java-ai-starter .

# 运行容器
docker run -p 8080:8080 \
  -e OPENAI_API_KEY=你的密钥 \
  intellidev/java-ai-starter
```

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: unless-stopped
```

## 🤝 贡献指南

### 开发流程
1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

### 代码规范
- 遵循Google Java代码风格
- 编写单元测试
- 更新相关文档
- 保持向后兼容性

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持

- 提交Issue：https://github.com/IntelliDev-AI/java-ai-starter/issues
- 文档：查看 [docs](docs/) 目录
- 邮箱：contact@intellidev.ai

## 🌟 致谢

感谢所有为本项目做出贡献的开发者！

---
**IntelliDev AI** - Java + AI 解决方案专家
