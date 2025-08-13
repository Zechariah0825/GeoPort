# iOS越狱定位修改应用方案

## 概述
将GeoPort转换为越狱iOS设备上的独立应用

## 技术栈
- Objective-C/Swift
- Theos开发框架
- LocationSimulation私有API
- Cydia Substrate/Substitute

## 实现步骤
1. 使用Theos创建越狱应用框架
2. 调用私有LocationSimulation API
3. 创建用户界面
4. 打包为.deb文件通过Cydia分发

## 限制
- 仅适用于越狱设备
- 需要root权限
- 不能通过App Store分发