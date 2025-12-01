# Harbor Docker 镜像仓库 - 完整部署包

## 📦 您已获得的完整部署包包含

```
✅ harbor_deploy.sh              - 完整版自动部署脚本
✅ harbor_quick_deploy.sh        - 快速部署脚本
✅ configure_docker_client.sh    - Docker 客户端配置脚本
✅ HARBOR_GUIDE.md              - 详细使用指南（50+ 页）
✅ HARBOR_COMMANDS.sh           - 常用命令参考手册
✅ QUICKSTART.md                - 快速参考卡
✅ README.md                    - 部署包说明
✅ DEPLOYMENT_SUMMARY.md        - 本文件
```

---

## 🚀 三步快速开始

### Step 1️⃣：登录服务器

```bash
ssh root@your-ubuntu-24.04-server
```

### Step 2️⃣：一键部署（选择一种）

**选项 A：快速部署（推荐新手）**
```bash
bash harbor_quick_deploy.sh http
```

**选项 B：完整部署（推荐生产）**
```bash
bash harbor_deploy.sh https your-domain.com YourPassword123
```

### Step 3️⃣：访问 Harbor

部署完成后在浏览器打开：
```
http://your-server-ip（或 https://your-domain.com）
用户名: admin
密码: Harbor12345（或您设置的密码）
```

---

## 📚 文档导航

### 对于新手
1. 📖 先读这个：`QUICKSTART.md` - 快速参考卡
2. 🚀 然后执行：`bash harbor_quick_deploy.sh http`
3. 🎓 学习详情：`HARBOR_GUIDE.md` 前三章

### 对于进阶用户
1. 📖 阅读：`README.md` - 完整部署说明
2. 🔧 使用：`harbor_deploy.sh` - HTTPS 和高级配置
3. 📚 参考：`HARBOR_COMMANDS.sh` - 所有命令
4. 📘 深入：`HARBOR_GUIDE.md` - 全部内容

### 对于运维
1. 🔧 配置：修改脚本参数以符合企业需求
2. 🛡️ 安全：使用 HTTPS + Let's Encrypt 证书
3. 💾 备份：配置定时备份脚本
4. 📊 监控：设置告警和日志收集

---

## 🎯 各脚本用途一览

### harbor_deploy.sh（完整版）
**何时使用：** 生产环境、需要 HTTPS、企业部署
**执行时间：** 10-15 分钟
**特点：**
- 自动检查和安装 Docker
- 支持 HTTPS 和自签名证书
- 自动生成强密码
- 详细的彩色日志
- 自动配置备份

**命令：**
```bash
sudo bash harbor_deploy.sh http
sudo bash harbor_deploy.sh https registry.example.com AdminPass123
sudo bash harbor_deploy.sh https $(hostname -I | awk '{print $1}') Harbor12345
```

---

### harbor_quick_deploy.sh（快速版）
**何时使用：** 快速测试、学习环境、PoC（概念验证）
**执行时间：** 5-10 分钟
**特点：**
- 最小化依赖
- 快速部署
- 自动配置
- 清晰的输出

**命令：**
```bash
sudo bash harbor_quick_deploy.sh
sudo bash harbor_quick_deploy.sh http 192.168.1.100
```

---

### configure_docker_client.sh（客户端配置）
**何时使用：** 配置其他机器连接到您的 Harbor
**执行位置：** 在 Docker 客户端机器上执行（不是 Harbor 服务器）
**用途：** 让 Docker 客户端能推送/拉取镜像到 Harbor

**命令：**
```bash
# 在客户机上执行
sudo bash configure_docker_client.sh 192.168.1.100 80 http
```

---

## ⚙️ 常见配置场景

### 场景 1：快速测试环境

```bash
# 只需一条命令
sudo bash harbor_quick_deploy.sh http
```

### 场景 2：生产 HTTPS 环境（自签名证书）

```bash
sudo bash harbor_deploy.sh https registry.example.com MyStrongPassword
```

### 场景 3：生产 HTTPS 环境（Let's Encrypt）

```bash
# 先获取证书
sudo apt install certbot
sudo certbot certonly --standalone -d registry.example.com

# 然后部署
sudo bash harbor_deploy.sh https registry.example.com MyStrongPassword
# 脚本会自动检测并使用 Let's Encrypt 证书
```

### 场景 4：内网环境（使用 IP 地址）

```bash
HARBOR_IP=$(hostname -I | awk '{print $1}')
sudo bash harbor_deploy.sh http $HARBOR_IP Harbor12345
```

---

## 📋 部署前检查清单

### 系统要求
- [ ] 操作系统：Ubuntu 24.04 LTS
- [ ] CPU：2+ 核心
- [ ] 内存：4GB+（推荐 8GB）
- [ ] 磁盘：40GB+（可用空间）
- [ ] 网络：稳定连接

### 环境准备
- [ ] 已获得 root 权限
- [ ] 脚本有执行权限：`chmod +x *.sh`
- [ ] 端口 80/443 可用（检查防火墙）
- [ ] 备有 SSH 密钥或密码（防止被锁定）

### 信息准备
- [ ] 服务器 IP 地址
- [ ] 要使用的域名（可选）
- [ ] 管理员密码（建议生成强密码）

---

## ✅ 部署后检查

### 验证部署成功

```bash
# 1. 查看容器状态
cd /opt/harbor && docker compose ps

# 2. 测试 Web 访问
curl -I http://your-harbor-ip

# 3. 查看日志
tail -f /data/harbor/logs/harbor.log
```

### 首次登录后

```bash
# 1. 修改管理员密码
# 登录 Harbor Web UI → 右上角用户菜单 → 修改密码

# 2. 创建项目
# Harbor Web UI → 项目 → 新建项目

# 3. 配置 Docker 客户端
sudo bash configure_docker_client.sh your-harbor-ip 80 http

# 4. 测试镜像推送
docker login your-harbor-ip
docker tag nginx:latest your-harbor-ip/library/nginx:latest
docker push your-harbor-ip/library/nginx:latest
```

---

## 🛠️ 常见问题快速解决

| 问题 | 解决方案 |
|-----|--------|
| `Permission denied` | 用 `sudo` 执行：`sudo bash harbor_deploy.sh` |
| `Docker not found` | 脚本会自动安装，或手动：`apt install docker.io` |
| `Port 80 already in use` | 找到占用端口的进程并关闭，或修改配置 |
| `Cannot connect to Harbor` | 检查防火墙：`ufw allow 80/tcp` |
| `Forgot admin password` | 查阅 `HARBOR_GUIDE.md` 的重置密码部分 |
| `Docker push failed` | 运行：`docker logout` 然后 `docker login` |
| `Out of disk space` | 执行：`docker compose exec registry bin/registry garbage-collect` |

---

## 🔐 安全建议

### ⚠️ 必须做

1. **修改默认密码**
   ```
   登录 Harbor → 用户管理 → 修改 admin 密码
   ```

2. **启用 HTTPS**（生产环境）
   ```bash
   sudo bash harbor_deploy.sh https your-domain.com
   ```

3. **防火墙配置**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   sudo ufw enable
   ```

4. **定期备份**
   ```bash
   tar -czf harbor_backup_$(date +%Y%m%d).tar.gz /data/harbor /opt/harbor
   ```

5. **启用漏洞扫描**
   - Harbor Web UI → 系统管理 → 配置管理
   - 启用 Clair 和 Trivy

---

## 📊 部署后的常用操作

### 启停 Harbor

```bash
cd /opt/harbor

# 启动
docker compose up -d

# 停止
docker compose down

# 重启
docker compose restart
```

### 推送镜像

```bash
# 1. 登录
docker login your-harbor-ip

# 2. 打标签
docker tag my-image:latest your-harbor-ip/library/my-image:latest

# 3. 推送
docker push your-harbor-ip/library/my-image:latest
```

### 拉取镜像

```bash
# 方式 1：直接从 Harbor
docker pull your-harbor-ip/library/nginx:latest

# 方式 2：配置镜像源后
docker pull nginx:latest
# 会自动从 Harbor 查找，没有则从 Docker Hub 拉取
```

### 查看日志

```bash
# Harbor 日志
tail -f /data/harbor/logs/harbor.log

# 容器日志
docker compose logs -f harbor-core
docker compose logs -f registry
docker compose logs -f harbor-db
```

---

## 📈 文档对应用途

| 需求 | 参考文档 | 说明 |
|-----|--------|------|
| 快速开始 | `QUICKSTART.md` | 5分钟快速参考 |
| 部署说明 | `README.md` | 详细部署流程 |
| 配置管理 | `HARBOR_GUIDE.md` | 所有配置选项 |
| 命令参考 | `HARBOR_COMMANDS.sh` | 常用命令 |
| 故障排查 | `HARBOR_GUIDE.md` 常见问题章节 | 问题解决 |
| API 使用 | `HARBOR_COMMANDS.sh` API部分 | API 调用示例 |
| 备份恢复 | `HARBOR_GUIDE.md` 维护章节 | 备份和恢复 |

---

## 🎓 学习建议

### Day 1：快速部署和基础使用
- [ ] 阅读 `QUICKSTART.md`
- [ ] 执行 `bash harbor_quick_deploy.sh http`
- [ ] 登录 Harbor Web UI
- [ ] 创建一个项目

### Day 2：镜像操作
- [ ] 阅读 `HARBOR_GUIDE.md` 的使用示例部分
- [ ] 推送一个镜像到 Harbor
- [ ] 从 Harbor 拉取镜像
- [ ] 配置另一台机器的 Docker 客户端

### Day 3：高级配置
- [ ] 阅读 `HARBOR_GUIDE.md` 的配置部分
- [ ] 尝试 HTTPS 部署
- [ ] 设置镜像源/仓库
- [ ] 启用漏洞扫描

### Week 2：维护和运维
- [ ] 学习备份和恢复
- [ ] 设置定时备份
- [ ] 理解日志和监控
- [ ] 制定灾难恢复计划

---

## 📞 获取帮助

### 文档内查找

使用 grep 快速查找：
```bash
# 查找关键字
grep -r "keyword" .

# 查找错误信息
grep -r "error message" .
```

### 查看脚本帮助

```bash
# 查看脚本头部注释
head -20 harbor_deploy.sh

# 查看脚本日志
docker compose logs
```

### 外部资源

- 官方文档：https://goharbor.io/docs/
- GitHub：https://github.com/goharbor/harbor
- 问题提交：https://github.com/goharbor/harbor/issues
- 讨论社区：https://github.com/goharbor/harbor/discussions

---

## 💾 保存您的部署信息

请妥善保存以下信息（建议保存在安全位置）：

```
====================================
Harbor 部署信息
====================================
部署日期: _____________________
服务器 IP: _____________________
域名: _____________________
管理员用户名: admin
管理员密码: _____________________
SSH 用户: _____________________
SSH 密钥位置: _____________________
Harbor 安装路径: /opt/harbor
Harbor 数据路径: /data/harbor
备份位置: _____________________
====================================
```

---

## 🎉 现在开始吧！

### 一键快速开始

```bash
# 复制粘贴即可部署
ssh root@your-server-ip
bash harbor_quick_deploy.sh http
```

### 或完整部署

```bash
ssh root@your-server-ip
bash harbor_deploy.sh https your-domain.com YourPassword
```

---

## ✨ 部署包特点总结

✅ **完全自动化** - 无需手动配置  
✅ **包含脚本** - 部署、客户端配置、命令参考  
✅ **详细文档** - 50+ 页使用指南  
✅ **多种方案** - 快速、完整、手动三种选择  
✅ **生产级** - 支持 HTTPS、SSL 证书、备份  
✅ **新手友好** - 清晰的操作步骤和常见问题解答  
✅ **企业支持** - 完整的维护、监控、恢复流程  

---

## 📝 版本信息

```
Harbor 版本: 2.12.3
Docker: 20.10+
Docker Compose: v2
Ubuntu: 24.04 LTS
脚本更新日期: 2025-12-01
```

---

## 🙏 感谢使用

希望这套部署包对您有帮助！

有任何问题或建议，欢迎查阅文档或参考官方资源。

**祝您部署顺利！** 🚀

---

**目录提示：**
- 快速上手 → QUICKSTART.md
- 部署说明 → README.md  
- 详细指南 → HARBOR_GUIDE.md
- 命令参考 → HARBOR_COMMANDS.sh
