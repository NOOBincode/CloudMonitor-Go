# CloudMonitor-Go

基于Go语言和Kratos框架的分布式云原生监控平台

## 🚀 项目简介

CloudMonitor-Go是一个基于微服务架构的分布式监控平台，采用Go语言开发，使用Kratos框架构建。平台提供全方位的监控、告警、可观测性能力，支持基础设施监控、应用性能监控、业务指标监控、日志监控和链路追踪。

## 🏗️ 架构设计

### 微服务架构

```
┌─────────────────┐    gRPC    ┌─────────────────┐
│   Agent服务     │ ──────────► │  Collector服务  │
│  (数据采集)     │             │  (数据接收)     │
└─────────────────┘             └─────────┬───────┘
                                          │ gRPC
                                          ▼
                    ┌─────────────────────────────────┐
                    │        Processor服务            │
                    │      (数据处理和聚合)           │
                    └─────────┬───────────────────────┘
                              │ gRPC
                              ▼
            ┌─────────────────┼─────────────────┐
            │                 │                 │
    ┌───────▼────────┐ ┌──────▼────────┐ ┌─────▼────────┐
    │  Alerting服务   │ │   Query服务    │ │   Web服务    │
    │  (告警评估)     │ │  (数据查询)    │ │ (API网关)    │
    └─────────────────┘ └───────────────┘ └─────────────┘
```

### 技术栈

- **微服务框架**: Kratos v2
- **通信协议**: gRPC + HTTP/2
- **数据存储**: MySQL + Redis + InfluxDB
- **消息队列**: Kafka/RabbitMQ
- **监控**: Prometheus + Grafana
- **链路追踪**: OpenTelemetry + Jaeger
- **日志**: ELK Stack

## 📁 项目结构

```
cloudmonitor-go/
├── cmd/                          # 微服务启动入口
│   ├── agent/                    # Agent服务
│   ├── collector/                # Collector服务
│   ├── processor/                # Processor服务
│   ├── alerting/                 # Alerting服务
│   ├── query/                    # Query服务
│   └── web/                      # Web服务
├── pkg/                          # 公共库
│   ├── grpc/                     # gRPC工具库
│   ├── utils/                    # 工具库
│   ├── metrics/                  # 指标库
│   ├── logs/                     # 日志库
│   ├── storage/                  # 存储库
│   └── alerting/                 # 告警库
├── configs/                      # 配置文件
├── deploy/                       # 部署配置
├── docs/                         # 文档
├── examples/                     # 示例代码
├── tests/                        # 测试代码
└── tools/                        # 开发工具
```

## 🛠️ 快速开始

### 环境要求

- Go 1.21+
- Docker & Docker Compose
- Make

### 安装依赖

```bash
# 安装Go依赖
make deps

# 安装Kratos CLI
go install github.com/go-kratos/kratos/cmd/kratos/v2@latest

# 安装protoc工具
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/google/wire/cmd/wire@latest
```

### 生成代码

```bash
# 生成proto文件
make proto

# 生成依赖注入代码
make wire
```

### 运行服务

```bash
# 启动所有服务
make docker-compose

# 或者单独运行某个服务
make run-agent
make run-collector
make run-processor
make run-alerting
make run-query
make run-web
```

### 构建项目

```bash
# 构建所有服务
make build

# 清理构建文件
make clean
```

## 📊 监控能力

### 基础设施监控
- 服务器监控 (CPU、内存、磁盘、网络)
- 容器监控 (Docker、Kubernetes)
- 网络监控 (延迟、带宽、连接数)
- 存储监控 (IOPS、容量、性能)

### 应用性能监控 (APM)
- 服务监控 (响应时间、吞吐量、错误率)
- 接口监控 (API调用、成功率、QPS)
- 数据库监控 (连接池、慢查询、事务)
- 缓存监控 (命中率、内存使用、连接数)

### 业务指标监控
- 业务KPI (订单量、用户活跃度、转化率)
- 业务异常 (异常订单、支付失败、库存不足)
- 用户体验 (页面加载时间、操作成功率)
- 业务流程 (关键流程执行状态)

### 日志监控
- 应用日志 (错误日志、警告日志、调试信息)
- 系统日志 (系统事件、安全日志、审计日志)
- 访问日志 (HTTP请求、API调用)
- 性能日志 (慢查询、性能分析)

### 链路追踪
- 分布式调用链 (请求传播路径)
- 服务依赖关系 (调用关系图谱)
- 性能瓶颈分析 (调用链性能热点)
- 异常定位 (故障传播路径)

## 🔧 配置说明

配置文件位于 `configs/config.yaml`，包含以下配置项：

- **服务配置**: 各微服务的端口和端点
- **数据库配置**: MySQL、Redis、InfluxDB连接信息
- **消息队列配置**: Kafka、RabbitMQ配置
- **监控配置**: Prometheus、Jaeger、Grafana配置
- **告警配置**: 钉钉、企微、邮件通知配置

## 🚀 部署

### Docker部署

```bash
# 构建Docker镜像
make docker

# 启动服务
make docker-compose
```

### Kubernetes部署

```bash
# 部署到Kubernetes
kubectl apply -f deploy/kubernetes/
```

## 📝 开发指南

### 添加新的微服务

1. 使用Kratos CLI创建服务
```bash
kratos new service-name
```

2. 定义gRPC接口
3. 实现业务逻辑
4. 添加配置和部署文件

### 代码规范

- 遵循Go语言官方代码规范
- 使用gofmt格式化代码
- 编写单元测试和集成测试
- 使用golangci-lint进行代码检查

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目主页: [GitHub](https://github.com/your-username/cloudmonitor-go)
- 问题反馈: [Issues](https://github.com/your-username/cloudmonitor-go/issues)
- 讨论交流: [Discussions](https://github.com/your-username/cloudmonitor-go/discussions)
