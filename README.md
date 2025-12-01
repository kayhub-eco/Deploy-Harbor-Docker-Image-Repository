# Harbor Docker 镜像仓库 - 部署包说明文档

## 📦 包含的文件

本部署包包含以下脚本和文档：

```
harbor_deploy.sh              ✅ 完整版自动部署脚本（推荐用于生产环境）
harbor_quick_deploy.sh        ⚡ 快速部署脚本（推荐用于快速测试）
configure_docker_client.sh    🔧 Docker 客户端配置脚本
HARBOR_GUIDE.md              📖 完整使用指南
HARBOR_COMMANDS.sh           📋 常用命令参考手册
README.md                    📝 本文件
```

---

## 🚀 快速开始（5分钟快速部署）

### Step 1: 登录服务器并下载脚本

```bash
# 连接到你的 Ubuntu 24.04 服务器
ssh root@your-server-ip

# 下载快速部署脚本
wget https://your-script-location/harbor_quick_deploy.sh
chmod +x harbor_quick_deploy.sh
```

### Step 2: 执行部署

```bash
# 基础部署（HTTP，使用服务器 IP）
sudo bash harbor_quick_deploy.sh

# 或指定参数
sudo bash harbor_quick_deploy.sh http 192.168.1.100 Harbor12345
```

### Step 3: 访问 Harbor Web UI

部署完成后，在浏览器访问：
```
http://your-server-ip
用户名: admin
密码: Harbor12345
```

---

## 📋 脚本详细说明

### 1️⃣ 完整部署脚本 (harbor_deploy.sh)

**特点：**
- ✅ 完全自动化，包含所有步骤
- ✅ 支持 HTTP 和 HTTPS
- ✅ 自动生成自签名证书（如需要）
- ✅ 安装 Docker、Docker Compose
- ✅ 支持 Let's Encrypt 证书
- ✅ 彩色输出和详细日志
- ✅ 自动备份配置

**使用方式：**

```bash
# HTTP 模式（推荐快速测试）
sudo bash harbor_deploy.sh http

# HTTPS 模式（生产环境）
sudo bash harbor_deploy.sh https registry.example.com MyStrongPassword123

# 完整参数
sudo bash harbor_deploy.sh [http|https] [hostname] [admin_password]
```

**参数说明：**
- 参数1：`http` 或 `https`（默认 http）
- 参数2：主机名或 IP（默认自动检测）
- 参数3：管理员密码（默认 Harbor12345）

**脚本执行步骤：**
1. 更新系统和安装依赖
2. 安装 Docker CE 和 Docker Compose
3. 创建 Harbor 目录结构
4. 生成 SSL 证书（如需要）
5. 下载 Harbor 安装包
6. 配置 harbor.yml
7. 运行安装脚本
8. 验证部署状态
9. 显示访问信息

---

### 2️⃣ 快速部署脚本 (harbor_quick_deploy.sh)

**特点：**
- ⚡ 体积小，执行快
- ⚡ 自动检测 Docker 安装
- ⚡ 简化参数配置
- ⚡ 最少依赖

**使用方式：**

```bash
# 最简单的方式
sudo bash harbor_quick_deploy.sh

# 指定协议和主机名
sudo bash harbor_quick_deploy.sh http 192.168.1.100

# 完整参数
sudo bash harbor_quick_deploy.sh [protocol] [hostname] [password]
```

---

### 3️⃣ Docker 客户端配置脚本 (configure_docker_client.sh)

**作用：**配置任何 Docker 客户端连接到你的 Harbor 仓库

**使用方式：**

```bash
# 在客户机（不是 Harbor 服务器）上执行
sudo bash configure_docker_client.sh 192.168.1.100 80 http

# 参数说明：
# 参数1：Harbor 服务器 IP 地址
# 参数2：Harbor 服务器端口（默认 80）
# 参数3：协议 http/https（默认 http）
```

**脚本操作：**
1. 检查 Docker 安装
2. 备份原配置
3. 创建新的 daemon.json
4. 重启 Docker 服务
5. 验证配置

---

## 📖 完整部署指南 (HARBOR_GUIDE.md)

这个文档包含：
- 详细的部署步骤
- Harbor 配置参数详解
- Docker 客户端各平台配置（Windows, macOS, Linux）
- 使用示例和常见操作
- 常见问题解答
- 备份和恢复操作
- 升级说明

**建议阅读此文档以了解：**
- HTTPS 配置
- 镜像源设置
- 项目管理
- API 使用
- 故障排查

---

## 📋 常用命令参考 (HARBOR_COMMANDS.sh)

这是一个可视化的命令参考手册，包含：

### 基础管理命令
```bash
# 启动 Harbor
cd /opt/harbor && docker compose up -d

# 停止 Harbor
cd /opt/harbor && docker compose down

# 重启 Harbor
cd /opt/harbor && docker compose restart

# 查看状态
docker compose ps
```

### 镜像操作
```bash
# 登录
docker login your-harbor-ip

# 推送
docker tag nginx:latest your-harbor-ip/library/nginx:latest
docker push your-harbor-ip/library/nginx:latest

# 拉取
docker pull your-harbor-ip/library/nginx:latest
```

### 备份和恢复
```bash
# 完整备份
tar -czf harbor_backup.tar.gz /data/harbor /opt/harbor/harbor.yml

# 数据库备份
docker compose exec -T harbor-db pg_dump -U postgres harbor_db | gzip > db_backup.sql.gz
```

### API 操作
```bash
# 查看系统信息
curl -u admin:password http://your-harbor-ip/api/v2.0/systeminfo

# 列出项目
curl -u admin:password http://your-harbor-ip/api/v2.0/projects

# 创建项目
curl -X POST -u admin:password http://your-harbor-ip/api/v2.0/projects \
  -H 'Content-Type: application/json' \
  -d '{"project_name": "myproject", "public": false}'
```

---

## 🛠️ 部署前的准备

### 系统要求

| 项目 | 要求 |
|-----|------|
| **操作系统** | Ubuntu 24.04 LTS |
| **CPU** | 2核+ （推荐4核） |
| **内存** | 4GB+（推荐8GB） |
| **磁盘** | 40GB+（根据镜像数量增加） |
| **网络** | 1GB 宽带推荐 |

### 网络配置

需要开放以下端口：

```bash
# HTTP
sudo ufw allow 80/tcp

# HTTPS (可选)
sudo ufw allow 443/tcp

# SSH (如果需要远程管理)
sudo ufw allow 22/tcp

# 启用防火墙
sudo ufw enable
```

### 域名配置（可选但推荐）

如果要使用域名而不是 IP：

1. 在 DNS 中添加 A 记录指向服务器 IP
2. 配置 SSL 证书（Let's Encrypt 或自签名）
3. 在部署脚本中使用域名而不是 IP

---

## 🚀 部署流程总结

### 方案 A：快速部署（推荐用于测试）

```bash
# 1. SSH 连接服务器
ssh root@your-server-ip

# 2. 下载快速脚本
wget https://your-location/harbor_quick_deploy.sh
chmod +x harbor_quick_deploy.sh

# 3. 执行部署
sudo bash harbor_quick_deploy.sh http

# 4. 等待部署完成（5-15 分钟）

# 5. 访问 Harbor
# 在浏览器打开: http://your-server-ip
# 用户名: admin
# 密码: Harbor12345
```

### 方案 B：完整部署（推荐用于生产）

```bash
# 1. SSH 连接服务器
ssh root@your-server-ip

# 2. 下载完整脚本
wget https://your-location/harbor_deploy.sh
chmod +x harbor_deploy.sh

# 3. 执行部署（使用 HTTPS）
sudo bash harbor_deploy.sh https your-domain.com YourStrongPassword

# 4. 等待部署完成（5-15 分钟）

# 5. 访问 Harbor
# 在浏览器打开: https://your-domain.com
# 用户名: admin
# 密码: YourStrongPassword
```

### 方案 C：手动部署（学习和自定义）

如果脚本无法完成，可以手动执行：

```bash
# 1. 安装 Docker
sudo apt update && sudo apt install -y docker.io docker-compose-plugin

# 2. 下载 Harbor
cd /opt
sudo wget https://github.com/goharbor/harbor/releases/download/v2.12.3/harbor-online-installer-v2.12.3.tgz
sudo tar -xzf harbor-online-installer-v2.12.3.tgz

# 3. 配置
cd harbor
sudo cp harbor.yml.tmpl harbor.yml
sudo nano harbor.yml  # 修改主机名和密码

# 4. 安装
sudo ./install.sh --with-trivy --with-clair

# 5. 验证
docker compose ps
```

---

## 🔧 部署后的常见操作

### 修改管理员密码

```bash
# 登录 Harbor Web UI
# 点击右上角用户菜单 → 修改密码
```

### 配置 Docker 客户端

在任何需要使用 Harbor 的机器上：

```bash
# 下载客户端配置脚本
wget https://your-location/configure_docker_client.sh
chmod +x configure_docker_client.sh

# 配置
sudo bash configure_docker_client.sh 192.168.1.100 80 http

# 测试
docker pull your-harbor-ip/library/nginx:latest
```

### 推送第一个镜像

```bash
# 1. 登录
docker login your-harbor-ip

# 2. 拉取一个公共镜像
docker pull nginx

# 3. 打标签
docker tag nginx:latest your-harbor-ip/library/nginx:latest

# 4. 推送到 Harbor
docker push your-harbor-ip/library/nginx:latest

# 5. 在 Harbor Web UI 中验证
```

### 创建新项目

```bash
# 通过 Web UI
# 登录 → 项目 → 新建项目 → 输入项目名称

# 或通过 API
curl -X POST -u admin:password http://your-harbor-ip/api/v2.0/projects \
  -H 'Content-Type: application/json' \
  -d '{
    "project_name": "my-project",
    "public": false
  }'
```

---

## ❌ 常见问题快速解决

### Q: 部署失败，显示 "Permission denied"
**A:** 使用 `sudo` 执行脚本
```bash
sudo bash harbor_deploy.sh http
```

### Q: Docker 命令提示权限不足
**A:** 将用户添加到 docker 组
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Q: 无法访问 Harbor Web UI
**A:** 检查防火墙和端口
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
docker compose ps  # 检查容器状态
```

### Q: 推送镜像时显示 "unauthorized"
**A:** 重新登录 Harbor
```bash
docker logout your-harbor-ip
docker login your-harbor-ip
```

### Q: 磁盘空间不足
**A:** 执行垃圾回收
```bash
cd /opt/harbor
docker compose exec registry bin/registry garbage-collect /etc/registry/config.yml
```

---

## 📊 部署后的关键信息

部署完成后，请妥善保存以下信息：

```
Harbor 访问地址: ___________________________
服务器 IP: _______________________________
服务器用户名: _____________________________
SSH 私钥位置: _____________________________
管理员用户名: _____________________________
管理员密码: _______________________________
Harbor 数据路径: ___________________________
Harbor 安装路径: ___________________________
数据库密码: _______________________________
SSL 证书路径: _____________________________
```

---

## 📚 进阶配置

### 配置镜像源（从 Docker Hub 自动拉取并缓存）

在 Harbor Web UI 中：
1. 登录 → 系统管理 → 仓库
2. 新建镜像源
3. 配置 Docker Hub 或其他源的凭据

### 启用 LDAP 认证

在 Harbor Web UI 中：
1. 登录 → 系统管理 → 配置管理
2. 认证 → LDAP 配置

### 配置邮件通知

在 Harbor Web UI 中：
1. 登录 → 系统管理 → 配置管理
2. 邮件设置

### 定时备份

```bash
# 创建备份脚本
cat > /usr/local/bin/harbor_backup.sh << 'EOF'
#!/bin/bash
cd /opt/harbor
docker compose down
tar -czf /backup/harbor_$(date +%Y%m%d_%H%M%S).tar.gz /data/harbor /opt/harbor
docker compose up -d
EOF

chmod +x /usr/local/bin/harbor_backup.sh

# 添加到 crontab
sudo crontab -e
# 添加行: 0 2 * * * /usr/local/bin/harbor_backup.sh
```

---

## 🆘 获取帮助

- **官方文档**: https://goharbor.io/docs/
- **GitHub Issues**: https://github.com/goharbor/harbor/issues
- **社区论坛**: https://github.com/goharbor/harbor/discussions

---

## ✅ 部署清单

部署前请检查：
- [ ] 系统升级到最新 (`sudo apt update && sudo apt upgrade`)
- [ ] 磁盘空间充足 (`df -h`)
- [ ] 网络连接正常
- [ ] 防火墙配置完成
- [ ] 备有 SSH 密钥或密码

部署时：
- [ ] 脚本具有执行权限 (`chmod +x`)
- [ ] 以 root 身份执行 (`sudo`)
- [ ] 记录部署日志（如需故障排查）

部署后：
- [ ] 能访问 Harbor Web UI
- [ ] 能成功登录
- [ ] 修改默认密码
- [ ] 配置 Docker 客户端
- [ ] 执行测试推送/拉取
- [ ] 备份配置信息

---

## 📝 版本信息

- Harbor 版本: 2.12.3
- Docker: 20.10+
- Docker Compose: v2
- Ubuntu: 24.04 LTS

---

**开始部署吧！** 🚀

如有问题，请查阅 HARBOR_GUIDE.md 或 HARBOR_COMMANDS.sh 中的详细内容。
