import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var locationSpoofer = LocationSpoofer.shared
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "提示"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingLocationHistory = false
    @State private var isLocationSpoofing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题区域
                    headerView
                    
                    // 状态指示器
                    statusIndicator
                    
                    // 地图视图
                    mapView
                    
                    // 坐标输入区域
                    coordinateInputView
                    
                    // 操作按钮
                    actionButtonsView
                    
                    // 快速定位
                    quickLocationsView
                    
                    // 历史记录按钮
                    historyButtonView
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingLocationHistory) {
                LocationHistoryView()
            }
        }
    }
    
    // MARK: - 视图组件
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                Text("GeoPort")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text("专业定位修改工具")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 10)
    }
    
    private var statusIndicator: some View {
        HStack {
            Circle()
                .fill(isLocationSpoofing ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
            
            Text(isLocationSpoofing ? "定位修改中" : "未修改定位")
                .font(.caption)
                .foregroundColor(isLocationSpoofing ? .green : .secondary)
            
            Spacer()
            
            if let spoofedLocation = locationSpoofer.getCurrentSpoofedLocation() {
                Text("当前: \(String(format: "%.4f", spoofedLocation.latitude)), \(String(format: "%.4f", spoofedLocation.longitude))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var mapView: some View {
        MapView(region: $region, selectedLocation: $selectedLocation) { coordinate in
            latitude = String(format: "%.6f", coordinate.latitude)
            longitude = String(format: "%.6f", coordinate.longitude)
            selectedLocation = coordinate
        }
        .frame(height: 250)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var coordinateInputView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "location.north.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                TextField("纬度 (例如: 39.9042)", text: $latitude)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: latitude) { _ in
                        updateMapFromInput()
                    }
            }
            
            HStack {
                Image(systemName: "location.east.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                TextField("经度 (例如: 116.4074)", text: $longitude)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: longitude) { _ in
                        updateMapFromInput()
                    }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            Button(action: setLocation) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("设置定位")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(latitude.isEmpty || longitude.isEmpty)
            
            HStack(spacing: 12) {
                Button(action: getCurrentLocation) {
                    HStack {
                        Image(systemName: "location.magnifyingglass")
                        Text("获取位置")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: stopLocationSpoof) {
                    HStack {
                        Image(systemName: "stop.circle")
                        Text("停止修改")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var quickLocationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速定位")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickLocationButton(name: "北京", lat: 39.9042, lng: 116.4074, icon: "🏛️") {
                        setQuickLocation(lat: 39.9042, lng: 116.4074)
                    }
                    QuickLocationButton(name: "上海", lat: 31.2304, lng: 121.4737, icon: "🏙️") {
                        setQuickLocation(lat: 31.2304, lng: 121.4737)
                    }
                    QuickLocationButton(name: "深圳", lat: 22.5431, lng: 114.0579, icon: "🌆") {
                        setQuickLocation(lat: 22.5431, lng: 114.0579)
                    }
                    QuickLocationButton(name: "香港", lat: 22.3193, lng: 114.1694, icon: "🌃") {
                        setQuickLocation(lat: 22.3193, lng: 114.1694)
                    }
                    QuickLocationButton(name: "纽约", lat: 40.7128, lng: -74.0060, icon: "🗽") {
                        setQuickLocation(lat: 40.7128, lng: -74.0060)
                    }
                    QuickLocationButton(name: "伦敦", lat: 51.5074, lng: -0.1278, icon: "🎡") {
                        setQuickLocation(lat: 51.5074, lng: -0.1278)
                    }
                    QuickLocationButton(name: "东京", lat: 35.6762, lng: 139.6503, icon: "🗼") {
                        setQuickLocation(lat: 35.6762, lng: 139.6503)
                    }
                    QuickLocationButton(name: "巴黎", lat: 48.8566, lng: 2.3522, icon: "🗼") {
                        setQuickLocation(lat: 48.8566, lng: 2.3522)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var historyButtonView: some View {
        Button(action: {
            showingLocationHistory = true
        }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text("历史记录")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
    }
    
    // MARK: - 功能方法
    
    private func setLocation() {
        guard let lat = Double(latitude), let lng = Double(longitude) else {
            showAlert(title: "输入错误", message: "请输入有效的经纬度")
            return
        }
        
        guard CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: lng)) else {
            showAlert(title: "坐标无效", message: "请输入有效的地理坐标")
            return
        }
        
        locationSpoofer.setLocation(latitude: lat, longitude: lng) { success, error in
            DispatchQueue.main.async {
                if success {
                    isLocationSpoofing = true
                    updateMap(lat: lat, lng: lng)
                    showAlert(title: "设置成功", message: "定位已设置为: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lng))")
                    
                    // 保存到历史记录
                    LocationHistoryManager.shared.addLocation(
                        latitude: lat,
                        longitude: lng,
                        name: getLocationName(lat: lat, lng: lng)
                    )
                } else {
                    showAlert(title: "设置失败", message: error ?? "未知错误")
                }
            }
        }
    }
    
    private func getCurrentLocation() {
        locationManager.requestLocation { location, error in
            DispatchQueue.main.async {
                if let location = location {
                    latitude = String(format: "%.6f", location.coordinate.latitude)
                    longitude = String(format: "%.6f", location.coordinate.longitude)
                    updateMap(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                    showAlert(title: "获取成功", message: "已获取当前位置")
                } else {
                    showAlert(title: "获取失败", message: error?.localizedDescription ?? "无法获取位置信息")
                }
            }
        }
    }
    
    private func stopLocationSpoof() {
        locationSpoofer.stopLocationSpoof { success, error in
            DispatchQueue.main.async {
                if success {
                    isLocationSpoofing = false
                    showAlert(title: "停止成功", message: "已停止定位修改")
                } else {
                    showAlert(title: "停止失败", message: error ?? "未知错误")
                }
            }
        }
    }
    
    private func setQuickLocation(lat: Double, lng: Double) {
        latitude = String(format: "%.6f", lat)
        longitude = String(format: "%.6f", lng)
        updateMap(lat: lat, lng: lng)
        setLocation()
    }
    
    private func updateMap(lat: Double, lng: Double) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            selectedLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
    
    private func updateMapFromInput() {
        guard let lat = Double(latitude), let lng = Double(longitude),
              CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: lng)) else {
            return
        }
        
        updateMap(lat: lat, lng: lng)
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    private func getLocationName(lat: Double, lng: Double) -> String {
        // 简单的位置名称识别
        let quickLocations = [
            (39.9042, 116.4074, "北京"),
            (31.2304, 121.4737, "上海"),
            (22.5431, 114.0579, "深圳"),
            (22.3193, 114.1694, "香港"),
            (40.7128, -74.0060, "纽约"),
            (51.5074, -0.1278, "伦敦"),
            (35.6762, 139.6503, "东京"),
            (48.8566, 2.3522, "巴黎")
        ]
        
        for (qLat, qLng, name) in quickLocations {
            if abs(lat - qLat) < 0.01 && abs(lng - qLng) < 0.01 {
                return name
            }
        }
        
        return "自定义位置"
    }
}

struct QuickLocationButton: View {
    let name: String
    let lat: Double
    let lng: Double
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(icon)
                    .font(.title2)
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}