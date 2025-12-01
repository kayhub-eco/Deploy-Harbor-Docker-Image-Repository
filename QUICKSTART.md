# Harbor 部署 - 快速参考卡（速查表）

## 🎯 60秒快速部署

```bash
# 1. 连接服务器
ssh root@your-server-ip

# 2. 下载脚本
curl -O https://your-location/harbor_quick_deploy.sh
chmod +x harbor_quick_deploy.sh

# 3. 部署
sudo bash harbor_quick_deploy.sh http

# 4. 访问
# 打开浏览器: http://your-server-ip
# 用户名: admin
# 密码: Harbor12345
```

---

## 📁 文件清单

| 文件 | 用途 | 何时使用 |
|-----|------|--------|
| **harbor_deploy.sh** | 完整部署 | 生产环境、HTTPS |
| **harbor_quick_deploy.sh** | 快速部署 | 快速测试 |
| **configure_docker_client.sh** | 客户端配置 | 配置其他机器连接 Harbor |
| **HARBOR_GUIDE.md** | 完整指南 | 学习详细配置 |
| **HARBOR_COMMANDS.sh** | 命令参考 | 查询常用命令 |
| **README.md** | 本文档 | 概览和快速开始 |

---

## ⚡ 三种部署方式

### 方式 1️⃣：快速部署（推荐新手）

```bash
sudo bash harbor_quick_deploy.sh http
# ⏱️ 耗时：5-10 分钟
# 📝 特点：最简单，适合测试
```

### 方式 2️⃣：完整部署（推荐生产）

```bash
sudo bash harbor_deploy.sh https your-domain.com YourPassword
# ⏱️ 耗时：10-15 分钟
# 📝 特点：完整功能，支持 HTTPS
```

### 方式 3️⃣：手动部署（需要学习）

```bash
# 参考 HARBOR_GUIDE.md 中的「手动部署」部分
# ⏱️ 耗时：20-30 分钟
# 📝 特点：完全可控，学习曲线较陡
```

---

## 🔧 配置总览

### 部署脚本参数

**harbor_deploy.sh**
```bash
sudo bash harbor_deploy.sh [protocol] [hostname] [password]
# protocol: http 或 https
# hostname: 域名或 IP
# password: 管理员密码
```

**harbor_quick_deploy.sh**
```bash
sudo bash harbor_quick_deploy.sh [protocol] [hostname] [password]
# 参数同上，更简洁
```

**configure_docker_client.sh**
```bash
sudo bash configure_docker_client.sh [ip] [port] [protocol]
# ip: Harbor 服务器 IP
# port: Harbor 端口（通常 80 或 443）
# protocol: http 或 https
```

---

## 📍 关键目录位置

```
/opt/harbor/                   # Harbor 安装目录
├── docker-compose.yml        # Docker Compose 配置
├── harbor.yml                # Harbor 主配置文件
├── install.sh                # 安装脚本
├── prepare                   # 配置准备脚本
└── certs/                    # SSL 证书目录

/data/harbor/                 # Harbor 数据目录
├── registry/                 # 镜像存储
├── database/                 # 数据库数据
└── logs/                     # 日志文件
```

---

## 🚨 部署前检查清单

```
☐ 系统为 Ubuntu 24.04
☐ 至少 2GB 空闲内存
☐ 至少 40GB 空闲磁盘
☐ 网络连接正常
☐ 防火墙允许 80 端口（或 443 for HTTPS）
☐ 有 root 权限
☐ 脚本文件具有执行权限 (chmod +x)
```

---

## ✅ 部署后验证

```bash
# 1. 检查容器
cd /opt/harbor && docker compose ps

# 2. 访问 Web UI
curl -I http://your-harbor-ip

# 3. 测试登录
docker login your-harbor-ip

# 4. 测试推送
docker push your-harbor-ip/library/nginx:latest
```

---

## 🛠️ 常见问题速解

| 问题 | 解决方案 |
|-----|--------|
| 脚本权限不足 | `chmod +x script.sh` |
| Docker 未安装 | 脚本自动安装，或 `apt install docker.io` |
| 端口被占用 | `sudo lsof -i :80` 找到进程后 kill |
| 无法访问 Web UI | `sudo ufw allow 80/tcp` 然后重启防火墙 |
| 容器启动失败 | `docker compose logs` 查看详细错误 |
| 磁盘满 | `docker compose exec registry bin/registry garbage-collect` |
| 忘记密码 | 在 Web UI 中重置或参考完整指南 |

---

## 🔐 安全建议（首次部署必读）

```
1️⃣ 修改默认密码
   登录后立即修改 admin 密码

2️⃣ 启用 HTTPS
   生产环境强烈推荐使用 HTTPS

3️⃣ 配置防火墙
   只允许必要的端口

4️⃣ 定期备份
   至少每周备份一次数据

5️⃣ 启用扫描
   开启 Clair/Trivy 漏洞扫描
```

---

## 📊 常用命令速查

### 基础操作
```bash
cd /opt/harbor

# 启动
docker compose up -d

# 停止
docker compose down

# 重启
docker compose restart

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f harbor-core
```

### Docker 镜像操作
```bash
# 登录
docker login your-harbor-ip

# 推送
docker tag nginx:latest your-harbor-ip/library/nginx:latest
docker push your-harbor-ip/library/nginx:latest

# 拉取
docker pull your-harbor-ip/library/nginx:latest

# 登出
docker logout your-harbor-ip
```

### 备份恢复
```bash
# 完整备份
tar -czf harbor_backup.tar.gz /data/harbor /opt/harbor

# 数据库备份
docker compose exec -T harbor-db pg_dump -U postgres harbor_db > backup.sql

# 恢复数据库
cat backup.sql | docker compose exec -T harbor-db psql -U postgres harbor_db
```

### API 查询
```bash
# 系统信息
curl -u admin:password http://your-harbor-ip/api/v2.0/systeminfo

# 项目列表
curl -u admin:password http://your-harbor-ip/api/v2.0/projects

# 镜像列表
curl -u admin:password http://your-harbor-ip/api/v2.0/repositories
```

---

## 🎓 学习路径

初学者建议按以下顺序学习：

1. **快速开始** (本文档) ← 你在这里
2. **快速部署** → `bash harbor_quick_deploy.sh http`
3. **完整指南** → 阅读 HARBOR_GUIDE.md
4. **命令参考** → 查看 HARBOR_COMMANDS.sh
5. **实战操作** → 创建项目、推送镜像、配置客户端

---

## 📞 获取帮助

### 检查日志
```bash
# Harbor 日志
tail -f /data/harbor/logs/harbor.log

# 容器日志
docker compose logs harbor-core
docker compose logs registry
docker compose logs harbor-db

# 系统日志
sudo journalctl -u docker -n 50
```

### 常见错误代码

| 错误 | 含义 | 解决方案 |
|-----|------|--------|
| 401 Unauthorized | 认证失败 | 检查用户名密码 |
| 404 Not Found | 镜像不存在 | 检查镜像名称和项目 |
| 429 Rate Limited | 请求过于频繁 | 稍等后重试 |
| 500 Server Error | 服务器错误 | 检查日志，重启服务 |
| 503 Unavailable | 服务不可用 | 检查磁盘空间和内存 |

### 联系资源

- 官网：https://goharbor.io
- GitHub：https://github.com/goharbor/harbor
- 问题追踪：https://github.com/goharbor/harbor/issues
- 讨论区：https://github.com/goharbor/harbor/discussions

---

## 📈 性能优化建议

### 推荐配置（小型环境）
```yaml
CPU: 2-4 核
内存: 4-8 GB
磁盘: 40-100 GB
```

### 推荐配置（中型环境）
```yaml
CPU: 4-8 核
内存: 8-16 GB
磁盘: 100-500 GB
```

### 推荐配置（大型环境）
```yaml
CPU: 8+ 核
内存: 16+ GB
磁盘: 500+ GB
网络: 专线推荐
```

---

## 🔄 升级指南

```bash
# 1. 备份
tar -czf harbor_backup.tar.gz /data/harbor /opt/harbor

# 2. 停止
cd /opt/harbor && docker compose down

# 3. 下载新版本
cd /opt
wget https://github.com/goharbor/harbor/releases/download/v2.13.0/harbor-online-installer-v2.13.0.tgz
tar -xzf harbor-online-installer-v2.13.0.tgz -C /opt/

# 4. 复制配置
cp /opt/harbor/harbor.yml.bak /opt/harbor/harbor.yml

# 5. 重新部署
cd /opt/harbor && ./install.sh --with-trivy --with-clair

# 6. 验证
docker compose ps
```

---

## 💡 最佳实践

✅ **务必做**
- 定期备份重要数据
- 使用强密码
- 启用 HTTPS
- 定期更新
- 监控磁盘空间
- 启用日志

❌ **不要做**
- 使用默认密码
- HTTP 用于生产环境
- 忽视日志错误
- 频繁修改核心配置
- 磁盘满还继续推送镜像
- 没有备份就删除数据

---

## 📝 记录您的部署信息

```
部署日期: ________________
Harbor IP: ________________
管理员密码: ________________
SSH 用户: ________________
数据位置: /data/harbor
配置位置: /opt/harbor
备份位置: ________________
备份频率: 每周 / 每月
```

---

**现在就开始部署吧！** 🚀

有问题？查阅对应的详细文档或执行命令参考。
