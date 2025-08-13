# GeoPort 快捷指令 - Vercel 一键部署版本

## 🚀 一键部署到 Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fyour-username%2Fgeoport-shortcuts&project-name=geoport-shortcuts&repository-name=geoport-shortcuts)

## 📋 部署前准备

### 1. 准备 GitHub 仓库
```bash
# 克隆项目
git clone https://github.com/your-username/geoport-shortcuts.git
cd geoport-shortcuts

# 或者 fork 原项目到你的 GitHub 账号
```

### 2. 环境要求
- GitHub 账号
- Vercel 账号（可用 GitHub 登录）
- Node.js 18+ （本地开发用）

## 🔧 部署步骤

### 方法一：一键部署（推荐）

1. **点击部署按钮**
   - 点击上方的 "Deploy with Vercel" 按钮
   - 使用 GitHub 账号登录 Vercel

2. **配置项目**
   - 项目名称：`geoport-shortcuts`
   - 仓库名称：`geoport-shortcuts`
   - 确认部署设置

3. **等待部署完成**
   - Vercel 会自动构建和部署
   - 部署完成后会提供访问链接

### 方法二：手动部署

1. **安装 Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **登录 Vercel**
   ```bash
   vercel login
   ```

3. **部署项目**
   ```bash
   # 在项目根目录执行
   vercel
   
   # 生产环境部署
   vercel --prod
   ```

## 📁 项目结构（Vercel 优化版）

```
Proj_Four/
├── api/                        # Vercel API 路由
│   └── index.js               # 主 API 处理器
├── web-interface/             # 静态前端文件
│   └── index.html            # Web 控制面板
├── shortcuts/                 # 快捷指令文件
│   ├── GeoPortLocation.shortcut
│   ├── GeoPortStop.shortcut
│   └── GeoPortQuickLocations.shortcut
├── vercel.json               # Vercel 配置文件
├── package.json              # 项目依赖
├── .vercelignore            # 部署忽略文件
└── README-VERCEL.md         # 部署说明
```

## ⚙️ 配置说明

### Vercel 配置 (`vercel.json`)
```json
{
  "version": 2,
  "builds": [
    {
      "src": "api/index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/index.js"
    },
    {
      "src": "/(.*)",
      "dest": "/web-interface/$1"
    }
  ]
}
```

### API 端点
部署后的 API 端点：
- **设置定位**: `POST /api/v1/set-location`
- **停止定位**: `POST /api/v1/stop-location`
- **获取状态**: `GET /api/v1/status`
- **健康检查**: `GET /api/health`

## 🔗 更新快捷指令配置

部署完成后，需要更新快捷指令中的 API 地址：

### 1. 获取部署地址
部署完成后，Vercel 会提供类似这样的地址：
```
https://geoport-shortcuts-abc123.vercel.app
```

### 2. 更新快捷指令
在快捷指令的"获取网页内容"操作中，将 URL 更新为：
```
https://your-vercel-app.vercel.app/api/v1/set-location
https://your-vercel-app.vercel.app/api/v1/stop-location
```

### 3. 更新认证 Token
在快捷指令的 Authorization 头中：
```
Authorization: Bearer demo_token
```

## 🌐 访问应用

### Web 控制面板
```
https://your-vercel-app.vercel.app
```

### API 文档
```
https://your-vercel-app.vercel.app/api/health
```

## 🔧 本地开发

### 1. 安装依赖
```bash
npm install
```

### 2. 启动开发服务器
```bash
npm run dev
# 或
vercel dev
```

### 3. 访问本地应用
```
http://localhost:3000
```

## 📱 快捷指令配置

### 自动配置
1. 访问部署后的网站
2. 按照页面提示下载快捷指令文件
3. 在 iPhone 上导入快捷指令

### 手动配置
参考 `installation-guide/setup-instructions.md` 中的详细步骤，将 API 地址替换为你的 Vercel 部署地址。

## 🔍 故障排除

### 常见问题

**1. 部署失败**
- 检查 `package.json` 中的依赖版本
- 确认 Node.js 版本兼容性
- 查看 Vercel 部署日志

**2. API 请求失败**
- 检查 CORS 配置
- 验证 API 端点地址
- 查看浏览器控制台错误

**3. 快捷指令无法连接**
- 确认 API 地址正确
- 检查认证 token
- 验证网络连接

### 调试方法

**查看部署日志**
```bash
vercel logs your-deployment-url
```

**本地测试 API**
```bash
curl -X POST https://your-vercel-app.vercel.app/api/v1/set-location \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer demo_token" \
  -d '{"latitude":39.9042,"longitude":116.4074,"device_id":"test"}'
```

## 🔒 安全配置

### 环境变量
在 Vercel 项目设置中添加环境变量：

```bash
# API 认证密钥
AUTH_SECRET=your-secret-key

# 允许的域名
ALLOWED_ORIGINS=https://your-domain.com

# 数据库连接（如需要）
DATABASE_URL=your-database-url
```

### 访问控制
```javascript
// 在 api/index.js 中配置
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['*'];

app.use(cors({
  origin: allowedOrigins,
  credentials: true
}));
```

## 📊 监控和分析

### Vercel Analytics
在 Vercel 项目设置中启用：
- **Analytics**: 访问统计
- **Speed Insights**: 性能监控
- **Web Vitals**: 用户体验指标

### 自定义监控
```javascript
// 在 API 中添加日志
console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
```

## 🚀 性能优化

### 1. 静态文件优化
- 启用 Vercel 的自动压缩
- 使用 CDN 加速静态资源

### 2. API 优化
- 实施请求缓存
- 优化数据库查询
- 使用连接池

### 3. 监控指标
- 响应时间
- 错误率
- 并发用户数

## 🔄 持续部署

### 自动部署
Vercel 会自动监听 GitHub 仓库变化：
- **主分支推送** → 生产环境部署
- **其他分支推送** → 预览环境部署

### 手动部署
```bash
# 部署到生产环境
vercel --prod

# 部署预览版本
vercel
```

## 📞 技术支持

### 官方资源
- [Vercel 文档](https://vercel.com/docs)
- [Node.js API 参考](https://vercel.com/docs/functions/serverless-functions/runtimes/node-js)
- [部署配置指南](https://vercel.com/docs/project-configuration)

### 社区支持
- [Vercel 社区](https://github.com/vercel/vercel/discussions)
- [项目 Issues](https://github.com/your-username/geoport-shortcuts/issues)

## 📄 许可证
本项目采用 MIT 许可证，详见 LICENSE 文件。

---

**🎉 恭喜！你已经成功部署了 GeoPort 快捷指令到 Vercel！**

现在你可以：
1. 访问 Web 控制面板
2. 配置 iOS 快捷指令
3. 开始使用定位修改功能

如有问题，请查看故障排除部分或提交 Issue。