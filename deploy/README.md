# CloudMonitor-Go 部署指南

本文档介绍如何部署 CloudMonitor-Go 分布式监控平台。

## 📋 部署方式

CloudMonitor-Go 支持两种部署方式：
- **Docker Compose**: 适用于开发环境和单机部署
- **Kubernetes**: 适用于生产环境和集群部署

## 🐳 Docker Compose 部署

### 环境要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 4GB 内存
- 至少 20GB 磁盘空间

### 快速部署

```bash
# 1. 克隆项目
git clone <repository-url>
cd CloudMonitor-Go

# 2. 构建并启动服务
cd deploy/docker
docker-compose up -d

# 3. 检查服务状态
docker-compose ps
```

### 服务访问地址

部署完成后，可以通过以下地址访问各个服务：

| 服务 | 地址 | 说明 |
|------|------|------|
| Web界面 | http://localhost:8006 | 监控平台主界面 |
| Grafana | http://localhost:3000 | 数据可视化 (admin/admin) |
| Prometheus | http://localhost:9090 | 指标监控 |
| Jaeger | http://localhost:16686 | 链路追踪 |
| Kibana | http://localhost:5601 | 日志分析 |
| InfluxDB | http://localhost:8086 | 时序数据库 |

### 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f [service-name]

# 重启服务
docker-compose restart [service-name]

# 更新服务
docker-compose pull
docker-compose up -d
```

## ☸️ Kubernetes 部署

### 环境要求

- Kubernetes 1.20+
- kubectl 1.20+
- 至少 8GB 内存
- 至少 50GB 磁盘空间
- 支持 StorageClass

### 快速部署

```bash
# 1. 克隆项目
git clone <repository-url>
cd CloudMonitor-Go

# 2. 使用部署脚本
chmod +x deploy/deploy.sh
./deploy/deploy.sh k8s-deploy

# 3. 检查部署状态
kubectl get pods -n cloudmonitor
kubectl get services -n cloudmonitor
```

### 手动部署

```bash
# 1. 创建命名空间
kubectl apply -f deploy/kubernetes/namespace.yaml

# 2. 创建配置
kubectl apply -f deploy/kubernetes/configmap.yaml

# 3. 部署数据库
kubectl apply -f deploy/kubernetes/mysql.yaml
kubectl apply -f deploy/kubernetes/redis.yaml

# 4. 部署微服务
kubectl apply -f deploy/kubernetes/agent.yaml
kubectl apply -f deploy/kubernetes/collector.yaml
kubectl apply -f deploy/kubernetes/processor.yaml
kubectl apply -f deploy/kubernetes/alerting.yaml
kubectl apply -f deploy/kubernetes/query.yaml
kubectl apply -f deploy/kubernetes/web.yaml

# 5. 部署监控组件
kubectl apply -f deploy/kubernetes/prometheus.yaml
kubectl apply -f deploy/kubernetes/grafana.yaml
kubectl apply -f deploy/kubernetes/jaeger.yaml

# 6. 创建Ingress
kubectl apply -f deploy/kubernetes/ingress.yaml
```

### 服务访问

配置 Ingress 后，可以通过以下地址访问：

| 服务 | 地址 | 说明 |
|------|------|------|
| Web界面 | http://cloudmonitor.local/web | 监控平台主界面 |
| API接口 | http://cloudmonitor.local/api | RESTful API |
| Grafana | http://cloudmonitor.local/grafana | 数据可视化 |
| Prometheus | http://cloudmonitor.local/prometheus | 指标监控 |
| Jaeger | http://cloudmonitor.local/jaeger | 链路追踪 |

### 常用命令

```bash
# 查看Pod状态
kubectl get pods -n cloudmonitor

# 查看服务状态
kubectl get services -n cloudmonitor

# 查看日志
kubectl logs -f deployment/cloudmonitor-agent -n cloudmonitor

# 进入Pod
kubectl exec -it <pod-name> -n cloudmonitor -- /bin/bash

# 删除部署
kubectl delete -f deploy/kubernetes/
```

## 🔧 配置说明

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| CONFIG_PATH | 配置文件路径 | /app/configs/config.yaml |
| LOG_LEVEL | 日志级别 | info |
| ENVIRONMENT | 运行环境 | development |

### 配置文件

配置文件位于 `configs/config.yaml`，包含以下配置项：

- **服务配置**: 各微服务的端口和端点
- **数据库配置**: MySQL、Redis、InfluxDB连接信息
- **消息队列配置**: Kafka、RabbitMQ配置
- **监控配置**: Prometheus、Jaeger、Grafana配置
- **告警配置**: 钉钉、企微、邮件通知配置

## 📊 监控指标

### 系统指标

- **CPU使用率**: 系统CPU使用情况
- **内存使用率**: 系统内存使用情况
- **磁盘IO**: 磁盘读写性能
- **网络流量**: 网络带宽使用

### 应用指标

- **响应时间**: 服务响应时间
- **错误率**: 服务错误率
- **吞吐量**: 服务处理能力
- **并发数**: 并发连接数

### 业务指标

- **用户活跃度**: 用户活跃情况
- **业务成功率**: 业务操作成功率
- **关键路径**: 关键业务流程
- **异常事件**: 业务异常事件

## 🔍 故障排查

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查日志
   docker-compose logs [service-name]
   kubectl logs [pod-name] -n cloudmonitor
   ```

2. **数据库连接失败**
   ```bash
   # 检查数据库状态
   docker-compose ps mysql
   kubectl get pods -l app=cloudmonitor-mysql -n cloudmonitor
   ```

3. **服务间通信失败**
   ```bash
   # 检查网络连接
   docker network ls
   kubectl get endpoints -n cloudmonitor
   ```

### 性能调优

1. **内存优化**
   - 调整JVM堆大小
   - 优化数据库连接池
   - 配置合理的缓存策略

2. **CPU优化**
   - 调整服务副本数
   - 优化算法复杂度
   - 使用异步处理

3. **存储优化**
   - 配置SSD存储
   - 优化数据库索引
   - 实施数据分片

## 🔒 安全配置

### 网络安全

- 配置防火墙规则
- 使用HTTPS/TLS
- 实施网络隔离

### 访问控制

- 配置RBAC权限
- 使用API密钥认证
- 实施审计日志

### 数据安全

- 加密敏感数据
- 配置数据备份
- 实施访问审计

## 📈 扩展部署

### 水平扩展

```bash
# Docker Compose
docker-compose up -d --scale agent=3 --scale collector=2

# Kubernetes
kubectl scale deployment cloudmonitor-agent --replicas=3 -n cloudmonitor
```

### 高可用部署

- 使用多节点集群
- 配置负载均衡
- 实施故障转移

### 多环境部署

- 开发环境: 单节点部署
- 测试环境: 小规模集群
- 生产环境: 大规模集群

## 📞 技术支持

如果遇到部署问题，请：

1. 查看日志文件
2. 检查配置文件
3. 参考故障排查指南
4. 提交Issue到GitHub
