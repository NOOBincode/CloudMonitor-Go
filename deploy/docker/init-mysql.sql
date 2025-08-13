-- CloudMonitor-Go MySQL 数据库初始化脚本
-- 基础版本数据库表设计

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS cloudmonitor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE cloudmonitor;

-- ========================================
-- 1. 用户管理相关表
-- ========================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    real_name VARCHAR(50) COMMENT '真实姓名',
    phone VARCHAR(20) COMMENT '手机号',
    avatar VARCHAR(255) COMMENT '头像URL',
    role ENUM('admin', 'user', 'viewer') DEFAULT 'user' COMMENT '用户角色',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active' COMMENT '用户状态',
    last_login_at TIMESTAMP NULL COMMENT '最后登录时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 用户组表
CREATE TABLE IF NOT EXISTS user_groups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '组名',
    description TEXT COMMENT '组描述',
    created_by BIGINT COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户组表';

-- 用户组关联表
CREATE TABLE IF NOT EXISTS user_group_relations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    group_id BIGINT NOT NULL COMMENT '组ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES user_groups(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_group (user_id, group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户组关联表';

-- ========================================
-- 2. 主机管理相关表
-- ========================================

-- 主机表
CREATE TABLE IF NOT EXISTS hosts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL COMMENT '主机名',
    ip_address VARCHAR(45) NOT NULL COMMENT 'IP地址',
    agent_id VARCHAR(100) NOT NULL UNIQUE COMMENT 'Agent ID',
    os_type VARCHAR(50) COMMENT '操作系统类型',
    os_version VARCHAR(100) COMMENT '操作系统版本',
    cpu_cores INT COMMENT 'CPU核心数',
    memory_total BIGINT COMMENT '总内存(字节)',
    disk_total BIGINT COMMENT '总磁盘空间(字节)',
    status ENUM('online', 'offline', 'maintenance') DEFAULT 'offline' COMMENT '主机状态',
    tags JSON COMMENT '主机标签',
    metadata JSON COMMENT '主机元数据',
    last_heartbeat TIMESTAMP NULL COMMENT '最后心跳时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_hostname (hostname),
    INDEX idx_ip_address (ip_address),
    INDEX idx_agent_id (agent_id),
    INDEX idx_status (status),
    INDEX idx_last_heartbeat (last_heartbeat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='主机表';

-- 主机组表
CREATE TABLE IF NOT EXISTS host_groups (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '组名',
    description TEXT COMMENT '组描述',
    created_by BIGINT COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='主机组表';

-- 主机组关联表
CREATE TABLE IF NOT EXISTS host_group_relations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id BIGINT NOT NULL COMMENT '主机ID',
    group_id BIGINT NOT NULL COMMENT '组ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES host_groups(id) ON DELETE CASCADE,
    UNIQUE KEY uk_host_group (host_id, group_id),
    INDEX idx_host_id (host_id),
    INDEX idx_group_id (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='主机组关联表';

-- ========================================
-- 3. 监控指标相关表
-- ========================================

-- 指标定义表
CREATE TABLE IF NOT EXISTS metrics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '指标名称',
    display_name VARCHAR(100) NOT NULL COMMENT '显示名称',
    description TEXT COMMENT '指标描述',
    unit VARCHAR(20) COMMENT '单位',
    type ENUM('counter', 'gauge', 'histogram', 'summary') NOT NULL COMMENT '指标类型',
    category ENUM('system', 'application', 'business', 'custom') DEFAULT 'system' COMMENT '指标分类',
    enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name),
    INDEX idx_category (category),
    INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='指标定义表';

-- 指标标签表
CREATE TABLE IF NOT EXISTS metric_labels (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    metric_id BIGINT NOT NULL COMMENT '指标ID',
    label_key VARCHAR(50) NOT NULL COMMENT '标签键',
    label_value VARCHAR(100) COMMENT '标签值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (metric_id) REFERENCES metrics(id) ON DELETE CASCADE,
    INDEX idx_metric_id (metric_id),
    INDEX idx_label_key (label_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='指标标签表';

-- ========================================
-- 4. 告警相关表
-- ========================================

-- 告警规则表
CREATE TABLE IF NOT EXISTS alert_rules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '规则名称',
    description TEXT COMMENT '规则描述',
    metric_name VARCHAR(100) NOT NULL COMMENT '指标名称',
    condition_type ENUM('threshold', 'trend', 'anomaly') DEFAULT 'threshold' COMMENT '条件类型',
    threshold_value DECIMAL(10,2) COMMENT '阈值',
    operator ENUM('>', '<', '>=', '<=', '==', '!=') DEFAULT '>' COMMENT '操作符',
    severity ENUM('info', 'warning', 'error', 'critical') DEFAULT 'warning' COMMENT '严重程度',
    duration INT DEFAULT 0 COMMENT '持续时间（秒）',
    labels JSON COMMENT '标签过滤',
    enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_by BIGINT COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_metric_name (metric_name),
    INDEX idx_severity (severity),
    INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='告警规则表';

-- 告警历史表
CREATE TABLE IF NOT EXISTS alert_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rule_id BIGINT COMMENT '规则ID',
    host_id BIGINT COMMENT '主机ID',
    metric_name VARCHAR(100) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(10,2) COMMENT '指标值',
    threshold_value DECIMAL(10,2) COMMENT '阈值',
    severity ENUM('info', 'warning', 'error', 'critical') DEFAULT 'warning' COMMENT '严重程度',
    status ENUM('firing', 'resolved', 'acknowledged') DEFAULT 'firing' COMMENT '告警状态',
    message TEXT COMMENT '告警消息',
    labels JSON COMMENT '标签',
    fired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '触发时间',
    resolved_at TIMESTAMP NULL COMMENT '解决时间',
    acknowledged_at TIMESTAMP NULL COMMENT '确认时间',
    acknowledged_by BIGINT COMMENT '确认者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (rule_id) REFERENCES alert_rules(id) ON DELETE SET NULL,
    FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE SET NULL,
    FOREIGN KEY (acknowledged_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_rule_id (rule_id),
    INDEX idx_host_id (host_id),
    INDEX idx_metric_name (metric_name),
    INDEX idx_severity (severity),
    INDEX idx_status (status),
    INDEX idx_fired_at (fired_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='告警历史表';

-- ========================================
-- 5. 通知相关表
-- ========================================

-- 通知配置表
CREATE TABLE IF NOT EXISTS notification_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '配置名称',
    type ENUM('email', 'dingtalk', 'wechat', 'webhook', 'sms') NOT NULL COMMENT '通知类型',
    config JSON NOT NULL COMMENT '配置信息',
    enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    created_by BIGINT COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_type (type),
    INDEX idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知配置表';

-- 告警通知关联表
CREATE TABLE IF NOT EXISTS alert_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    alert_id BIGINT NOT NULL COMMENT '告警ID',
    notification_id BIGINT NOT NULL COMMENT '通知配置ID',
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending' COMMENT '发送状态',
    sent_at TIMESTAMP NULL COMMENT '发送时间',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (alert_id) REFERENCES alert_history(id) ON DELETE CASCADE,
    FOREIGN KEY (notification_id) REFERENCES notification_configs(id) ON DELETE CASCADE,
    INDEX idx_alert_id (alert_id),
    INDEX idx_notification_id (notification_id),
    INDEX idx_status (status),
    INDEX idx_sent_at (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='告警通知关联表';

-- ========================================
-- 6. 仪表板相关表
-- ========================================

-- 仪表板表
CREATE TABLE IF NOT EXISTS dashboards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '仪表板名称',
    description TEXT COMMENT '仪表板描述',
    layout JSON NOT NULL COMMENT '布局配置',
    refresh_interval INT DEFAULT 30 COMMENT '刷新间隔（秒）',
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否公开',
    created_by BIGINT COMMENT '创建者ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_created_by (created_by),
    INDEX idx_is_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仪表板表';

-- 仪表板面板表
CREATE TABLE IF NOT EXISTS dashboard_panels (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    dashboard_id BIGINT NOT NULL COMMENT '仪表板ID',
    title VARCHAR(100) NOT NULL COMMENT '面板标题',
    type ENUM('graph', 'stat', 'table', 'heatmap', 'pie') NOT NULL COMMENT '面板类型',
    position JSON NOT NULL COMMENT '位置信息',
    config JSON NOT NULL COMMENT '面板配置',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (dashboard_id) REFERENCES dashboards(id) ON DELETE CASCADE,
    INDEX idx_dashboard_id (dashboard_id),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='仪表板面板表';

-- ========================================
-- 7. 系统配置相关表
-- ========================================

-- 系统配置表
CREATE TABLE IF NOT EXISTS system_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    description TEXT COMMENT '配置描述',
    category VARCHAR(50) DEFAULT 'general' COMMENT '配置分类',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_config_key (config_key),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS operation_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT COMMENT '用户ID',
    action VARCHAR(100) NOT NULL COMMENT '操作动作',
    resource_type VARCHAR(50) COMMENT '资源类型',
    resource_id BIGINT COMMENT '资源ID',
    details JSON COMMENT '操作详情',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_resource_type (resource_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- ========================================
-- 8. 权限管理相关表
-- ========================================

-- 权限表
CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '权限名称',
    code VARCHAR(100) NOT NULL UNIQUE COMMENT '权限代码',
    description TEXT COMMENT '权限描述',
    resource_type VARCHAR(50) COMMENT '资源类型',
    action VARCHAR(50) COMMENT '操作类型',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name),
    INDEX idx_code (code),
    INDEX idx_resource_type (resource_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

-- 角色表
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '角色名称',
    code VARCHAR(100) NOT NULL UNIQUE COMMENT '角色代码',
    description TEXT COMMENT '角色描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name),
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

-- 角色权限关联表
CREATE TABLE IF NOT EXISTS role_permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT NOT NULL COMMENT '角色ID',
    permission_id BIGINT NOT NULL COMMENT '权限ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

-- ========================================
-- 9. 监控数据相关表
-- ========================================

-- 监控数据快照表（用于存储关键指标的当前值）
CREATE TABLE IF NOT EXISTS metric_snapshots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id BIGINT NOT NULL COMMENT '主机ID',
    metric_name VARCHAR(100) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(15,4) NOT NULL COMMENT '指标值',
    labels JSON COMMENT '标签',
    collected_at TIMESTAMP NOT NULL COMMENT '采集时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE,
    INDEX idx_host_id (host_id),
    INDEX idx_metric_name (metric_name),
    INDEX idx_collected_at (collected_at),
    UNIQUE KEY uk_host_metric_time (host_id, metric_name, collected_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='监控数据快照表';

-- 监控数据聚合表（用于存储聚合后的数据）
CREATE TABLE IF NOT EXISTS metric_aggregations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id BIGINT NOT NULL COMMENT '主机ID',
    metric_name VARCHAR(100) NOT NULL COMMENT '指标名称',
    aggregation_type ENUM('avg', 'max', 'min', 'sum', 'count') NOT NULL COMMENT '聚合类型',
    time_bucket VARCHAR(20) NOT NULL COMMENT '时间桶（如：1m, 5m, 1h, 1d）',
    metric_value DECIMAL(15,4) NOT NULL COMMENT '聚合值',
    labels JSON COMMENT '标签',
    bucket_start TIMESTAMP NOT NULL COMMENT '桶开始时间',
    bucket_end TIMESTAMP NOT NULL COMMENT '桶结束时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE,
    INDEX idx_host_id (host_id),
    INDEX idx_metric_name (metric_name),
    INDEX idx_aggregation_type (aggregation_type),
    INDEX idx_time_bucket (time_bucket),
    INDEX idx_bucket_start (bucket_start),
    UNIQUE KEY uk_host_metric_agg_time (host_id, metric_name, aggregation_type, time_bucket, bucket_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='监控数据聚合表';

-- ========================================
-- 10. 任务调度相关表
-- ========================================

-- 定时任务表
CREATE TABLE IF NOT EXISTS scheduled_tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '任务名称',
    description TEXT COMMENT '任务描述',
    task_type VARCHAR(50) NOT NULL COMMENT '任务类型',
    cron_expression VARCHAR(100) NOT NULL COMMENT 'Cron表达式',
    config JSON COMMENT '任务配置',
    enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    last_run_at TIMESTAMP NULL COMMENT '最后运行时间',
    next_run_at TIMESTAMP NULL COMMENT '下次运行时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (name),
    INDEX idx_task_type (task_type),
    INDEX idx_enabled (enabled),
    INDEX idx_next_run_at (next_run_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='定时任务表';

-- 任务执行历史表
CREATE TABLE IF NOT EXISTS task_executions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    task_id BIGINT NOT NULL COMMENT '任务ID',
    status ENUM('running', 'success', 'failed', 'cancelled') NOT NULL COMMENT '执行状态',
    started_at TIMESTAMP NOT NULL COMMENT '开始时间',
    finished_at TIMESTAMP NULL COMMENT '结束时间',
    duration_ms BIGINT NULL COMMENT '执行时长（毫秒）',
    result TEXT COMMENT '执行结果',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (task_id) REFERENCES scheduled_tasks(id) ON DELETE CASCADE,
    INDEX idx_task_id (task_id),
    INDEX idx_status (status),
    INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务执行历史表';

-- ========================================
-- 11. 插入基础数据
-- ========================================

-- 插入默认管理员用户（密码: admin123）
INSERT INTO users (username, email, password_hash, real_name, role, status) VALUES 
('admin', 'admin@cloudmonitor.local', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '系统管理员', 'admin', 'active')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认指标定义
INSERT INTO metrics (name, display_name, description, unit, type, category) VALUES 
('cpu_usage', 'CPU使用率', 'CPU使用率百分比', '%', 'gauge', 'system'),
('memory_usage', '内存使用率', '内存使用率百分比', '%', 'gauge', 'system'),
('disk_usage', '磁盘使用率', '磁盘使用率百分比', '%', 'gauge', 'system'),
('network_in', '网络入流量', '网络入流量', 'bytes/s', 'counter', 'system'),
('network_out', '网络出流量', '网络出流量', 'bytes/s', 'counter', 'system'),
('http_requests_total', 'HTTP请求总数', 'HTTP请求总数', 'count', 'counter', 'application'),
('http_request_duration', 'HTTP请求耗时', 'HTTP请求耗时', 'ms', 'histogram', 'application'),
('database_connections', '数据库连接数', '数据库连接数', 'count', 'gauge', 'application'),
('redis_memory_usage', 'Redis内存使用', 'Redis内存使用量', 'bytes', 'gauge', 'application')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认告警规则
INSERT INTO alert_rules (name, description, metric_name, condition_type, threshold_value, operator, severity, duration, created_by) VALUES 
('CPU使用率过高', 'CPU使用率超过80%持续5分钟', 'cpu_usage', 'threshold', 80.0, '>', 'warning', 300, 1),
('内存使用率过高', '内存使用率超过90%持续3分钟', 'memory_usage', 'threshold', 90.0, '>', 'error', 180, 1),
('磁盘使用率过高', '磁盘使用率超过85%', 'disk_usage', 'threshold', 85.0, '>', 'warning', 0, 1),
('HTTP错误率过高', 'HTTP错误率超过5%', 'http_requests_total', 'threshold', 5.0, '>', 'error', 60, 1)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认通知配置
INSERT INTO notification_configs (name, type, config, created_by) VALUES 
('默认邮件通知', 'email', '{"smtp_host": "smtp.example.com", "smtp_port": 587, "username": "noreply@example.com", "password": "password", "from": "noreply@example.com", "to": ["admin@example.com"]}', 1),
('默认钉钉通知', 'dingtalk', '{"webhook_url": "https://oapi.dingtalk.com/robot/send?access_token=your_token", "secret": "your_secret"}', 1)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入默认仪表板
INSERT INTO dashboards (name, description, layout, is_public, created_by) VALUES 
('系统概览', '系统整体监控概览', '{"panels": [{"id": 1, "title": "CPU使用率", "type": "graph", "position": {"x": 0, "y": 0, "w": 6, "h": 4}}, {"id": 2, "title": "内存使用率", "type": "graph", "position": {"x": 6, "y": 0, "w": 6, "h": 4}}]}', TRUE, 1)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, description, category) VALUES 
('system.name', 'CloudMonitor-Go', '系统名称', 'general'),
('system.version', '1.0.0', '系统版本', 'general'),
('monitor.retention_days', '30', '监控数据保留天数', 'monitor'),
('alert.default_timeout', '300', '默认告警超时时间（秒）', 'alert'),
('dashboard.default_refresh', '30', '默认仪表板刷新间隔（秒）', 'dashboard')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
