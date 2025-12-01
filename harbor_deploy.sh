#!/bin/bash

#############################################################
# Harbor 自动部署脚本 for Ubuntu 24.04
# 功能：一键安装 Docker、Harbor、配置 SSL
# 使用方法：bash harbor_deploy.sh [http|https] [hostname] [admin_password]
#############################################################

set -e  # 任何命令失败都退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 参数处理
PROTOCOL=${1:-http}  # 默认 HTTP，可选值：http 或 https
HOSTNAME=${2:-$(hostname -I | awk '{print $1}')}  # 默认使用本机 IP
ADMIN_PASSWORD=${3:-Harbor12345}  # 默认密码，建议修改
DB_PASSWORD=$(openssl rand -base64 32)  # 生成随机数据库密码

# 检查权限
if [[ $EUID -ne 0 ]]; then
    log_error "此脚本必须以 root 身份运行"
    exit 1
fi

log_info "========================================="
log_info "Harbor 自动部署脚本"
log_info "========================================="
log_info "协议: $PROTOCOL"
log_info "主机名/IP: $HOSTNAME"
log_info "管理员密码: $ADMIN_PASSWORD"
log_info "========================================="

# ============ Step 1: 更新系统 ============
log_info "Step 1: 更新系统..."
apt update -y
apt upgrade -y
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    openssl \
    wget \
    git

log_success "系统已更新"

# ============ Step 2: 安装 Docker ============
log_info "Step 2: 检查并安装 Docker..."

if command -v docker &> /dev/null; then
    log_warning "Docker 已安装: $(docker --version)"
else
    log_info "安装 Docker CE..."
    
    # 添加 Docker 官方 GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # 添加 Docker 仓库
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装 Docker
    apt update -y
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # 启动 Docker
    systemctl start docker
    systemctl enable docker
    
    log_success "Docker 已安装"
fi

# 验证 Docker
docker --version
docker compose version

# ============ Step 3: 创建 Harbor 目录 ============
log_info "Step 3: 创建 Harbor 目录结构..."

mkdir -p /opt/harbor
mkdir -p /data/harbor
mkdir -p /data/harbor/registry
mkdir -p /data/harbor/database
mkdir -p /opt/harbor/certs

chmod 755 /data/harbor
chmod 755 /data/harbor/registry
chmod 755 /data/harbor/database

log_success "Harbor 目录已创建"

# ============ Step 4: 处理 SSL 证书 ============
if [[ "$PROTOCOL" == "https" ]]; then
    log_info "Step 4a: 配置 HTTPS..."
    
    # 检查是否有 Let's Encrypt 证书
    if command -v certbot &> /dev/null && [[ -f "/etc/letsencrypt/live/${HOSTNAME}/fullchain.pem" ]]; then
        log_info "使用现有 Let's Encrypt 证书..."
        CERT_PATH="/etc/letsencrypt/live/${HOSTNAME}/fullchain.pem"
        KEY_PATH="/etc/letsencrypt/live/${HOSTNAME}/privkey.pem"
    else
        log_info "生成自签名证书..."
        
        openssl req \
            -newkey rsa:4096 \
            -nodes \
            -sha256 \
            -keyout /opt/harbor/certs/harbor.key \
            -addext "subjectAltName = DNS:${HOSTNAME}" \
            -x509 \
            -days 365 \
            -out /opt/harbor/certs/harbor.crt \
            -subj "/CN=${HOSTNAME}/O=Harbor/OU=Harbor/C=CN"
        
        CERT_PATH="/opt/harbor/certs/harbor.crt"
        KEY_PATH="/opt/harbor/certs/harbor.key"
        
        log_success "自签名证书已生成"
    fi
else
    log_info "Step 4b: 使用 HTTP（跳过 HTTPS 配置）..."
fi

# ============ Step 5: 下载 Harbor ============
log_info "Step 5: 下载 Harbor..."

cd /opt

# 获取最新版本
HARBOR_VERSION="2.12.3"
HARBOR_URL="https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-online-installer-v${HARBOR_VERSION}.tgz"

if [[ -f "harbor-online-installer-v${HARBOR_VERSION}.tgz" ]]; then
    log_warning "Harbor 安装包已存在，跳过下载"
else
    log_info "从 GitHub 下载 Harbor $HARBOR_VERSION..."
    wget -q "$HARBOR_URL" -O "harbor-online-installer-v${HARBOR_VERSION}.tgz"
    
    if [[ $? -ne 0 ]]; then
        log_error "Harbor 下载失败，请检查网络连接或手动下载"
        exit 1
    fi
fi

log_success "Harbor 已下载"

# ============ Step 6: 解压并设置权限 ============
log_info "Step 6: 解压 Harbor..."

tar -xzf "harbor-online-installer-v${HARBOR_VERSION}.tgz" -C /opt/
chown -R root:root /opt/harbor
chmod +x /opt/harbor/install.sh
chmod +x /opt/harbor/prepare

log_success "Harbor 已解压"

# ============ Step 7: 生成 harbor.yml 配置 ============
log_info "Step 7: 生成 harbor.yml 配置文件..."

cd /opt/harbor

# 备份原配置
if [[ -f "harbor.yml" ]]; then
    cp harbor.yml harbor.yml.bak.$(date +%s)
fi

# 根据协议生成配置
if [[ "$PROTOCOL" == "https" ]]; then
    cat > harbor.yml << EOF
# Harbor 配置文件

# 主机名或域名
hostname: $HOSTNAME

# HTTP 配置
http:
  port: 80

# HTTPS 配置
https:
  port: 443
  certificate: $CERT_PATH
  private_key: $KEY_PATH

# 管理员密码
harbor_admin_password: $ADMIN_PASSWORD

# 数据库配置
database:
  password: $DB_PASSWORD
  max_idle_conns: 100
  max_open_conns: 900

# 数据卷路径
data_volume: /data/harbor

# Clair 漏洞扫描
clair:
  enabled: true

# Trivy 漏洞扫描
trivy:
  enabled: true

# 日志级别
log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /data/harbor/logs

# 注意事项
_version: 2.12.0
EOF
else
    cat > harbor.yml << EOF
# Harbor 配置文件

# 主机名或域名
hostname: $HOSTNAME

# HTTP 配置
http:
  port: 80

# HTTPS 配置（注释掉以禁用 HTTPS）
# https:
#   port: 443
#   certificate: /your/certificate/path
#   private_key: /your/private/key/path

# 管理员密码
harbor_admin_password: $ADMIN_PASSWORD

# 数据库配置
database:
  password: $DB_PASSWORD
  max_idle_conns: 100
  max_open_conns: 900

# 数据卷路径
data_volume: /data/harbor

# Clair 漏洞扫描
clair:
  enabled: true

# Trivy 漏洞扫描
trivy:
  enabled: true

# 日志级别
log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /data/harbor/logs

# 注意事项
_version: 2.12.0
EOF
fi

log_success "harbor.yml 已生成"

# 显示配置内容
log_info "harbor.yml 配置文件内容："
cat harbor.yml

# ============ Step 8: 运行安装脚本 ============
log_info "Step 8: 运行 Harbor 安装脚本..."
log_info "这可能需要 5-15 分钟，请耐心等待..."

./install.sh --with-trivy --with-clair

if [[ $? -ne 0 ]]; then
    log_error "Harbor 安装失败，请检查错误日志"
    exit 1
fi

log_success "Harbor 安装成功！"

# ============ Step 9: 验证安装 ============
log_info "Step 9: 验证 Harbor 状态..."

sleep 5

docker compose ps

# ============ Step 10: 显示访问信息 ============
log_info "========================================="
log_success "Harbor 部署完成！"
log_info "========================================="

if [[ "$PROTOCOL" == "https" ]]; then
    log_info "访问地址: https://$HOSTNAME"
    log_warning "证书类型: $([ -f /etc/letsencrypt/live/${HOSTNAME}/fullchain.pem ] && echo 'Let'\''s Encrypt' || echo '自签名')"
else
    log_info "访问地址: http://$HOSTNAME"
fi

log_info "用户名: admin"
log_info "密码: $ADMIN_PASSWORD"
log_info "数据库密码: $DB_PASSWORD (已保存到系统)"

log_info "========================================="
log_info "重要提示:"
log_info "1. 首次访问可能需要 1-2 分钟初始化"
log_info "2. 建议修改管理员密码 (登录后在设置中修改)"
log_info "3. 如使用自签名证书，Docker 客户端需要配置"
log_info "4. Harbor 日志位置: /data/harbor/logs"
log_info "========================================="

# ============ Step 11: 生成快速命令参考 ============
log_info "常用 Harbor 命令:"
echo ""
echo "# 查看运行状态"
echo "docker compose -f /opt/harbor/docker-compose.yml ps"
echo ""
echo "# 启动 Harbor"
echo "cd /opt/harbor && docker compose up -d"
echo ""
echo "# 停止 Harbor"
echo "cd /opt/harbor && docker compose down"
echo ""
echo "# 重启 Harbor"
echo "cd /opt/harbor && docker compose restart"
echo ""
echo "# 查看日志"
echo "tail -f /data/harbor/logs/harbor.log"
echo ""
echo "# 备份 Harbor 数据"
echo "sudo tar -czf harbor-backup-\$(date +%Y%m%d_%H%M%S).tar.gz /data/harbor /opt/harbor"
echo ""

# 保存配置信息到文件
cat > /opt/harbor/DEPLOYMENT_INFO.txt << EOF
=================================================
Harbor 部署信息
=================================================
部署时间: $(date)
服务器 IP/主机名: $HOSTNAME
协议: $PROTOCOL
管理员密码: $ADMIN_PASSWORD
数据库密码: $DB_PASSWORD
Harbor 版本: $HARBOR_VERSION
=================================================
EOF

log_success "部署信息已保存到 /opt/harbor/DEPLOYMENT_INFO.txt"

exit 0
