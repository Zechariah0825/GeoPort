import Foundation
import CoreLocation
import UIKit

// iOS快捷指令集成方案
// 通过URL Scheme和快捷指令实现定位修改

class LocationSpooferShortcuts {
    
    // 生成快捷指令URL
    static func generateShortcutURL(latitude: Double, longitude: Double) -> URL? {
        let baseURL = "shortcuts://run-shortcut"
        let shortcutName = "LocationSpoofer"
        let params = "?name=\(shortcutName)&input=\(latitude),\(longitude)"
        
        return URL(string: baseURL + params)
    }
    
    // 处理定位数据
    static func processLocationData(_ input: String) -> (lat: Double, lng: Double)? {
        let components = input.components(separatedBy: ",")
        guard components.count == 2,
              let lat = Double(components[0]),
              let lng = Double(components[1]) else {
            return nil
        }
        return (lat: lat, lng: lng)
    }
}

// 快捷指令配置说明
/*
1. 打开快捷指令应用
2. 创建新快捷指令，命名为"LocationSpoofer"
3. 添加"获取输入"操作
4. 添加"分割文本"操作，使用逗号分隔
5. 添加自定义操作调用定位修改服务
6. 保存快捷指令

使用方法：
- 通过Siri语音："Hey Siri, LocationSpoofer 39.9042,116.4074"
- 通过快捷指令应用直接运行
- 通过第三方应用URL调用
*/