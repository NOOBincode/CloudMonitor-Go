@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: CloudMonitor-Go Windows 部署脚本

echo [INFO] CloudMonitor-Go 部署脚本
echo.

if "%1"=="" (
    echo 用法: %0 [命令]
    echo.
    echo 命令:
    echo   docker-deploy    部署到Docker环境
    echo   k8s-deploy       部署到Kubernetes环境
    echo   docker-stop      停止Docker服务
    echo   k8s-stop         停止Kubernetes服务
    echo   help             显示此帮助信息
    echo.
    echo 示例:
    echo   %0 docker-deploy
    echo   %0 k8s-deploy
    exit /b 1
)

if "%1"=="docker-deploy" goto docker_deploy
if "%1"=="k8s-deploy" goto k8s_deploy
if "%1"=="docker-stop" goto docker_stop
if "%1"=="k8s-stop" goto k8s_stop
if "%1"=="help" goto show_help

echo [ERROR] 未知命令: %1
goto show_help

:docker_deploy
echo [INFO] 开始Docker部署...
cd deploy\docker
echo [INFO] 构建Docker镜像...
docker-compose build
echo [INFO] 启动服务...
docker-compose up -d
echo [INFO] 检查服务状态...
docker-compose ps
echo [INFO] Docker部署完成！
echo [INFO] 访问地址：
echo [INFO]   - Web界面: http://localhost:8006
echo [INFO]   - Grafana: http://localhost:3000 (admin/admin)
echo [INFO]   - Prometheus: http://localhost:9090
echo [INFO]   - Jaeger: http://localhost:16686
echo [INFO]   - Kibana: http://localhost:5601
goto end

:k8s_deploy
echo [INFO] 开始Kubernetes部署...
cd deploy\kubernetes
echo [INFO] 创建命名空间...
kubectl apply -f namespace.yaml
echo [INFO] 创建ConfigMap...
kubectl apply -f configmap.yaml
echo [INFO] 部署数据库...
kubectl apply -f mysql.yaml
kubectl apply -f redis.yaml
echo [INFO] 等待数据库就绪...
kubectl wait --for=condition=ready pod -l app=cloudmonitor-mysql -n cloudmonitor --timeout=300s
kubectl wait --for=condition=ready pod -l app=cloudmonitor-redis -n cloudmonitor --timeout=300s
echo [INFO] 部署微服务...
kubectl apply -f agent.yaml
kubectl apply -f collector.yaml
kubectl apply -f processor.yaml
kubectl apply -f alerting.yaml
kubectl apply -f query.yaml
kubectl apply -f web.yaml
echo [INFO] 部署监控组件...
kubectl apply -f prometheus.yaml
kubectl apply -f grafana.yaml
kubectl apply -f jaeger.yaml
echo [INFO] 创建Ingress...
kubectl apply -f ingress.yaml
echo [INFO] Kubernetes部署完成！
echo [INFO] 检查服务状态：
kubectl get pods -n cloudmonitor
kubectl get services -n cloudmonitor
goto end

:docker_stop
echo [INFO] 停止Docker服务...
cd deploy\docker
docker-compose down
echo [INFO] Docker服务已停止
goto end

:k8s_stop
echo [INFO] 停止Kubernetes服务...
cd deploy\kubernetes
kubectl delete -f .
echo [INFO] Kubernetes服务已停止
goto end

:show_help
echo CloudMonitor-Go 部署脚本
echo.
echo 用法: %0 [命令]
echo.
echo 命令:
echo   docker-deploy    部署到Docker环境
echo   k8s-deploy       部署到Kubernetes环境
echo   docker-stop      停止Docker服务
echo   k8s-stop         停止Kubernetes服务
echo   help             显示此帮助信息
echo.
echo 示例:
echo   %0 docker-deploy
echo   %0 k8s-deploy
goto end

:end
cd ..\..
echo.
pause
