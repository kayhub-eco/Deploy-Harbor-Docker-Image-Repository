#!/bin/bash

#############################################################
# Harbor 快速部署脚本 - 简化版本
# 用途：快速启动 Harbor 而无需复杂配置
#############################################################

# 配置变量
HARBOR_VERSION="2.12.3"
HARBOR_PATH="/opt/harbor"
DATA_PATH="/data/harbor"
PROTOCOL="${1:-http}"
HOSTNAME="${2:-$(hostname -I | awk '{print $1}')}"
ADMIN_PASSWORD="${3:-Harbor12345}"

echo "=========================================="
echo "Harbor 快速部署助手"
echo "=========================================="
echo "版本: $HARBOR_VERSION"
echo "路径: $HARBOR_PATH"
echo "协议: $PROTOCOL"
echo "主机名: $HOSTNAME"
echo "=========================================="

# 检查是否为 root
if [[ $EUID -ne 0 ]]; then
    echo "❌ 必须以 root 身份运行 (sudo)"
    exit 1
fi

# 快速部署
deploy_harbor() {
    echo ""
    echo "📦 准备 Harbor 部署..."
    
    # 1. 创建目录
    mkdir -p $DATA_PATH $HARBOR_PATH
    cd /opt
    
    # 2. 检查并下载
    if [[ ! -f "harbor-online-installer-v${HARBOR_VERSION}.tgz" ]]; then
        echo "⬇️  下载 Harbor $HARBOR_VERSION..."
        wget -q https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-online-installer-v${HARBOR_VERSION}.tgz
    fi
    
    # 3. 解压
    echo "📂 解压 Harbor..."
    tar -xzf harbor-online-installer-v${HARBOR_VERSION}.tgz -C /opt/ 2>/dev/null || true
    
    # 4. 生成配置
    echo "⚙️  生成配置..."
    cd $HARBOR_PATH
    cp harbor.yml.tmpl harbor.yml
    
    # 修改配置
    sed -i "s/hostname: .*/hostname: $HOSTNAME/" harbor.yml
    sed -i "s/harbor_admin_password: .*/harbor_admin_password: $ADMIN_PASSWORD/" harbor.yml
    
    # 禁用 HTTPS（如果 protocol 是 http）
    if [[ "$PROTOCOL" == "http" ]]; then
        sed -i '/^https:/,/^[^ ]/s/^/#/' harbor.yml
    fi
    
    # 5. 启动
    echo "🚀 启动 Harbor..."
    ./install.sh --with-trivy --with-clair
    
    echo ""
    echo "✅ Harbor 已部署!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌐 访问地址: $PROTOCOL://$HOSTNAME"
    echo "👤 用户名: admin"
    echo "🔑 密码: $ADMIN_PASSWORD"
    echo "📁 数据位置: $DATA_PATH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 执行部署
deploy_harbor

# 显示状态
echo ""
echo "🔍 Harbor 服务状态:"
docker compose -f $HARBOR_PATH/docker-compose.yml ps
