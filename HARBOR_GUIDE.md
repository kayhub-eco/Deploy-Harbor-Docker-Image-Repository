# Harbor Docker 镜像仓库 - 配置与使用指南

## 📋 目录
1. [部署步骤](#部署步骤)
2. [Harbor 配置详解](#harbor-配置详解)
3. [Docker 客户端配置](#docker-客户端配置)
4. [使用示例](#使用示例)
5. [常见问题](#常见问题)
6. [维护与备份](#维护与备份)

---

## 部署步骤

### 1️⃣ 快速一键部署

```bash
# 下载部署脚本
wget https://your-server/harbor_deploy.sh

# 设置执行权限
chmod +x harbor_deploy.sh

# 执行部署（HTTP 模式，使用服务器 IP）
sudo bash harbor_deploy.sh http

# 或使用 HTTPS（需要 SSL 证书）
sudo bash harbor_deploy.sh https your-domain.com YourStrongPassword

# 或完整参数
sudo bash harbor_deploy.sh [http|https] [hostname] [admin_password]
```

**参数说明:**
- 第一参数：`http` 或 `https`（默认 http）
- 第二参数：主机名或 IP（默认自动检测）
- 第三参数：管理员密码（默认 Harbor12345）

### 2️⃣ 查看部署进度

```bash
# 查看 Harbor 容器状态
docker compose -f /opt/harbor/docker-compose.yml ps

# 查看实时日志
tail -f /data/harbor/logs/harbor.log

# 查看核心组件日志
docker logs harbor-core
docker logs harbor-jobservice
```

### 3️⃣ 首次访问

```
访问地址：http://your-server-ip
用户名：admin
密码：您在部署时设置的密码
```

---

## Harbor 配置详解

### 核心配置文件位置
```bash
/opt/harbor/harbor.yml
```

### 重要配置项说明

#### HTTP 配置
```yaml
http:
  port: 80  # HTTP 端口，可修改为 8080 等其他端口
```

#### HTTPS 配置（可选）
```yaml
https:
  port: 443
  certificate: /etc/letsencrypt/live/your-domain/fullchain.pem  # SSL 证书路径
  private_key: /etc/letsencrypt/live/your-domain/privkey.pem     # 私钥路径
```

#### 管理员密码
```yaml
harbor_admin_password: Harbor12345
```
⚠️ **强烈建议：** 部署后立即登录并修改密码

#### 数据库配置
```yaml
database:
  password: your-strong-db-password
  max_idle_conns: 100    # 最大空闲连接
  max_open_conns: 900    # 最大打开连接
```

#### 存储路径
```yaml
data_volume: /data/harbor  # 所有数据存储位置
```

#### 镜像扫描
```yaml
clair:
  enabled: true   # Clair 漏洞扫描
trivy:
  enabled: true   # Trivy 漏洞扫描
```

### ⚙️ 修改配置后的操作

```bash
cd /opt/harbor

# 1. 停止 Harbor
docker compose down

# 2. 修改配置
nano harbor.yml

# 3. 重新准备配置（重要！）
./prepare

# 4. 重启 Harbor
docker compose up -d

# 5. 验证
docker compose ps
```

---

## Docker 客户端配置

### 🔧 HTTP 配置（非 HTTPS）

#### Ubuntu/Debian 客户端

```bash
# 1. 编辑 Docker 配置
sudo nano /etc/docker/daemon.json

# 2. 添加以下内容（如果文件为空，复制整个内容）
{
  "insecure-registries": ["your-harbor-ip:80"],
  "registry-mirrors": ["http://your-harbor-ip"]
}

# 3. 保存并关闭，然后重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 4. 验证配置
docker info | grep -A 5 "Insecure Registries"
```

#### CentOS/RHEL 客户端

```bash
sudo nano /etc/docker/daemon.json
# 配置同上
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### Windows Docker Desktop

```
Settings → Docker Engine → daemon.json

{
  "insecure-registries": ["your-harbor-ip:80"],
  "registry-mirrors": ["http://your-harbor-ip"]
}

点击 "Apply & Restart"
```

#### macOS Docker Desktop

```
Docker Menu → Preferences → Docker Engine → daemon.json

{
  "insecure-registries": ["your-harbor-ip:80"],
  "registry-mirrors": ["http://your-harbor-ip"]
}

点击 "Apply & Restart"
```

### 🔒 HTTPS 配置（使用自签名证书）

#### 1️⃣ 获取服务器证书

```bash
# 从 Harbor 服务器获取证书
scp root@your-harbor-ip:/opt/harbor/certs/harbor.crt ~/harbor.crt
```

#### 2️⃣ 在客户端安装证书

**Ubuntu/Debian:**
```bash
# 复制证书到信任目录
sudo mkdir -p /usr/local/share/ca-certificates
sudo cp harbor.crt /usr/local/share/ca-certificates/

# 更新证书
sudo update-ca-certificates

# 重启 Docker
sudo systemctl restart docker
```

**CentOS/RHEL:**
```bash
sudo cp harbor.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
sudo systemctl restart docker
```

#### 3️⃣ Docker 配置

```bash
{
  "insecure-registries": [],
  "registry-mirrors": ["https://your-harbor-ip"]
}
```

---

## 使用示例

### 📌 基础操作

#### 登录 Harbor

```bash
docker login your-harbor-ip
# 输入用户名：admin
# 输入密码：你设置的密码
```

#### 推送镜像到 Harbor

```bash
# 1. 给本地镜像打标签
docker tag nginx:latest your-harbor-ip/library/nginx:latest

# 2. 推送到 Harbor
docker push your-harbor-ip/library/nginx:latest

# 3. 验证
docker images
```

#### 从 Harbor 拉取镜像

```bash
# 方式1：直接从 Harbor 拉取
docker pull your-harbor-ip/library/nginx:latest

# 方式2：通过镜像源自动拉取（配置 registry-mirrors 后）
docker pull nginx:latest
# 会自动从 Harbor 查找，如果没有会从 Docker Hub 拉取并缓存
```

### 🏢 项目管理

#### 创建项目

Harbor Web UI 操作：
1. 登录 Harbor → 项目 → 新建项目
2. 项目名称：`myproject`
3. 访问级别：公开/私有

或使用命令行：
```bash
# 使用 curl 创建项目
curl -X POST http://admin:password@your-harbor-ip/api/v2.0/projects \
  -H "Content-Type: application/json" \
  -d '{
    "project_name": "myproject",
    "public": false
  }'
```

#### 推送到自定义项目

```bash
docker tag my-app:1.0 your-harbor-ip/myproject/my-app:1.0
docker push your-harbor-ip/myproject/my-app:1.0
```

### 🔄 镜像复制（仓库同步）

#### Harbor Web UI 设置镜像源

1. 登录 Harbor
2. 项目 → 项目名称 → 仓库管理 → 新建仓库
3. 添加镜像源（如 Docker Hub、Quay 等）
4. Harbor 会自动从源仓库拉取并缓存镜像

#### 使用 API 创建镜像源

```bash
curl -X POST http://admin:password@your-harbor-ip/api/v2.0/registries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "dockerhub",
    "type": "docker-registry",
    "url": "https://registry-1.docker.io",
    "credential": {
      "access_key": "dockerhub_username",
      "access_secret": "dockerhub_token"
    },
    "insecure": false
  }'
```

---

## 常见问题

### ❌ 问题 1：无法推送/拉取镜像，提示 "no basic auth credentials"

**解决方案：**
```bash
# 确保已登录
docker login your-harbor-ip

# 如果仍失败，检查凭证
cat ~/.docker/config.json

# 重新登出后登录
docker logout your-harbor-ip
docker login your-harbor-ip
```

### ❌ 问题 2：HTTPS 连接错误 "x509: certificate signed by unknown authority"

**解决方案：**
```bash
# 方案 A：信任自签名证书
sudo nano /etc/docker/daemon.json
# 添加: "insecure-registries": ["your-harbor-ip"]

# 方案 B：安装证书（见前面 HTTPS 配置部分）

# 重启 Docker
sudo systemctl restart docker
```

### ❌ 问题 3：Harbor 容器无法启动或启动失败

**诊断步骤：**
```bash
# 查看所有容器状态
docker compose -f /opt/harbor/docker-compose.yml ps

# 查看具体错误日志
docker logs harbor-core
docker logs harbor-db
docker logs registry

# 查看完整日志文件
tail -n 100 /data/harbor/logs/harbor.log

# 重新启动所有服务
cd /opt/harbor
docker compose restart
```

### ❌ 问题 4：磁盘空间不足

**解决方案：**
```bash
# 查看 Harbor 数据占用
du -sh /data/harbor/

# 查看镜像占用
du -sh /data/harbor/registry/

# 清理未使用的镜像（危险操作，请谨慎）
docker image prune -a

# 清理 Harbor 垃圾数据
cd /opt/harbor
docker compose exec registry bin/registry garbage-collect /etc/registry/config.yml

# 如需删除具体镜像，在 Harbor Web UI 中操作
```

### ❌ 问题 5：无法访问 Harbor Web UI

**诊断步骤：**
```bash
# 检查防火墙
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 检查端口是否监听
sudo netstat -tlnp | grep -E ':(80|443)'

# 查看 nginx 日志
docker logs harbor-nginx

# 验证 Harbor 服务状态
cd /opt/harbor
docker compose logs nginx
```

---

## 维护与备份

### 💾 备份 Harbor 数据

#### 完整备份

```bash
#!/bin/bash
# backup_harbor.sh

BACKUP_DIR="/backup/harbor"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/harbor_backup_$TIMESTAMP.tar.gz"

mkdir -p $BACKUP_DIR

# 停止 Harbor（可选，建议做）
cd /opt/harbor
docker compose down

# 备份数据和配置
tar -czf $BACKUP_FILE \
  /data/harbor \
  /opt/harbor/harbor.yml \
  /opt/harbor/certs 2>/dev/null || true

# 启动 Harbor
docker compose up -d

# 显示备份大小
du -h $BACKUP_FILE

echo "备份完成：$BACKUP_FILE"
```

**使用：**
```bash
chmod +x backup_harbor.sh
sudo ./backup_harbor.sh
```

#### 数据库备份

```bash
# 导出数据库
docker compose exec -T harbor-db pg_dump -U postgres harbor_db \
  | gzip > harbor_db_backup.sql.gz

# 导入数据库（恢复时）
gunzip -c harbor_db_backup.sql.gz | \
  docker compose exec -T harbor-db psql -U postgres harbor_db
```

#### 定时备份（Cron）

```bash
# 编辑 cron 任务
sudo crontab -e

# 添加每天 2:00 AM 备份
0 2 * * * /path/to/backup_harbor.sh >> /var/log/harbor_backup.log 2>&1
```

### 🔄 升级 Harbor

```bash
cd /opt/harbor

# 1. 备份当前版本（重要！）
sudo ./backup_harbor.sh

# 2. 停止 Harbor
docker compose down

# 3. 备份配置文件
cp harbor.yml harbor.yml.backup

# 4. 下载新版本
cd /opt
wget https://github.com/goharbor/harbor/releases/download/v2.13.0/harbor-online-installer-v2.13.0.tgz
tar -xzf harbor-online-installer-v2.13.0.tgz -C /opt/

# 5. 复制旧配置到新目录
cp /opt/harbor/harbor.yml.backup /opt/harbor/harbor.yml

# 6. 重新部署
cd /opt/harbor
./install.sh --with-trivy --with-clair
```

### 📊 监控与日志

```bash
# 查看 Harbor 系统信息
curl http://admin:password@your-harbor-ip/api/v2.0/systeminfo

# 监控实时日志
docker compose logs -f

# 监控特定服务
docker compose logs -f harbor-core

# 查看镜像统计
curl http://admin:password@your-harbor-ip/api/v2.0/repositories

# 查看项目列表
curl http://admin:password@your-harbor-ip/api/v2.0/projects
```

### 🛠️ 常用命令速查

```bash
# 启动 Harbor
cd /opt/harbor && docker compose up -d

# 停止 Harbor
cd /opt/harbor && docker compose down

# 重启 Harbor
cd /opt/harbor && docker compose restart

# 查看状态
cd /opt/harbor && docker compose ps

# 查看日志
tail -f /data/harbor/logs/harbor.log

# 查看容器实时日志
docker compose logs -f [service-name]

# 进入容器
docker compose exec [service-name] /bin/bash

# 清理磁盘
cd /opt/harbor && docker compose exec registry bin/registry garbage-collect /etc/registry/config.yml

# 重新加载配置
cd /opt/harbor && ./prepare && docker compose up -d
```

---

## 安全建议

1. ✅ **修改默认密码** - 首次登录后立即修改 admin 密码
2. ✅ **启用 HTTPS** - 生产环境强烈建议使用 HTTPS
3. ✅ **定期备份** - 建立自动备份机制
4. ✅ **防火墙配置** - 限制 Harbor 访问 IP
5. ✅ **启用漏洞扫描** - 配置 Clair/Trivy 定期扫描镜像
6. ✅ **管理员账号** - 使用强密码，定期更新
7. ✅ **日志监控** - 定期检查异常登录和操作日志

---

## 获取帮助

- Harbor 官方文档：https://goharbor.io/docs/
- GitHub Issues：https://github.com/goharbor/harbor/issues
- 社区论坛：https://github.com/goharbor/harbor/discussions
