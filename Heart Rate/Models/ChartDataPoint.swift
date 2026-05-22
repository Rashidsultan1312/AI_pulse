import SwiftUI
import Charts

// MARK: - Главный экран
struct MeasuringView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @Binding var selectedItem: MeasurementHistoryItem?
    
    @State private var selectedPeriod: StatsPeriod = .day
    @State private var isStatsExpanded = false
    @State private var displayedDate: Date = Date()
    
    // Флаг подписки
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    private let maxHeaderHeight: CGFloat = 380
    
    private let pickerGradient = LinearGradient(
        colors: [Color(hex: "FFA0B5"), Color(hex: "F3547E")],
        startPoint: .top, endPoint: .bottom
    )

    var body: some View {
        
        VStack(spacing: 0) {
            
            StatsToggleButton(isExpanded: $isStatsExpanded)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)

            if isStatsExpanded {
                HeaderChartView(
                    selectedPeriod: $selectedPeriod,
                    displayedDate: $displayedDate,
                    chartData: chartData,
                    pickerGradient: pickerGradient,
                    dateRangeText: dateRangeText
                )
                .frame(height: maxHeaderHeight)
                .clipped()
                .background(Color.white)
                
                // ✅ ИСПРАВЛЕНИЕ ОШИБКИ ЗДЕСЬ
                // Мы создаем Binding "на лету".
                // get: возвращает true, если НЕ премиум.
                // set: пустой, так как график сам не снимает блокировку.
                .locked(isLocked: Binding(
                    get: { !isPremiumUser },
                    set: { _ in }
                ))
                
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // MARK: - Контент (Список истории)
            ScrollView {
                VStack(spacing: 15) {
                    
                    if historyStore.history.isEmpty {
                        VStack(spacing: 16) {
                            Image("heart") // Или ваш Image("heart")
                                .resizable().scaledToFit().frame(width: 100, height: 100)
                                .foregroundColor(Color(hex: "FF1C64").opacity(0.5))
                                .padding(.bottom, 20)
                            Text("Nothing here yet")
                                .font(.system(size: 28, weight: .bold))
                            Text("Begin monitoring your heart rate\nby pressing the round button.")
                                .font(.system(size: 16)).foregroundColor(.gray)
                                .multilineTextAlignment(.center).padding(.horizontal, 40)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                        .padding(.top, 80)
                        
                    } else {
                        // --- Список истории ---
                        VStack(spacing: 20) {
                            ForEach(historyStore.history) { item in
                                HistoryRowView(item: item)
                                    .onTapGesture { self.selectedItem = item }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                .padding(.top, 10)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isStatsExpanded)
        .background(Color.white.ignoresSafeArea())
        .onChange(of: selectedPeriod) { _ in
            displayedDate = Date()
        }
    }
    
    // --- Данные для графика ---
    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: displayedDate)
        let now = Date()

        let allHistory = historyStore.history
        let filteredHistory: [MeasurementHistoryItem]

        switch selectedPeriod {
        case .day:
            filteredHistory = allHistory.filter {
                calendar.isDate($0.date, inSameDayAs: targetDate)
            }
        case .week:
            guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: targetDate) else { return [] }
            let endOfWeek = targetDate > now ? now : targetDate
            filteredHistory = allHistory.filter { $0.date >= startOfWeek && $0.date <= endOfWeek }
        case .month:
            guard let startOfMonth = calendar.date(byAdding: .month, value: -1, to: targetDate) else { return [] }
            let endOfMonth = targetDate > now ? now : targetDate
            filteredHistory = allHistory.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "h:mm a"
        let weekMonthFormatter = DateFormatter()
        weekMonthFormatter.dateFormat = "d.MM"

        return filteredHistory.reversed().map { item in
            let label: String
            if selectedPeriod == .day {
                label = dayFormatter.string(from: item.date)
            } else {
                label = weekMonthFormatter.string(from: item.date)
            }
            
            return ChartDataPoint(
                date: item.date,
                dateLabel: label,
                bpm: item.bpm,
                status: item.status
            )
        }
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        let targetDate = displayedDate

        switch selectedPeriod {
        case .day:
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: targetDate)
        case .week:
            formatter.dateFormat = "d MMMM"
            let startDay = Calendar.current.startOfDay(for: targetDate)
            guard let startOfWeek = Calendar.current.date(byAdding: .day, value: -6, to: startDay) else { return "" }
            let startText = formatter.string(from: startOfWeek)
            let endText = formatter.string(from: startDay)
            return "\(startText) - \(endText)"
        case .month:
            formatter.dateFormat = "MMMM"
            return formatter.string(from: targetDate)
        }
    }
}

// MARK: - Subviews
struct StatsToggleButton: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "F3547E"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
    }
}

struct HistoryRowView: View {
    let item: MeasurementHistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(item.bpm)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, -4)
                
                VStack(spacing: 2) {
                    GradientHeartIcon(width: 24, height: 24)
                    Text("BPM")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
                
                Spacer()
                
                StatusTagView(status: item.status)
            }
            
            Text(item.formattedDate)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.black.opacity(0.4))
                .padding(.leading, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// Определения StatsPeriod
enum StatsPeriod: String {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}
