const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const app = express();

// 中间件配置
app.use(cors({
  origin: true,
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 速率限制
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 100, // 限制每个IP 15分钟内最多100个请求
    message: {
        error: '请求过于频繁，请稍后再试'
    }
});

app.use('/api/', limiter);

// 存储活跃的定位会话（使用内存存储，适合Vercel serverless）
const activeSessions = new Map();

// 设备验证中间件
const validateDevice = (req, res, next) => {
    const deviceId = req.body.device_id || req.headers['x-device-id'];
    const authToken = req.headers.authorization;
    
    if (!deviceId) {
        return res.status(400).json({
            success: false,
            error: '缺少设备标识符'
        });
    }
    
    // 简单的token验证
    if (!authToken || !authToken.startsWith('Bearer ')) {
        return res.status(401).json({
            success: false,
            error: '缺少或无效的认证token'
        });
    }
    
    req.deviceId = deviceId;
    req.authToken = authToken.replace('Bearer ', '');
    next();
};

// API路由

// 设置定位
app.post('/api/v1/set-location', validateDevice, (req, res) => {
    try {
        const { latitude, longitude, source } = req.body;
        const { deviceId } = req;
        
        // 验证坐标
        if (typeof latitude !== 'number' || typeof longitude !== 'number') {
            return res.status(400).json({
                success: false,
                error: '无效的坐标格式'
            });
        }
        
        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            return res.status(400).json({
                success: false,
                error: '坐标超出有效范围'
            });
        }
        
        // 创建定位会话
        const session = {
            deviceId,
            latitude,
            longitude,
            source: source || 'api',
            timestamp: new Date(),
            active: true
        };
        
        activeSessions.set(deviceId, session);
        
        console.log(`[${new Date().toISOString()}] 设置定位 - 设备: ${deviceId}, 坐标: ${latitude}, ${longitude}, 来源: ${source}`);
        
        res.json({
            success: true,
            message: '定位设置成功',
            data: {
                latitude,
                longitude,
                timestamp: session.timestamp
            }
        });
        
    } catch (error) {
        console.error('设置定位错误:', error);
        res.status(500).json({
            success: false,
            error: '服务器内部错误'
        });
    }
});

// 停止定位修改
app.post('/api/v1/stop-location', validateDevice, (req, res) => {
    try {
        const { deviceId } = req;
        
        if (activeSessions.has(deviceId)) {
            const session = activeSessions.get(deviceId);
            session.active = false;
            session.stoppedAt = new Date();
            
            console.log(`[${new Date().toISOString()}] 停止定位 - 设备: ${deviceId}`);
            
            activeSessions.delete(deviceId);
            
            res.json({
                success: true,
                message: '已停止定位修改'
            });
        } else {
            res.json({
                success: true,
                message: '没有活跃的定位会话'
            });
        }
        
    } catch (error) {
        console.error('停止定位错误:', error);
        res.status(500).json({
            success: false,
            error: '服务器内部错误'
        });
    }
});

// 获取当前状态
app.get('/api/v1/status', validateDevice, (req, res) => {
    try {
        const { deviceId } = req;
        const session = activeSessions.get(deviceId);
        
        if (session && session.active) {
            res.json({
                success: true,
                active: true,
                data: {
                    latitude: session.latitude,
                    longitude: session.longitude,
                    timestamp: session.timestamp,
                    source: session.source
                }
            });
        } else {
            res.json({
                success: true,
                active: false,
                message: '当前没有活跃的定位修改'
            });
        }
        
    } catch (error) {
        console.error('获取状态错误:', error);
        res.status(500).json({
            success: false,
            error: '服务器内部错误'
        });
    }
});

// 获取历史记录
app.get('/api/v1/history', validateDevice, (req, res) => {
    try {
        const { deviceId } = req;
        const limit = parseInt(req.query.limit) || 50;
        
        // 模拟历史记录数据
        const history = [
            {
                latitude: 39.9042,
                longitude: 116.4074,
                name: '北京',
                timestamp: new Date(Date.now() - 3600000),
                source: 'shortcuts'
            },
            {
                latitude: 31.2304,
                longitude: 121.4737,
                name: '上海',
                timestamp: new Date(Date.now() - 7200000),
                source: 'api'
            }
        ];
        
        res.json({
            success: true,
            data: history.slice(0, limit)
        });
        
    } catch (error) {
        console.error('获取历史记录错误:', error);
        res.status(500).json({
            success: false,
            error: '服务器内部错误'
        });
    }
});

// 健康检查
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date(),
        platform: 'vercel',
        activeSessions: activeSessions.size
    });
});

// 获取服务器统计信息
app.get('/api/stats', (req, res) => {
    const stats = {
        activeSessions: activeSessions.size,
        platform: 'vercel',
        timestamp: new Date(),
        memory: process.memoryUsage()
    };
    
    res.json(stats);
});

// 错误处理中间件
app.use((error, req, res, next) => {
    console.error('服务器错误:', error);
    
    res.status(error.status || 500).json({
        success: false,
        error: process.env.NODE_ENV === 'production' ? '服务器内部错误' : error.message
    });
});

// 404处理
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: '接口不存在'
    });
});

module.exports = app;