# GeoPort 快捷指令集成方案

## 项目概述
这是GeoPort的快捷指令集成版本，通过iOS快捷指令应用实现无需电脑的独立定位修改功能。用户可以通过Siri语音、快捷指令小组件或Web控制面板来控制定位修改。

## 功能特性

### 核心功能
- ✅ 快捷指令定位设置
- ✅ Siri语音控制
- ✅ 快速城市定位选择
- ✅ 停止定位修改
- ✅ Web可视化控制面板
- ✅ 自动化触发支持

### 高级功能
- ✅ 小组件快速访问
- ✅ 历史记录管理
- ✅ 状态实时监控
- ✅ 批量位置导入
- ✅ 自定义API集成

## 项目结构

```
Proj_Four/
├── shortcuts/                      # 快捷指令文件
│   ├── GeoPortLocation.shortcut    # 主要定位设置
│   ├── GeoPortStop.shortcut        # 停止定位修改
│   └── GeoPortQuickLocations.shortcut # 快速城市选择
├── web-interface/                   # Web控制面板
│   └── index.html                  # 主界面
├── server/                         # 后端服务器
│   ├── app.js                      # Express服务器
│   └── package.json                # 依赖配置
├── installation-guide/             # 安装指南
│   └── setup-instructions.md       # 详细安装说明
└── README.md                       # 项目说明
```

## 快速开始

### 1. 服务器部署

```bash
# 进入服务器目录
cd Proj_Four/server

# 安装依赖
npm install

# 启动服务器
npm start

# 开发模式（自动重启）
npm run dev
```

### 2. 快捷指令安装

#### 自动安装（推荐）
1. 在iPhone上打开Safari
2. 访问项目页面下载快捷指令文件
3. 点击`.shortcut`文件自动导入

#### 手动安装
1. 打开"快捷指令"应用
2. 按照`installation-guide/setup-instructions.md`中的详细步骤创建
3. 配置API端点和认证信息

### 3. Web控制面板
1. 在浏览器中访问：`http://localhost:3000`
2. 使用可视化界面进行定位控制
3. 支持添加到主屏幕作为Web应用

## 使用方法

### 快捷指令使用

**基本定位设置：**
```
1. 运行"GeoPortLocation"快捷指令
2. 输入坐标：39.9042,116.4074
3. 等待成功通知
```

**Siri语音控制：**
```
"Hey Siri, GeoPortLocation"
"39.9042,116.4074"
```

**快速城市定位：**
```
1. 运行"GeoPortQuickLocations"
2. 从列表中选择城市
3. 自动设置定位
```

**停止定位修改：**
```
运行"GeoPortStop"快捷指令
```

### Web控制面板使用

**坐标输入：**
- 在输入框中填入纬度和经度
- 点击"设置定位"按钮

**地图选择：**
- 点击地图上的任意位置
- 自动填入对应坐标

**快速定位：**
- 点击预设城市按钮
- 一键设置到对应位置

**获取当前位置：**
- 点击"获取当前位置"按钮
- 自动填入真实坐标

## API接口文档

### 基础信息
- **Base URL**: `https://api.geoport.example.com/v1`
- **认证方式**: Bearer Token
- **数据格式**: JSON

### 接口列表

#### 1. 设置定位
```http
POST /api/v1/set-location
Content-Type: application/json
Authorization: Bearer {token}

{
  "latitude": 39.9042,
  "longitude": 116.4074,
  "device_id": "shortcuts_device",
  "source": "shortcuts"
}
```

**响应：**
```json
{
  "success": true,
  "message": "定位设置成功",
  "data": {
    "latitude": 39.9042,
    "longitude": 116.4074,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### 2. 停止定位修改
```http
POST /api/v1/stop-location
Content-Type: application/json
Authorization: Bearer {token}

{
  "device_id": "shortcuts_device",
  "source": "shortcuts"
}
```

#### 3. 获取当前状态
```http
GET /api/v1/status
Authorization: Bearer {token}
X-Device-ID: shortcuts_device
```

#### 4. 获取历史记录
```http
GET /api/v1/history?limit=50
Authorization: Bearer {token}
X-Device-ID: shortcuts_device
```

#### 5. 健康检查
```http
GET /api/health
```

## 配置选项

### 服务器配置
在`server/app.js`中修改：

```javascript
// 端口配置
const PORT = process.env.PORT || 3000;

// CORS配置
app.use(cors({
  origin: ['https://your-domain.com'],
  credentials: true
}));

// 速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100 // 最多100个请求
});
```

### 快捷指令配置
部署到 Vercel 后，在快捷指令中修改：

```
URL: https://your-vercel-app.vercel.app/api/v1/set-location
Authorization: Bearer demo_token
```

### Web界面配置
Web界面会自动检测当前域名，无需手动配置。如需自定义：

```javascript
// 在 web-interface/index.html 中
const API_BASE_URL = window.location.origin + '/api/v1';
const AUTH_TOKEN = 'demo_token';
```

## 部署指南

### 🚀 一键部署到 Vercel（推荐）

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fyour-username%2Fgeoport-shortcuts&project-name=geoport-shortcuts&repository-name=geoport-shortcuts)

**优势：**
- 零配置部署
- 自动 HTTPS
- 全球 CDN 加速
- 自动扩容
- 免费额度充足

**部署步骤：**
1. 点击上方部署按钮
2. 使用 GitHub 登录 Vercel
3. 等待自动部署完成
4. 获取部署地址并更新快捷指令配置

详细说明请查看：[README-VERCEL.md](./README-VERCEL.md)

### 本地开发
```bash
# 克隆项目
git clone https://github.com/geoport/shortcuts.git
cd Proj_Four

# 安装依赖
npm install

# 启动开发服务器
npm run dev
# 或使用 Vercel CLI
vercel dev
```

### 其他部署方式

#### 传统服务器部署
```bash
# 使用原始 Express 服务器
cd server
npm install
npm start
```

#### 使用Docker
```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY api/ ./api/
COPY web-interface/ ./web-interface/

EXPOSE 3000
CMD ["node", "api/index.js"]
```

#### 使用PM2
```bash
# 安装PM2
npm install -g pm2

# 启动应用
pm2 start api/index.js --name geoport-shortcuts

# 设置开机自启
pm2 startup
pm2 save
```

## 安全考虑

### 认证机制
- 使用Bearer Token认证
- 支持设备ID绑定
- 实施请求频率限制

### 数据保护
- 所有API请求使用HTTPS
- 敏感数据加密存储
- 定期清理过期会话

### 访问控制
```javascript
// IP白名单
const allowedIPs = ['192.168.1.0/24'];

// 设备认证
const validateDevice = (req, res, next) => {
  const deviceId = req.headers['x-device-id'];
  const token = req.headers.authorization;
  
  // 验证逻辑
  if (isValidDevice(deviceId, token)) {
    next();
  } else {
    res.status(401).json({ error: '未授权访问' });
  }
};
```

## 监控和日志

### 日志配置
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### 性能监控
```javascript
// 响应时间监控
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} - ${duration}ms`);
  });
  next();
});
```

### 健康检查
```javascript
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    activeSessions: activeSessions.size
  });
});
```

## 故障排除

### 常见问题

**1. 快捷指令无法运行**
- 检查网络连接状态
- 验证API服务器地址
- 确认认证token有效

**2. API请求失败**
- 查看服务器日志
- 检查请求格式和参数
- 验证CORS配置

**3. Web界面无法访问**
- 确认服务器正在运行
- 检查防火墙设置
- 验证端口配置

### 调试工具

**服务器调试：**
```bash
# 查看日志
tail -f combined.log

# 检查进程
ps aux | grep node

# 测试API
curl -X POST https://api.geoport.example.com/v1/set-location \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer demo_token" \
  -d '{"latitude":39.9042,"longitude":116.4074,"device_id":"test"}'
```

**快捷指令调试：**
- 在快捷指令中添加"显示结果"操作
- 查看每步的输出内容
- 使用"显示通知"显示变量值

## 扩展功能

### 自定义位置库
```javascript
// 添加自定义位置
const customLocations = [
  { name: '公司', lat: 39.9042, lng: 116.4074 },
  { name: '家', lat: 31.2304, lng: 121.4737 },
  { name: '学校', lat: 22.5431, lng: 114.0579 }
];
```

### 批量操作
```javascript
// 批量设置定位
app.post('/api/v1/batch-locations', (req, res) => {
  const { locations } = req.body;
  // 处理批量位置设置
});
```

### 定时任务
```javascript
const cron = require('node-cron');

// 每小时清理过期会话
cron.schedule('0 * * * *', () => {
  cleanExpiredSessions();
});
```

## 更新日志

### v1.0.0 (2024-01-15)
- ✅ 初始版本发布
- ✅ 基础快捷指令功能
- ✅ Web控制面板
- ✅ API服务器
- ✅ 安装指南文档

### 计划功能
- 🔄 地图可视化选择
- 🔄 路线模拟功能
- 🔄 多设备同步
- 🔄 云端配置管理

## 贡献指南

### 开发环境
```bash
# 克隆仓库
git clone https://github.com/geoport/shortcuts.git

# 安装依赖
cd Proj_Four/server
npm install

# 启动开发服务器
npm run dev
```

### 提交规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建过程或辅助工具的变动
```

### Pull Request流程
1. Fork项目
2. 创建功能分支
3. 提交代码更改
4. 编写测试用例
5. 发起Pull Request

## 许可证
本项目采用MIT许可证，详见LICENSE文件。

## 免责声明
本工具仅供技术研究和测试使用。用户需遵守当地法律法规，开发者不承担因使用本工具而产生的任何法律责任。