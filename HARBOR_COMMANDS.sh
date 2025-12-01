#!/bin/bash

#############################################################
# Harbor 管理命令集 & 常用操作
#############################################################

# 设置 Harbor 路径
HARBOR_PATH="/opt/harbor"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_title() {
    echo -e "${BLUE}█████████████████████████████████████████${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}█████████████████████████████████████████${NC}"
}

print_cmd() {
    echo -e "${GREEN}$1${NC}"
}

# ==================== Harbor 基础命令 ====================
print_title "Harbor 基础管理命令"

echo ""
print_cmd "# 1️⃣ 启动 Harbor"
echo "cd $HARBOR_PATH"
echo "docker compose up -d"
echo ""

print_cmd "# 2️⃣ 停止 Harbor"
echo "cd $HARBOR_PATH"
echo "docker compose down"
echo ""

print_cmd "# 3️⃣ 重启 Harbor"
echo "cd $HARBOR_PATH"
echo "docker compose restart"
echo ""

print_cmd "# 4️⃣ 查看 Harbor 状态"
echo "cd $HARBOR_PATH"
echo "docker compose ps"
echo ""

print_cmd "# 5️⃣ 查看 Harbor 日志"
echo "tail -f /data/harbor/logs/harbor.log"
echo ""

print_cmd "# 6️⃣ 查看特定服务日志"
echo "docker compose logs -f harbor-core"
echo "docker compose logs -f registry"
echo "docker compose logs -f harbor-db"
echo ""

# ==================== Docker 镜像操作 ====================
print_title "Docker 镜像操作（以 nginx 为例）"

echo ""
print_cmd "# 1️⃣ 登录 Harbor"
echo "docker login your-harbor-ip"
echo "# 输入用户名: admin"
echo "# 输入密码: 你的密码"
echo ""

print_cmd "# 2️⃣ 推送镜像到 Harbor"
echo "# 打标签"
echo "docker tag nginx:latest your-harbor-ip/library/nginx:latest"
echo ""
echo "# 推送"
echo "docker push your-harbor-ip/library/nginx:latest"
echo ""

print_cmd "# 3️⃣ 拉取镜像从 Harbor"
echo "docker pull your-harbor-ip/library/nginx:latest"
echo ""

print_cmd "# 4️⃣ 查看本地镜像"
echo "docker images | grep your-harbor-ip"
echo ""

# ==================== Harbor 配置管理 ====================
print_title "Harbor 配置管理"

echo ""
print_cmd "# 1️⃣ 查看当前配置"
echo "cat $HARBOR_PATH/harbor.yml | grep -E '^[^#]' | head -20"
echo ""

print_cmd "# 2️⃣ 修改配置（编辑 harbor.yml）"
echo "nano $HARBOR_PATH/harbor.yml"
echo ""

print_cmd "# 3️⃣ 重新应用配置"
echo "cd $HARBOR_PATH"
echo "./prepare  # 生成新配置"
echo "docker compose up -d  # 重启服务"
echo ""

print_cmd "# 4️⃣ 修改管理员密码"
echo "# 方法1：通过 Web UI"
echo "# 登录 Harbor → 用户管理 → 修改密码"
echo ""
echo "# 方法2：通过 API"
echo "curl -X PUT http://admin:oldpass@your-harbor-ip/api/v2.0/users/1/password \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"new_password\": \"newpass\"}'"
echo ""

# ==================== 数据管理 ====================
print_title "Harbor 数据管理"

echo ""
print_cmd "# 1️⃣ 查看 Harbor 数据大小"
echo "du -sh /data/harbor"
echo "du -sh /data/harbor/registry  # 镜像数据大小"
echo "du -sh /data/harbor/database  # 数据库大小"
echo ""

print_cmd "# 2️⃣ 清理未使用的镜像（本地 Docker）"
echo "docker image prune -a"
echo ""

print_cmd "# 3️⃣ Harbor 垃圾回收"
echo "cd $HARBOR_PATH"
echo "docker compose exec registry bin/registry garbage-collect /etc/registry/config.yml"
echo ""

print_cmd "# 4️⃣ 完整备份 Harbor"
echo "cd /opt"
echo "tar -czf harbor_backup_\$(date +%Y%m%d_%H%M%S).tar.gz \\"
echo "  /data/harbor \\"
echo "  /opt/harbor/harbor.yml"
echo ""

print_cmd "# 5️⃣ 数据库备份"
echo "cd $HARBOR_PATH"
echo "docker compose exec -T harbor-db pg_dump -U postgres harbor_db | \\"
echo "  gzip > harbor_db_backup.sql.gz"
echo ""

print_cmd "# 6️⃣ 恢复数据库"
echo "gunzip -c harbor_db_backup.sql.gz | \\"
echo "  docker compose exec -T harbor-db psql -U postgres harbor_db"
echo ""

# ==================== API 操作 ====================
print_title "Harbor API 常用操作"

echo ""
print_cmd "# 1️⃣ 查看系统信息"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/systeminfo"
echo ""

print_cmd "# 2️⃣ 列出所有项目"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/projects"
echo ""

print_cmd "# 3️⃣ 创建新项目"
echo "curl -X POST -u admin:password http://your-harbor-ip/api/v2.0/projects \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"project_name\": \"myproject\", \"public\": false}'"
echo ""

print_cmd "# 4️⃣ 列出项目内的仓库"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/projects/1/repositories"
echo ""

print_cmd "# 5️⃣ 获取镜像标签列表"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/repositories/library/nginx/artifacts"
echo ""

print_cmd "# 6️⃣ 删除镜像"
echo "curl -X DELETE -u admin:password \\"
echo "  http://your-harbor-ip/api/v2.0/projects/1/repositories/nginx/artifacts/tag-name"
echo ""

# ==================== 故障排查 ====================
print_title "故障排查命令"

echo ""
print_cmd "# 1️⃣ 检查所有容器状态"
echo "docker ps -a"
echo "docker compose -f $HARBOR_PATH/docker-compose.yml ps"
echo ""

print_cmd "# 2️⃣ 查看容器错误"
echo "docker logs harbor-core | tail -50"
echo "docker logs harbor-db | tail -50"
echo "docker logs registry | tail -50"
echo ""

print_cmd "# 3️⃣ 检查端口监听"
echo "sudo netstat -tlnp | grep -E ':(80|443)'"
echo "sudo lsof -i :80"
echo "sudo lsof -i :443"
echo ""

print_cmd "# 4️⃣ 检查防火墙"
echo "sudo ufw status"
echo "sudo ufw allow 80/tcp"
echo "sudo ufw allow 443/tcp"
echo ""

print_cmd "# 5️⃣ 检查磁盘空间"
echo "df -h"
echo "du -sh /data/harbor"
echo ""

print_cmd "# 6️⃣ 检查网络连接"
echo "curl -I http://your-harbor-ip"
echo "curl -I http://your-harbor-ip/api/v2.0/"
echo ""

print_cmd "# 7️⃣ 重建 Harbor 容器（保留数据）"
echo "cd $HARBOR_PATH"
echo "docker compose down"
echo "docker compose up -d"
echo ""

print_cmd "# 8️⃣ 完全重置 Harbor（危险！会丢失数据）"
echo "cd $HARBOR_PATH"
echo "docker compose down -v  # -v 删除所有数据"
echo "rm -rf /data/harbor/*"
echo "./install.sh"
echo ""

# ==================== 快速操作脚本 ====================
print_title "快速操作脚本示例"

echo ""
print_cmd "# 1️⃣ 快速重启脚本"
echo "#!/bin/bash"
echo "cd /opt/harbor"
echo "docker compose restart"
echo "echo '等待服务启动...'"
echo "sleep 5"
echo "docker compose ps"
echo ""

print_cmd "# 2️⃣ 完整备份脚本"
echo "#!/bin/bash"
echo "BACKUP_DIR=\"/backup/harbor\""
echo "mkdir -p \$BACKUP_DIR"
echo "cd /opt/harbor"
echo "docker compose down"
echo "tar -czf \$BACKUP_DIR/harbor_\$(date +%Y%m%d_%H%M%S).tar.gz /data/harbor /opt/harbor"
echo "docker compose up -d"
echo "ls -lh \$BACKUP_DIR"
echo ""

print_cmd "# 3️⃣ 性能检查脚本"
echo "#!/bin/bash"
echo "echo '========== 系统资源 =========='"
echo "top -bn1 | head -10"
echo "echo ''"
echo "echo '========== Harbor 容器 =========='"
echo "docker stats --no-stream"
echo "echo ''"
echo "echo '========== 磁盘使用 =========='"
echo "du -sh /data/harbor/*"
echo ""

# ==================== 常见问题快速解决 ====================
print_title "常见问题快速解决方案"

echo ""
print_cmd "❌ 无法推送镜像 → docker login failed"
echo "$ docker login your-harbor-ip"
echo "$ docker logout your-harbor-ip  # 先登出"
echo "$ docker login your-harbor-ip   # 重新登录"
echo ""

print_cmd "❌ 无法拉取镜像 → x509: certificate signed by unknown authority"
echo "$ sudo nano /etc/docker/daemon.json"
echo "# 添加: \"insecure-registries\": [\"your-harbor-ip\"]"
echo "$ sudo systemctl restart docker"
echo ""

print_cmd "❌ Harbor 无法启动 → 查看具体错误"
echo "$ docker compose -f /opt/harbor/docker-compose.yml logs"
echo "$ docker compose -f /opt/harbor/docker-compose.yml restart"
echo ""

print_cmd "❌ 磁盘空间满了"
echo "$ docker compose exec registry bin/registry garbage-collect /etc/registry/config.yml"
echo "$ df -h"
echo ""

print_cmd "❌ 端口被占用"
echo "$ sudo lsof -i :80"
echo "$ sudo kill -9 <PID>"
echo ""

# ==================== 监控与统计 ====================
print_title "监控与统计命令"

echo ""
print_cmd "# 1️⃣ 实时监控容器资源"
echo "docker stats"
echo ""

print_cmd "# 2️⃣ 获取 Harbor 统计信息"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/systeminfo"
echo ""

print_cmd "# 3️⃣ 镜像数量统计"
echo "curl -u admin:password http://your-harbor-ip/api/v2.0/projects | jq '.[] | .repo_count'"
echo ""

print_cmd "# 4️⃣ Harbor 系统日志"
echo "tail -n 1000 /data/harbor/logs/harbor.log | grep ERROR"
echo ""

echo ""
echo -e "${GREEN}提示：将 'your-harbor-ip' 替换为你的 Harbor 服务器 IP${NC}"
echo -e "${GREEN}提示：将 'password' 替换为你的 Harbor 管理员密码${NC}"
echo ""
