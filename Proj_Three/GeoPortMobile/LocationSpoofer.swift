import Foundation
import CoreLocation
import Network
import UIKit

// 定位修改核心类
class LocationSpoofer: ObservableObject {
    static let shared = LocationSpoofer()
    
    @Published var isLocationSpoofing = false
    @Published var currentSpoofedLocation: CLLocationCoordinate2D?
    
    private var networkMonitor: NWPathMonitor
    private var monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isNetworkAvailable = false
    
    private override init() {
        networkMonitor = NWPathMonitor()
        super.init()
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - 网络监控
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    // MARK: - 公共接口
    
    func setLocation(latitude: Double, longitude: Double, completion: @escaping (Bool, String?) -> Void) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 验证坐标有效性
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            completion(false, "无效的坐标")
            return
        }
        
        // 检查设备类型和权限
        if isJailbroken() {
            setLocationViaPrivateAPI(coordinate: coordinate, completion: completion)
        } else if isNetworkAvailable {
            setLocationViaNetworkService(coordinate: coordinate, completion: completion)
        } else {
            setLocationViaSimulation(coordinate: coordinate, completion: completion)
        }
    }
    
    func stopLocationSpoof(completion: @escaping (Bool, String?) -> Void) {
        if isJailbroken() {
            stopLocationViaPrivateAPI(completion: completion)
        } else if isNetworkAvailable {
            stopLocationViaNetworkService(completion: completion)
        } else {
            stopLocationViaSimulation(completion: completion)
        }
        
        DispatchQueue.main.async {
            self.isLocationSpoofing = false
            self.currentSpoofedLocation = nil
        }
    }
    
    func getCurrentSpoofedLocation() -> CLLocationCoordinate2D? {
        return currentSpoofedLocation
    }
    
    func isCurrentlySpoofing() -> Bool {
        return isLocationSpoofing
    }
    
    // MARK: - 设备检测
    
    private func isJailbroken() -> Bool {
        // 检查常见的越狱文件和路径
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // 检查是否可以写入系统目录
        let testPath = "/private/test_jailbreak.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // 无法写入，可能未越狱
        }
        
        // 检查是否可以调用system函数
        let result = system("echo test")
        if result == 0 {
            return true
        }
        
        return false
    }
    
    // MARK: - 私有API方法 (越狱设备)
    
    private func setLocationViaPrivateAPI(coordinate: CLLocationCoordinate2D, completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 模拟私有API调用
            // 在实际实现中，这里会调用越狱环境下的私有API
            
            /*
            实际的私有API调用示例 (需要在越狱环境下):
            
            // 获取LocationSimulation服务
            Class locationSimulationClass = NSClassFromString(@"DTLocationSimulation");
            if (locationSimulationClass) {
                id locationSimulation = [[locationSimulationClass alloc] init];
                
                // 设置模拟位置
                SEL setLocationSelector = NSSelectorFromString(@"setLocation:");
                if ([locationSimulation respondsToSelector:setLocationSelector]) {
                    CLLocation *fakeLocation = [[CLLocation alloc] 
                        initWithLatitude:coordinate.latitude 
                        longitude:coordinate.longitude];
                    
                    [locationSimulation performSelector:setLocationSelector withObject:fakeLocation];
                }
            }
            */
            
            // 模拟API调用延迟
            Thread.sleep(forTimeInterval: 1.0)
            
            DispatchQueue.main.async {
                self.isLocationSpoofing = true
                self.currentSpoofedLocation = coordinate
                completion(true, nil)
            }
        }
    }
    
    private func stopLocationViaPrivateAPI(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 模拟停止私有API调用
            Thread.sleep(forTimeInterval: 0.5)
            
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - 网络服务方法
    
    private func setLocationViaNetworkService(coordinate: CLLocationCoordinate2D, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://api.geoport.example.com/v1/set-location") else {
            completion(false, "无效的服务器地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getDeviceToken())", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10.0
        
        let requestBody: [String: Any] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "device_id": getDeviceIdentifier(),
            "timestamp": Date().timeIntervalSince1970,
            "app_version": getAppVersion()
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(false, "请求数据编码失败")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "网络请求失败: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "无效的服务器响应")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    self?.isLocationSpoofing = true
                    self?.currentSpoofedLocation = coordinate
                    completion(true, nil)
                case 401:
                    completion(false, "认证失败，请检查设备授权")
                case 429:
                    completion(false, "请求过于频繁，请稍后再试")
                case 500...599:
                    completion(false, "服务器错误，请稍后再试")
                default:
                    completion(false, "未知错误 (状态码: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func stopLocationViaNetworkService(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://api.geoport.example.com/v1/stop-location") else {
            completion(false, "无效的服务器地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getDeviceToken())", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10.0
        
        let requestBody: [String: Any] = [
            "device_id": getDeviceIdentifier(),
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(false, "请求数据编码失败")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "网络请求失败: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    completion(false, "服务器响应错误")
                    return
                }
                
                completion(true, nil)
            }
        }.resume()
    }
    
    // MARK: - 本地模拟方法
    
    private func setLocationViaSimulation(coordinate: CLLocationCoordinate2D, completion: @escaping (Bool, String?) -> Void) {
        // 本地模拟实现，用于演示和测试
        DispatchQueue.global(qos: .userInitiated).async {
            // 模拟处理时间
            Thread.sleep(forTimeInterval: 0.8)
            
            DispatchQueue.main.async {
                self.isLocationSpoofing = true
                self.currentSpoofedLocation = coordinate
                
                // 发送本地通知
                self.sendLocationChangeNotification(coordinate: coordinate)
                
                completion(true, nil)
            }
        }
    }
    
    private func stopLocationViaSimulation(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 0.3)
            
            DispatchQueue.main.async {
                // 发送停止通知
                self.sendLocationStopNotification()
                
                completion(true, nil)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func getDeviceIdentifier() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
    
    private func getDeviceToken() -> String {
        // 在实际应用中，这里应该返回从服务器获取的认证token
        return "demo_token_\(getDeviceIdentifier())"
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func sendLocationChangeNotification(coordinate: CLLocationCoordinate2D) {
        NotificationCenter.default.post(
            name: .locationDidChange,
            object: nil,
            userInfo: [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        )
    }
    
    private func sendLocationStopNotification() {
        NotificationCenter.default.post(
            name: .locationDidStop,
            object: nil
        )
    }
}

// MARK: - 通知扩展

extension Notification.Name {
    static let locationDidChange = Notification.Name("locationDidChange")
    static let locationDidStop = Notification.Name("locationDidStop")
}