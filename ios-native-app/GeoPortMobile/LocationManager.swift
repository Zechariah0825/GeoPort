import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocation?, Error?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation(completion: @escaping (CLLocation?, Error?) -> Void) {
        locationCompletion = completion
        
        switch locationManager.authorizationStatus {
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
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationCompletion?(location, nil)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(nil, error)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
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
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "定位权限被拒绝"
        case .unknown:
            return "未知错误"
        }
    }
}