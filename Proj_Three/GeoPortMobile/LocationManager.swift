import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocation?, Error?) -> Void)?
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation(completion: @escaping (CLLocation?, Error?) -> Void) {
        locationCompletion = completion
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(nil, LocationError.permissionDenied)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            completion(nil, LocationError.unknown)
        }
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        locationCompletion?(location, nil)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        locationCompletion?(nil, error)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationCompletion != nil {
                locationManager.requestLocation()
            }
        case .denied, .restricted:
            locationCompletion?(nil, LocationError.permissionDenied)
            locationCompletion = nil
        default:
            break
        }
    }
}

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case locationUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "定位权限被拒绝，请在设置中开启定位权限"
        case .locationUnavailable:
            return "无法获取位置信息"
        case .unknown:
            return "未知定位错误"
        }
    }
}