//
//  ProfileView.swift
//  BeMe
//
//  Created by Assistant on 12/9/25.
//

import SwiftUI

struct ProfileView: View {
    // Persisted counters
    @AppStorage("totalPhotosCount") private var totalPhotosCount: Int = 0
    @AppStorage("photosToday") private var photosToday: Int = 0
    @AppStorage("lastPhotoDate") private var lastPhotoDate: String = ""
    
    // Session passed in
    let sessionCount: Int
    
    @State private var weekCount: Int = 0
    @State private var last7Days: [(label: String, count: Int)] = []
    
    private let byDateDefaultsKey = "photoCountsByDate"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header summary
                    HStack(spacing: 12) {
                        StatsCard(title: "Hoy", value: photosToday, color: .green)
                        StatsCard(title: "Semana", value: weekCount, color: .blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        StatsCard(title: "Total", value: totalPhotosCount, color: .orange)
                        StatsCard(title: "Sesión", value: sessionCount, color: .purple)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Actividad últimos 7 días")
                            .font(.headline)
                        
                        SevenDayBarChart(data: last7Days)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear(perform: refresh)
    }
    
    private func refresh() {
        // Ensure daily rollover visual consistency
        let todayKey = dateKey(for: Date())
        if lastPhotoDate != todayKey {
            // Only visual; the actual rollover is handled in CameraManager on first save of the day
        }
        let dict = loadCountsByDate()
        weekCount = computeWeekCount(from: dict)
        last7Days = buildLast7Days(from: dict)
    }
    
    private func loadCountsByDate() -> [String:Int] {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: byDateDefaultsKey),
           let dict = try? JSONDecoder().decode([String:Int].self, from: data) {
            return dict
        }
        return [:]
    }
    
    private func dateKey(for date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
    
    private func computeWeekCount(from dict: [String:Int]) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        var sum = 0
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: today) {
                let key = dateKey(for: day)
                sum += dict[key, default: 0]
            }
        }
        return sum
    }
    
    private func buildLast7Days(from dict: [String:Int]) -> [(label: String, count: Int)] {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        var result: [(String, Int)] = []
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "E" // short weekday
        for i in stride(from: 6, through: 0, by: -1) {
            if let day = calendar.date(byAdding: .day, value: -i, to: today) {
                let key = dateKey(for: day)
                let label = df.string(from: day).capitalized
                result.append((label, dict[key, default: 0]))
            }
        }
        return result
    }
}

private struct StatsCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.12))
        )
    }
}

private struct SevenDayBarChart: View {
    let data: [(label: String, count: Int)]
    
    var maxValue: CGFloat {
        CGFloat(max(1, data.map { $0.count }.max() ?? 1))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0..<data.count, id: \.self) { i in
                    VStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [Color.blue.opacity(0.8), Color.blue], startPoint: .top, endPoint: .bottom))
                            .frame(width: 16, height: barHeight(for: data[i].count))
                        Text(data[i].label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let h: CGFloat = 120
        return max(6, h * CGFloat(count) / maxValue)
    }
}

#Preview {
    ProfileView(sessionCount: 3)
}

