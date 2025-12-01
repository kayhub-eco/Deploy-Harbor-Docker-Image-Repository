#!/bin/bash

#############################################################
# Docker 客户端配置脚本 - 配置本地 Docker 连接 Harbor
# 用途：快速配置任何 Docker 客户端连接到 Harbor
#############################################################

HARBOR_IP="${1:-192.168.1.100}"
HARBOR_PORT="${2:-80}"
PROTOCOL="${3:-http}"

echo "=========================================="
echo "Docker 客户端 Harbor 配置工具"
echo "=========================================="
echo "Harbor 地址: $PROTOCOL://$HARBOR_IP:$HARBOR_PORT"
echo "=========================================="

# 检查 Docker 安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    exit 1
fi

# 创建或修改 daemon.json
CONFIG_FILE="/etc/docker/daemon.json"

# 备份现有配置
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)"
    echo "✅ 原配置已备份"
fi

# 创建新配置
cat > "$CONFIG_FILE" << EOF
{
  "insecure-registries": ["$HARBOR_IP:$HARBOR_PORT"],
  "registry-mirrors": ["$PROTOCOL://$HARBOR_IP:$HARBOR_PORT"]
}
EOF

echo "✅ 配置文件已创建: $CONFIG_FILE"
cat "$CONFIG_FILE"

# 重启 Docker
echo ""
echo "🔄 重启 Docker 服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证
echo ""
echo "🔍 验证配置..."
sleep 2
docker info | grep -A 5 "Insecure Registries"

echo ""
echo "✅ 配置完成!"
echo ""
echo "下一步："
echo "1. 登录: docker login $HARBOR_IP"
echo "2. 推送: docker push $HARBOR_IP/library/nginx:latest"
echo "3. 拉取: docker pull $HARBOR_IP/library/nginx:latest"
