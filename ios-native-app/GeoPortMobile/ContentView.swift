import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                VStack {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("GeoPort Mobile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("随时随地修改定位")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // 地图视图
                Map(coordinateRegion: $region, annotationItems: [LocationPin(coordinate: region.center)]) { pin in
                    MapPin(coordinate: pin.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(15)
                .onTapGesture { location in
                    // 地图点击事件处理
                }
                
                // 输入框
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "location.north")
                            .foregroundColor(.blue)
                        TextField("纬度 (例如: 39.9042)", text: $latitude)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Image(systemName: "location.east")
                            .foregroundColor(.blue)
                        TextField("经度 (例如: 116.4074)", text: $longitude)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal)
                
                // 按钮组
                VStack(spacing: 12) {
                    Button(action: setLocation) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("设置定位")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: getCurrentLocation) {
                        HStack {
                            Image(systemName: "location.magnifyingglass")
                            Text("获取当前位置")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: stopLocationSpoof) {
                        HStack {
                            Image(systemName: "stop.circle")
                            Text("停止定位修改")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // 快速定位
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuickLocationButton(name: "北京", lat: 39.9042, lng: 116.4074, icon: "🏛️") {
                            setQuickLocation(lat: 39.9042, lng: 116.4074)
                        }
                        QuickLocationButton(name: "上海", lat: 31.2304, lng: 121.4737, icon: "🏙️") {
                            setQuickLocation(lat: 31.2304, lng: 121.4737)
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
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func setLocation() {
        guard let lat = Double(latitude), let lng = Double(longitude) else {
            showAlert("请输入有效的经纬度")
            return
        }
        
        // 调用定位修改服务
        LocationSpoofer.shared.setLocation(latitude: lat, longitude: lng) { success, error in
            DispatchQueue.main.async {
                if success {
                    updateMap(lat: lat, lng: lng)
                    showAlert("定位已设置为: \(lat), \(lng)")
                } else {
                    showAlert("设置定位失败: \(error ?? "未知错误")")
                }
            }
        }
    }
    
    private func getCurrentLocation() {
        locationManager.requestLocation { location, error in
            if let location = location {
                latitude = String(location.coordinate.latitude)
                longitude = String(location.coordinate.longitude)
                updateMap(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                showAlert("已获取当前位置")
            } else {
                showAlert("无法获取位置信息: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
    
    private func stopLocationSpoof() {
        LocationSpoofer.shared.stopLocationSpoof { success, error in
            DispatchQueue.main.async {
                if success {
                    showAlert("已停止定位修改")
                } else {
                    showAlert("停止失败: \(error ?? "未知错误")")
                }
            }
        }
    }
    
    private func setQuickLocation(lat: Double, lng: Double) {
        latitude = String(lat)
        longitude = String(lng)
        setLocation()
    }
    
    private func updateMap(lat: Double, lng: Double) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
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
            VStack {
                Text(icon)
                    .font(.title2)
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    ContentView()
}