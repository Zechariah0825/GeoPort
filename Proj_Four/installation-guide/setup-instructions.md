# GeoPort 快捷指令安装指南

## 概述
本指南将帮助您在iPhone上设置GeoPort快捷指令，实现无需电脑的独立定位修改功能。

## 系统要求
- iOS 13.0 或更高版本
- iPhone 或 iPad
- 网络连接

## 安装步骤

### 第一步：下载快捷指令文件

1. 在iPhone上打开Safari浏览器
2. 访问快捷指令下载页面
3. 依次下载以下快捷指令：
   - `GeoPortLocation.shortcut` - 主要定位设置功能
   - `GeoPortStop.shortcut` - 停止定位修改
   - `GeoPortQuickLocations.shortcut` - 快速城市定位

### 第二步：导入快捷指令

#### 方法一：直接导入（推荐）
1. 点击下载的`.shortcut`文件
2. 系统会自动打开"快捷指令"应用
3. 点击"添加快捷指令"
4. 重复此过程导入所有三个快捷指令

#### 方法二：手动创建
如果自动导入失败，可以手动创建：

**创建 GeoPortLocation 快捷指令：**
1. 打开"快捷指令"应用
2. 点击右上角"+"创建新快捷指令
3. 按以下步骤添加操作：

```
1. 添加"获取输入"操作
   - 输入类型：文本
   
2. 添加"分割文本"操作
   - 分隔符：自定义
   - 自定义分隔符：,（逗号）
   
3. 添加"从列表中获取项目"操作
   - 获取：第一个项目
   
4. 添加"设置变量"操作
   - 变量名：Latitude
   
5. 添加"从列表中获取项目"操作
   - 获取：索引为2的项目
   
6. 添加"设置变量"操作
   - 变量名：Longitude
   
7. 添加"获取网页内容"操作
   - URL：https://api.geoport.example.com/v1/set-location
   - 方法：POST
   - 请求体：JSON
   - JSON内容：
     {
       "latitude": [Latitude变量],
       "longitude": [Longitude变量],
       "device_id": "shortcuts_device",
       "source": "shortcuts"
     }
   - 标头：
     Content-Type: application/json
     Authorization: Bearer demo_token
     
8. 添加"从字典中获取值"操作
   - 获取：success的值
   
9. 添加"如果"操作
   - 条件：等于
   - 值：true
   
10. 在"如果"分支中添加"显示通知"操作
    - 标题：GeoPort - 成功
    - 正文：定位设置成功！
    
11. 在"否则"分支中添加"显示通知"操作
    - 标题：GeoPort - 失败
    - 正文：定位设置失败，请检查网络连接
```

4. 保存快捷指令，命名为"GeoPortLocation"

**创建 GeoPortStop 快捷指令：**
1. 创建新快捷指令
2. 添加以下操作：

```
1. 添加"获取网页内容"操作
   - URL：https://api.geoport.example.com/v1/stop-location
   - 方法：POST
   - 请求体：JSON
   - JSON内容：
     {
       "device_id": "shortcuts_device",
       "source": "shortcuts"
     }
   - 标头：
     Content-Type: application/json
     Authorization: Bearer demo_token
     
2. 添加"从字典中获取值"操作
   - 获取：success的值
   
3. 添加"如果"操作
   - 条件：等于
   - 值：true
   
4. 在"如果"分支中添加"显示通知"操作
   - 标题：GeoPort - 成功
   - 正文：已停止定位修改
   
5. 在"否则"分支中添加"显示通知"操作
   - 标题：GeoPort - 失败
   - 正文：停止失败，请检查网络连接
```

3. 保存为"GeoPortStop"

### 第三步：配置服务器地址

1. 在快捷指令中找到"获取网页内容"操作
2. 将URL中的`api.geoport.example.com`替换为实际的服务器地址
3. 如果需要，更新Authorization头中的token

### 第四步：测试快捷指令

1. 打开"GeoPortLocation"快捷指令
2. 输入测试坐标，例如：`39.9042,116.4074`
3. 运行快捷指令
4. 检查是否收到成功通知

## 使用方法

### 基本使用

**设置定位：**
1. 运行"GeoPortLocation"快捷指令
2. 输入坐标格式：`纬度,经度`
3. 例如：`39.9042,116.4074`（北京）

**停止定位：**
1. 运行"GeoPortStop"快捷指令
2. 等待确认通知

**快速定位：**
1. 运行"GeoPortQuickLocations"快捷指令
2. 从列表中选择城市
3. 自动设置到选中位置

### 高级使用

**Siri语音控制：**
1. 对Siri说："Hey Siri, GeoPortLocation"
2. 说出坐标："39.9042,116.4074"
3. Siri会自动执行定位设置

**小组件使用：**
1. 长按主屏幕空白处
2. 点击左上角"+"
3. 搜索"快捷指令"
4. 添加快捷指令小组件
5. 选择GeoPort相关快捷指令

**自动化触发：**
1. 打开"快捷指令"应用
2. 点击"自动化"标签
3. 创建个人自动化
4. 设置触发条件（如时间、位置等）
5. 选择运行GeoPort快捷指令

## Web控制面板

### 访问控制面板
1. 在Safari中打开：`http://your-server.com`
2. 使用Web界面进行可视化操作
3. 支持地图选择和快速定位

### 控制面板功能
- 📍 坐标输入设置
- 🗺️ 地图交互选择
- 🌏 快速城市定位
- 📱 获取当前位置
- 🛑 停止定位修改
- 📊 状态监控

## 故障排除

### 常见问题

**问题1：快捷指令无法运行**
- 检查网络连接
- 确认服务器地址正确
- 验证快捷指令配置

**问题2：定位设置失败**
- 检查坐标格式是否正确
- 确认服务器状态正常
- 查看错误通知信息

**问题3：Siri无法识别**
- 重新录制Siri短语
- 检查快捷指令名称
- 确保麦克风权限开启

**问题4：通知不显示**
- 检查通知权限设置
- 确认快捷指令通知已开启
- 重启快捷指令应用

### 调试步骤

1. **检查网络连接**
   ```bash
   # 在浏览器中访问
   https://api.geoport.example.com/api/health
   ```

2. **验证API响应**
   - 使用Postman或类似工具测试API
   - 检查返回的JSON格式

3. **查看快捷指令日志**
   - 在快捷指令中添加"显示结果"操作
   - 查看每步的输出结果

## 安全注意事项

### 隐私保护
- 所有数据传输使用HTTPS加密
- 不会存储个人敏感信息
- 可随时删除使用记录

### 使用限制
- 仅供技术研究和测试使用
- 遵守当地法律法规
- 不得用于欺诈或违法活动

### 权限管理
- 最小权限原则
- 定期更新访问token
- 监控异常使用行为

## 更新维护

### 快捷指令更新
1. 下载新版本快捷指令文件
2. 删除旧版本快捷指令
3. 导入新版本快捷指令
4. 重新配置服务器地址

### 服务器维护
- 定期检查服务器状态
- 更新API端点地址
- 备份重要配置数据

## 技术支持

### 联系方式
- 📧 邮箱：support@geoport.example.com
- 🌐 官网：https://geoport.example.com
- 💬 社区：https://github.com/geoport/shortcuts

### 常用资源
- [快捷指令官方文档](https://support.apple.com/guide/shortcuts/)
- [API接口文档](https://api.geoport.example.com/docs)
- [视频教程](https://youtube.com/geoport-tutorials)

## 许可证
本项目采用MIT许可证，详见LICENSE文件。

---

**免责声明：**
本工具仅供技术研究和测试使用。用户需遵守当地法律法规，开发者不承担因使用本工具而产生的任何法律责任。