# CloudMonitor-Go 数据库设计文档

## 📋 概述

本文档描述了CloudMonitor-Go项目的MySQL数据库设计，包含基础版本的所有表结构和关系。

## 🗄️ 数据库信息

- **数据库名**: `cloudmonitor`
- **字符集**: `utf8mb4`
- **排序规则**: `utf8mb4_unicode_ci`
- **引擎**: `InnoDB`

## 📊 表结构总览

### 1. 用户管理模块 (4张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `users` | 用户表 | id, username, email, password_hash, role, status |
| `user_groups` | 用户组表 | id, name, description, created_by |
| `user_group_relations` | 用户组关联表 | user_id, group_id |
| `roles` | 角色表 | id, name, code, description |
| `permissions` | 权限表 | id, name, code, resource_type, action |
| `role_permissions` | 角色权限关联表 | role_id, permission_id |
| `user_roles` | 用户角色关联表 | user_id, role_id |

### 2. 主机管理模块 (3张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `hosts` | 主机表 | id, hostname, ip_address, agent_id, status, last_heartbeat |
| `host_groups` | 主机组表 | id, name, description, created_by |
| `host_group_relations` | 主机组关联表 | host_id, group_id |

### 3. 监控指标模块 (4张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `metrics` | 指标定义表 | id, name, display_name, type, category, unit |
| `metric_labels` | 指标标签表 | metric_id, label_key, label_value |
| `metric_snapshots` | 监控数据快照表 | host_id, metric_name, metric_value, collected_at |
| `metric_aggregations` | 监控数据聚合表 | host_id, metric_name, aggregation_type, metric_value |

### 4. 告警管理模块 (2张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `alert_rules` | 告警规则表 | id, name, metric_name, condition_type, threshold_value, severity |
| `alert_history` | 告警历史表 | rule_id, host_id, metric_name, status, fired_at, resolved_at |

### 5. 通知管理模块 (2张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `notification_configs` | 通知配置表 | id, name, type, config, enabled |
| `alert_notifications` | 告警通知关联表 | alert_id, notification_id, status, sent_at |

### 6. 仪表板模块 (2张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `dashboards` | 仪表板表 | id, name, description, layout, refresh_interval, is_public |
| `dashboard_panels` | 仪表板面板表 | dashboard_id, title, type, position, config |

### 7. 系统管理模块 (4张表)

| 表名 | 说明 | 主要字段 |
|------|------|----------|
| `system_configs` | 系统配置表 | config_key, config_value, description, category |
| `operation_logs` | 操作日志表 | user_id, action, resource_type, resource_id, details |
| `scheduled_tasks` | 定时任务表 | name, task_type, cron_expression, config, enabled |
| `task_executions` | 任务执行历史表 | task_id, status, started_at, finished_at, result |

## 🔗 表关系图

```
users (1) ──── (N) user_groups
  │                    │
  │                    │
  └─── (N) user_roles (1) ──── roles (1) ──── (N) role_permissions (N) ──── permissions
  │
  └─── (N) hosts (1) ──── (N) host_groups
  │
  └─── (N) alert_rules
  │
  └─── (N) notification_configs
  │
  └─── (N) dashboards
  │
  └─── (N) operation_logs

hosts (1) ──── (N) metric_snapshots
  │
  └─── (N) metric_aggregations
  │
  └─── (N) alert_history

alert_rules (1) ──── (N) alert_history (1) ──── (N) alert_notifications (N) ──── notification_configs

dashboards (1) ──── (N) dashboard_panels

scheduled_tasks (1) ──── (N) task_executions
```

## 📈 索引设计

### 主要索引策略

1. **主键索引**: 所有表都使用 `BIGINT AUTO_INCREMENT` 作为主键
2. **唯一索引**: 用户名、邮箱、主机名、Agent ID等关键字段
3. **外键索引**: 所有外键关系都建立了索引
4. **查询索引**: 根据业务查询需求建立复合索引
5. **时间索引**: 对时间相关字段建立索引，支持时间范围查询

### 重要索引

```sql
-- 用户表索引
INDEX idx_username (username)
INDEX idx_email (email)
INDEX idx_status (status)
INDEX idx_role (role)

-- 主机表索引
INDEX idx_hostname (hostname)
INDEX idx_ip_address (ip_address)
INDEX idx_agent_id (agent_id)
INDEX idx_status (status)
INDEX idx_last_heartbeat (last_heartbeat)

-- 告警表索引
INDEX idx_rule_id (rule_id)
INDEX idx_host_id (host_id)
INDEX idx_metric_name (metric_name)
INDEX idx_severity (severity)
INDEX idx_status (status)
INDEX idx_fired_at (fired_at)

-- 监控数据索引
INDEX idx_host_id (host_id)
INDEX idx_metric_name (metric_name)
INDEX idx_collected_at (collected_at)
INDEX idx_bucket_start (bucket_start)
```

## 🔧 数据类型选择

### 主键类型
- 使用 `BIGINT AUTO_INCREMENT` 确保足够大的ID范围
- 支持分布式环境下的ID生成

### 字符串类型
- `VARCHAR(50-100)`: 用于名称、代码等短字符串
- `TEXT`: 用于描述、消息等长文本
- `JSON`: 用于存储结构化配置数据

### 数值类型
- `DECIMAL(10,2)`: 用于精确的数值计算（如阈值）
- `DECIMAL(15,4)`: 用于监控数据的高精度存储
- `BIGINT`: 用于大数值（如内存、磁盘空间）

### 时间类型
- `TIMESTAMP`: 用于所有时间字段，支持时区转换
- 自动设置 `created_at` 和 `updated_at`

### 枚举类型
- 使用 `ENUM` 限制可选值，提高数据一致性
- 如：用户状态、告警级别、指标类型等

## 🚀 性能优化

### 分区策略
- 监控数据表按时间分区
- 告警历史表按时间分区
- 操作日志表按时间分区

### 数据清理
- 监控数据保留30天
- 告警历史保留90天
- 操作日志保留180天

### 查询优化
- 使用覆盖索引减少回表
- 合理使用复合索引
- 避免全表扫描

## 📝 基础数据

### 默认用户
- 管理员用户: `admin` / `admin123`
- 角色: `admin`
- 状态: `active`

### 默认指标
- CPU使用率、内存使用率、磁盘使用率
- 网络流量、HTTP请求、数据库连接数
- Redis内存使用等

### 默认告警规则
- CPU使用率 > 80% (5分钟)
- 内存使用率 > 90% (3分钟)
- 磁盘使用率 > 85%
- HTTP错误率 > 5%

### 默认通知配置
- 邮件通知配置
- 钉钉通知配置

## 🔒 安全考虑

### 数据加密
- 密码使用bcrypt哈希存储
- 敏感配置信息加密存储

### 访问控制
- 基于角色的权限控制(RBAC)
- 细粒度的资源权限管理

### 审计日志
- 记录所有重要操作
- 支持操作追溯

## 📋 扩展性设计

### 水平扩展
- 支持分库分表
- 监控数据可以按时间分片
- 支持读写分离

### 功能扩展
- 预留了足够的字段长度
- 使用JSON字段存储灵活配置
- 支持自定义指标和告警规则

## 🔄 版本管理

### 数据库版本
- 当前版本: 1.0.0
- 支持增量升级
- 提供回滚方案

### 变更记录
- 记录所有表结构变更
- 提供升级脚本
- 支持数据迁移

## 📞 维护建议

### 日常维护
- 定期清理过期数据
- 监控索引使用情况
- 优化慢查询

### 备份策略
- 每日全量备份
- 实时增量备份
- 异地备份存储

### 监控告警
- 数据库连接数监控
- 慢查询监控
- 磁盘空间监控

---

**注意**: 这是基础版本的数据库设计，后续开发中可能会根据实际需求进行调整和优化。
