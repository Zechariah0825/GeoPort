import SwiftUI
import CoreLocation

struct LocationHistoryView: View {
    @StateObject private var historyManager = LocationHistoryManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var locationToDelete: LocationHistoryItem?
    
    var body: some View {
        NavigationView {
            List {
                if historyManager.locations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("暂无历史记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("使用定位功能后，历史记录将显示在这里")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(historyManager.locations) { location in
                        LocationHistoryRow(location: location) {
                            // 使用历史位置
                            LocationSpoofer.shared.setLocation(
                                latitude: location.latitude,
                                longitude: location.longitude
                            ) { success, error in
                                if success {
                                    dismiss()
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("删除", role: .destructive) {
                                locationToDelete = location
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                if !historyManager.locations.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("清空") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                if let locationToDelete = locationToDelete {
                    Button("删除", role: .destructive) {
                        historyManager.removeLocation(locationToDelete)
                        self.locationToDelete = nil
                    }
                    Button("取消", role: .cancel) {
                        self.locationToDelete = nil
                    }
                } else {
                    Button("清空", role: .destructive) {
                        historyManager.clearAllLocations()
                    }
                    Button("取消", role: .cancel) { }
                }
            } message: {
                if locationToDelete != nil {
                    Text("确定要删除这个位置记录吗？")
                } else {
                    Text("确定要清空所有历史记录吗？此操作不可撤销。")
                }
            }
        }
    }
}

struct LocationHistoryRow: View {
    let location: LocationHistoryItem
    let onUse: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatDate(location.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("使用") {
                onUse()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 历史记录管理器

class LocationHistoryManager: ObservableObject {
    static let shared = LocationHistoryManager()
    
    @Published var locations: [LocationHistoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let locationsKey = "LocationHistory"
    private let maxHistoryCount = 50
    
    private init() {
        loadLocations()
    }
    
    func addLocation(latitude: Double, longitude: Double, name: String) {
        let newLocation = LocationHistoryItem(
            latitude: latitude,
            longitude: longitude,
            name: name,
            timestamp: Date()
        )
        
        // 检查是否已存在相同位置
        if let existingIndex = locations.firstIndex(where: { 
            abs($0.latitude - latitude) < 0.0001 && abs($0.longitude - longitude) < 0.0001 
        }) {
            // 更新时间戳
            locations[existingIndex] = newLocation
        } else {
            // 添加新位置
            locations.insert(newLocation, at: 0)
        }
        
        // 限制历史记录数量
        if locations.count > maxHistoryCount {
            locations = Array(locations.prefix(maxHistoryCount))
        }
        
        saveLocations()
    }
    
    func removeLocation(_ location: LocationHistoryItem) {
        locations.removeAll { $0.id == location.id }
        saveLocations()
    }
    
    func clearAllLocations() {
        locations.removeAll()
        saveLocations()
    }
    
    private func loadLocations() {
        if let data = userDefaults.data(forKey: locationsKey),
           let decodedLocations = try? JSONDecoder().decode([LocationHistoryItem].self, from: data) {
            locations = decodedLocations
        }
    }
    
    private func saveLocations() {
        if let encodedData = try? JSONEncoder().encode(locations) {
            userDefaults.set(encodedData, forKey: locationsKey)
        }
    }
}

// MARK: - 历史记录数据模型

struct LocationHistoryItem: Identifiable, Codable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let name: String
    let timestamp: Date
}

#Preview {
    LocationHistoryView()
}