#!/bin/bash

# CloudMonitor-Go 部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 检查Docker部署
deploy_docker() {
    print_info "开始Docker部署..."
    
    check_command docker
    check_command docker-compose
    
    cd deploy/docker
    
    print_info "构建Docker镜像..."
    docker-compose build
    
    print_info "启动服务..."
    docker-compose up -d
    
    print_info "检查服务状态..."
    docker-compose ps
    
    print_info "Docker部署完成！"
    print_info "访问地址："
    print_info "  - Web界面: http://localhost:8006"
    print_info "  - Grafana: http://localhost:3000 (admin/admin)"
    print_info "  - Prometheus: http://localhost:9090"
    print_info "  - Jaeger: http://localhost:16686"
    print_info "  - Kibana: http://localhost:5601"
}

# 检查Kubernetes部署
deploy_kubernetes() {
    print_info "开始Kubernetes部署..."
    
    check_command kubectl
    
    cd deploy/kubernetes
    
    print_info "创建命名空间..."
    kubectl apply -f namespace.yaml
    
    print_info "创建ConfigMap..."
    kubectl apply -f configmap.yaml
    
    print_info "部署数据库..."
    kubectl apply -f mysql.yaml
    kubectl apply -f redis.yaml
    
    print_info "等待数据库就绪..."
    kubectl wait --for=condition=ready pod -l app=cloudmonitor-mysql -n cloudmonitor --timeout=300s
    kubectl wait --for=condition=ready pod -l app=cloudmonitor-redis -n cloudmonitor --timeout=300s
    
    print_info "部署微服务..."
    kubectl apply -f agent.yaml
    kubectl apply -f collector.yaml
    kubectl apply -f processor.yaml
    kubectl apply -f alerting.yaml
    kubectl apply -f query.yaml
    kubectl apply -f web.yaml
    
    print_info "部署监控组件..."
    kubectl apply -f prometheus.yaml
    kubectl apply -f grafana.yaml
    kubectl apply -f jaeger.yaml
    
    print_info "创建Ingress..."
    kubectl apply -f ingress.yaml
    
    print_info "Kubernetes部署完成！"
    print_info "检查服务状态："
    kubectl get pods -n cloudmonitor
    kubectl get services -n cloudmonitor
}

# 停止Docker服务
stop_docker() {
    print_info "停止Docker服务..."
    cd deploy/docker
    docker-compose down
    print_info "Docker服务已停止"
}

# 停止Kubernetes服务
stop_kubernetes() {
    print_info "停止Kubernetes服务..."
    cd deploy/kubernetes
    kubectl delete -f .
    print_info "Kubernetes服务已停止"
}

# 显示帮助信息
show_help() {
    echo "CloudMonitor-Go 部署脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  docker-deploy    部署到Docker环境"
    echo "  k8s-deploy       部署到Kubernetes环境"
    echo "  docker-stop      停止Docker服务"
    echo "  k8s-stop         停止Kubernetes服务"
    echo "  help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 docker-deploy"
    echo "  $0 k8s-deploy"
}

# 主函数
main() {
    case "$1" in
        "docker-deploy")
            deploy_docker
            ;;
        "k8s-deploy")
            deploy_kubernetes
            ;;
        "docker-stop")
            stop_docker
            ;;
        "k8s-stop")
            stop_kubernetes
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
