# 🚀 一键部署到 Vercel

点击下方按钮即可将 GeoPort 快捷指令项目一键部署到 Vercel：

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fyour-username%2Fgeoport-shortcuts&project-name=geoport-shortcuts&repository-name=geoport-shortcuts&demo-title=GeoPort%20Shortcuts&demo-description=iOS%20Shortcuts%20for%20Location%20Spoofing&demo-url=https%3A%2F%2Fgeoport-shortcuts.vercel.app&demo-image=https%3A%2F%2Fraw.githubusercontent.com%2Fyour-username%2Fgeoport-shortcuts%2Fmain%2Fscreenshot.png)

## 部署后配置

### 1. 获取部署地址
部署完成后，记录你的 Vercel 应用地址，例如：
```
https://geoport-shortcuts-abc123.vercel.app
```

### 2. 更新快捷指令
下载并导入快捷指令文件，然后：

1. 打开"GeoPortLocation"快捷指令
2. 找到"获取网页内容"操作
3. 将 URL 更新为：`https://your-app.vercel.app/api/v1/set-location`
4. 对"GeoPortStop"快捷指令执行相同操作

### 3. 测试功能
1. 访问你的 Vercel 应用地址
2. 使用 Web 控制面板测试功能
3. 在 iPhone 上运行快捷指令测试

## 自定义域名（可选）

在 Vercel 项目设置中可以添加自定义域名：
1. 进入项目设置
2. 点击"Domains"
3. 添加你的域名
4. 配置 DNS 记录

## 环境变量配置

在 Vercel 项目设置中可以添加环境变量：
- `AUTH_SECRET`: API 认证密钥
- `ALLOWED_ORIGINS`: 允许的域名列表
- `NODE_ENV`: 设置为 `production`

---

**需要帮助？** 查看 [README-VERCEL.md](./README-VERCEL.md) 获取详细部署指南。