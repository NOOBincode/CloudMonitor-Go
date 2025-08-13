# CloudMonitor-Go Makefile

.PHONY: help build clean test proto wire docker docker-compose

# 默认目标
help:
	@echo "CloudMonitor-Go 构建工具"
	@echo ""
	@echo "可用命令:"
	@echo "  build        - 构建所有服务"
	@echo "  clean        - 清理构建文件"
	@echo "  test         - 运行测试"
	@echo "  proto        - 生成proto文件"
	@echo "  wire         - 生成依赖注入代码"
	@echo "  docker       - 构建Docker镜像"
	@echo "  docker-compose - 启动Docker Compose"
	@echo "  run-agent    - 运行Agent服务"
	@echo "  run-collector - 运行Collector服务"
	@echo "  run-processor - 运行Processor服务"
	@echo "  run-alerting - 运行Alerting服务"
	@echo "  run-query    - 运行Query服务"
	@echo "  run-web      - 运行Web服务"

# 构建所有服务
build:
	@echo "构建所有服务..."
	@cd cmd/agent && make build
	@cd cmd/collector && make build
	@cd cmd/processor && make build
	@cd cmd/alerting && make build
	@cd cmd/query && make build
	@cd cmd/web && make build

# 清理构建文件
clean:
	@echo "清理构建文件..."
	@cd cmd/agent && make clean
	@cd cmd/collector && make clean
	@cd cmd/processor && make clean
	@cd cmd/alerting && make clean
	@cd cmd/query && make clean
	@cd cmd/web && make clean
	@rm -rf bin/

# 运行测试
test:
	@echo "运行测试..."
	@cd cmd/agent && make test
	@cd cmd/collector && make test
	@cd cmd/processor && make test
	@cd cmd/alerting && make test
	@cd cmd/query && make test
	@cd cmd/web && make test

# 生成proto文件
proto:
	@echo "生成proto文件..."
	@cd cmd/agent && make proto
	@cd cmd/collector && make proto
	@cd cmd/processor && make proto
	@cd cmd/alerting && make proto
	@cd cmd/query && make proto
	@cd cmd/web && make proto

# 生成依赖注入代码
wire:
	@echo "生成依赖注入代码..."
	@cd cmd/agent && make wire
	@cd cmd/collector && make wire
	@cd cmd/processor && make wire
	@cd cmd/alerting && make wire
	@cd cmd/query && make wire
	@cd cmd/web && make wire

# 构建Docker镜像
docker:
	@echo "构建Docker镜像..."
	@cd cmd/agent && make docker
	@cd cmd/collector && make docker
	@cd cmd/processor && make docker
	@cd cmd/alerting && make docker
	@cd cmd/query && make docker
	@cd cmd/web && make docker

# 启动Docker Compose
docker-compose:
	@echo "启动Docker Compose..."
	@docker-compose up -d

# 运行各个服务
run-agent:
	@echo "运行Agent服务..."
	@cd cmd/agent && make run

run-collector:
	@echo "运行Collector服务..."
	@cd cmd/collector && make run

run-processor:
	@echo "运行Processor服务..."
	@cd cmd/processor && make run

run-alerting:
	@echo "运行Alerting服务..."
	@cd cmd/alerting && make run

run-query:
	@echo "运行Query服务..."
	@cd cmd/query && make run

run-web:
	@echo "运行Web服务..."
	@cd cmd/web && make run

# 安装依赖
deps:
	@echo "安装依赖..."
	@go mod download
	@go mod tidy

# 格式化代码
fmt:
	@echo "格式化代码..."
	@go fmt ./...
	@go vet ./...

# 代码检查
lint:
	@echo "代码检查..."
	@golangci-lint run

# 生成文档
docs:
	@echo "生成文档..."
	@swag init -g cmd/web/cmd/web/main.go -o cmd/web/docs
