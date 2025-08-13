# GeoPort Mobile - 原生iOS应用

## 项目概述
这是GeoPort的原生iOS应用版本，使用SwiftUI开发，提供完整的定位修改功能。

## 功能特性

### 核心功能
- ✅ 实时定位修改
- ✅ 地图交互选择位置
- ✅ 手动输入经纬度
- ✅ 快速定位到热门城市
- ✅ 获取当前真实位置
- ✅ 停止定位修改
- ✅ 历史记录管理

### 高级功能
- ✅ 越狱设备支持 (私有API)
- ✅ 网络服务集成
- ✅ 本地模拟模式
- ✅ 网络状态监控
- ✅ 设备类型检测

## 技术架构

### 开发环境
- Xcode 15.0+
- iOS 15.0+
- Swift 5.0+
- SwiftUI

### 核心组件
```
GeoPortMobile/
├── GeoPortMobileApp.swift      # 应用入口
├── ContentView.swift           # 主界面
├── LocationManager.swift       # 位置管理器
├── LocationSpoofer.swift       # 定位修改核心
├── MapView.swift              # 地图视图
├── LocationHistoryView.swift   # 历史记录
└── Info.plist                 # 应用配置
```

### 架构设计
- **MVVM模式**: 使用SwiftUI + ObservableObject
- **单例模式**: LocationSpoofer和LocationHistoryManager
- **委托模式**: CLLocationManagerDelegate
- **观察者模式**: NotificationCenter和@Published

## 安装部署

### 开发环境配置
1. 克隆项目到本地
2. 使用Xcode打开 `GeoPortMobile.xcodeproj`
3. 配置开发者账号和Bundle ID
4. 选择目标设备或模拟器
5. 点击运行按钮

### 企业分发
1. 申请企业开发者账号
2. 创建企业证书和描述文件
3. 配置项目签名
4. 构建IPA文件
5. 通过企业分发平台发布

### 证书配置
```bash
# 1. 生成证书请求文件
# 在钥匙串访问中生成CSR文件

# 2. 在Apple Developer创建证书
# 选择iOS Distribution (In-House)

# 3. 创建App ID
# Bundle ID: com.geoport.mobile

# 4. 创建描述文件
# 选择In-House分发类型
```

## 使用说明

### 基本操作
1. **设置定位**
   - 在地图上点击选择位置
   - 或手动输入经纬度
   - 点击"设置定位"按钮

2. **快速定位**
   - 点击预设城市按钮
   - 自动设置到对应位置

3. **获取当前位置**
   - 点击"获取位置"按钮
   - 自动填入当前真实坐标

4. **停止修改**
   - 点击"停止修改"按钮
   - 恢复正常定位服务

5. **历史记录**
   - 查看之前使用过的位置
   - 快速重用历史位置
   - 删除或清空记录

### 权限设置
应用需要以下权限：
- **位置权限**: 获取当前位置
- **网络权限**: 连接定位服务

## 技术实现

### 定位修改策略
应用采用三层定位修改策略：

1. **私有API (越狱设备)**
   ```swift
   // 检测越狱环境
   private func isJailbroken() -> Bool {
       // 检查越狱文件和路径
       // 尝试系统调用
       // 检查写入权限
   }
   
   // 调用私有API
   private func setLocationViaPrivateAPI() {
       // 使用LocationSimulation私有API
       // 直接修改系统定位服务
   }
   ```

2. **网络服务 (普通设备)**
   ```swift
   // 通过服务器API修改定位
   private func setLocationViaNetworkService() {
       // 发送HTTP请求到定位服务器
       // 服务器端处理定位修改
   }
   ```

3. **本地模拟 (离线模式)**
   ```swift
   // 本地模拟实现
   private func setLocationViaSimulation() {
       // 发送本地通知
       // 更新应用内状态
   }
   ```

### 网络监控
```swift
private func startNetworkMonitoring() {
    networkMonitor.pathUpdateHandler = { path in
        self.isNetworkAvailable = path.status == .satisfied
    }
}
```

### 历史记录管理
```swift
class LocationHistoryManager: ObservableObject {
    func addLocation(latitude: Double, longitude: Double, name: String) {
        // 添加到历史记录
        // 限制记录数量
        // 持久化存储
    }
}
```

## 配置选项

### 应用配置
在 `Info.plist` 中配置：
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>GeoPort需要访问您的位置信息以提供定位服务</string>
```

### 服务器配置
在 `LocationSpoofer.swift` 中修改：
```swift
private let serverURL = "https://api.geoport.example.com"
```

### 快速定位配置
在 `ContentView.swift` 中添加城市：
```swift
QuickLocationButton(name: "城市名", lat: 纬度, lng: 经度, icon: "图标")
```

## 安全考虑

### 数据保护
- 所有网络请求使用HTTPS
- 设备标识符加密存储
- 历史记录本地加密

### 权限控制
- 最小权限原则
- 用户明确授权
- 透明的隐私政策

### 反检测机制
- 随机化请求间隔
- 模拟真实用户行为
- 动态API端点

## 故障排除

### 常见问题

1. **定位修改失败**
   - 检查网络连接
   - 验证服务器状态
   - 确认设备权限

2. **地图不显示**
   - 检查网络连接
   - 验证地图服务可用性
   - 重启应用

3. **历史记录丢失**
   - 检查存储权限
   - 验证数据完整性
   - 重新安装应用

### 调试模式
在开发环境中启用详细日志：
```swift
#if DEBUG
print("Debug: \(message)")
#endif
```

## 法律声明

### 使用条款
- 仅供技术研究和测试使用
- 用户需遵守当地法律法规
- 不得用于欺诈或违法活动

### 免责声明
- 开发者不承担使用风险
- 用户自行承担法律责任
- 应用可能随时停止服务

## 更新日志

### v1.0.0 (2024-01-15)
- ✅ 初始版本发布
- ✅ 基础定位修改功能
- ✅ 地图交互界面
- ✅ 历史记录管理
- ✅ 多种定位修改策略

## 技术支持

### 联系方式
- 邮箱: support@geoport.example.com
- 官网: https://geoport.example.com
- GitHub: https://github.com/geoport/mobile

### 贡献指南
1. Fork项目
2. 创建功能分支
3. 提交代码更改
4. 发起Pull Request

## 许可证
本项目采用MIT许可证，详见LICENSE文件。