import SwiftUI
import Charts

// ✅ 1. ДОБАВЛЯЕМ 'Equatable', ЧТОБЫ СРАВНИВАТЬ ДАННЫЕ ДЛЯ АНИМАЦИИ
struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let dateLabel: String
    let bpm: Int
    let status: MeasurementHistoryItem.Status
    
    var pointColor: Color {
        switch status {
        case .high: return Color(hex: "F3547E")
        case .normal: return Color(hex: "00B031")
        case .low: return Color(hex: "8E8E93")
        }
    }
}

// MARK: - Header с графиком
struct HeaderChartView: View {
    @Binding var selectedPeriod: StatsPeriod
    @Binding var displayedDate: Date
    
    let chartData: [ChartDataPoint]
    let pickerGradient: LinearGradient
    let dateRangeText: String
    
    // ✅ 2. НОВОЕ СОСТОЯНИЕ ДЛЯ АНИМАЦИИ ПОЯВЛЕНИЯ
    @State private var hasAppeared = false
    
    // --- Хелперы для кнопок-стрелок (без изменений) ---
    
    private func moveDate(by amount: Int) {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch selectedPeriod {
        case .day:
            newDate = calendar.date(byAdding: .day, value: amount, to: displayedDate)
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: amount, to: displayedDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: amount, to: displayedDate)
        }
        
        if let newDate = newDate {
            if newDate <= Date() {
                displayedDate = newDate
            } else {
                displayedDate = Date()
            }
        }
    }
    
    private var isViewingCurrentPeriod: Bool {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            return calendar.isDate(displayedDate, inSameDayAs: Date())
        case .week, .month:
            if selectedPeriod == .week {
                return calendar.isDate(displayedDate, equalTo: Date(), toGranularity: .weekOfYear)
            } else {
                return calendar.isDate(displayedDate, equalTo: Date(), toGranularity: .month)
            }
        }
    }
    
    
    // --- Хелперы для графика ---
    
    private func chartXScaleDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: displayedDate)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return startOfDay...tomorrow
    }
    
    // ✅ 3. ГЛАВНЫЕ ИЗМЕНЕНИЯ ДЛЯ АНИМАЦИИ ГРАФИКА
    private var chartContent: some View {
        Chart {
            ForEach(chartData) { dataPoint in
                if selectedPeriod == .day {
                    // --- ЛИНИЯ ---
                    LineMark(
                        x: .value("Time", dataPoint.date),
                        // Анимируем Y-позицию (линия "вырастает" из 0)
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5]))
                    .foregroundStyle(Color.gray.opacity(0.7))
                    
                    // --- ТОЧКА ---
                    PointMark(
                        x: .value("Time", dataPoint.date),
                        // Анимируем Y-позицию
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    // Анимируем размер (точка "надувается")
                    .symbolSize(hasAppeared ? 150 : 0)
                    .foregroundStyle(dataPoint.pointColor)
                    
                    // --- ОБЛАСТЬ (для совместимости) ---
                    AreaMark(
                        x: .value("Time", dataPoint.date),
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    .foregroundStyle(.clear)
                    
                } else {
                    // --- ЛИНИЯ ---
                    LineMark(
                        x: .value("Date", dataPoint.dateLabel),
                        // Анимируем Y-позицию (линия "вырастает" из 0)
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5]))
                    .foregroundStyle(Color.gray.opacity(0.7))
                    
                    // --- ТОЧКА ---
                    PointMark(
                        x: .value("Date", dataPoint.dateLabel),
                        // Анимируем Y-позицию
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    // Анимируем размер (точка "надувается")
                    .symbolSize(hasAppeared ? 150 : 0)
                    .foregroundStyle(dataPoint.pointColor)
                    
                    // --- ОБЛАСТЬ (для совместимости) ---
                    AreaMark(
                        x: .value("Date", dataPoint.dateLabel),
                        y: .value("BPM", hasAppeared ? dataPoint.bpm : 0)
                    )
                    .foregroundStyle(.clear)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Пикер (Day/Week/Month) - без изменений
            HStack {
                Spacer()
                PickerButton(title: "Day", isSelected: selectedPeriod == .day, gradient: pickerGradient) { selectedPeriod = .day }
                Spacer()
                PickerButton(title: "Week", isSelected: selectedPeriod == .week, gradient: pickerGradient) { selectedPeriod = .week }
                Spacer()
                PickerButton(title: "Month", isSelected: selectedPeriod == .month, gradient: pickerGradient) { selectedPeriod = .month }
                Spacer()
            }
            .padding(.horizontal)
            
            // Блок с датой - без изменений
            HStack {
                Button(action: {
                    moveDate(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                }
                Spacer()
                Text(dateRangeText)
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button(action: {
                    moveDate(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .semibold))
                }
                .disabled(isViewingCurrentPeriod)
                .opacity(isViewingCurrentPeriod ? 0.3 : 1.0)
            }
            .foregroundColor(.black)
            .padding(.horizontal)
            
            // --- Блок графика (без изменений) ---
            if selectedPeriod == .day {
                chartContent
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 35, 70, 110, 140, 180]) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.gray.opacity(0.3))
                            AxisTick()
                            AxisValueLabel(centered: true)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 4)) {
                            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)), centered: true)
                                .font(.system(size: 10))
                        }
                    }
                    .chartYScale(domain: 0...180)
                    .chartXScale(domain: chartXScaleDomain())
                    .frame(height: 250)
                    .padding(.horizontal)
            } else {
                chartContent
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 35, 70, 110, 140, 180]) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color.gray.opacity(0.3))
                            AxisTick()
                            AxisValueLabel(centered: true)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel(value.as(String.self) ?? "")
                                .font(.system(size: 10))
                        }
                    }
                    .chartYScale(domain: 0...180)
                    .frame(height: 250)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 10)
        
        // ✅ 4. ДОБАВЛЯЕМ АНИМАТОРЫ В КОНЕЦ 'body'
        
        // Анимация "появления" (сработает 1 раз при открытии)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }
        }
        // Анимация смены данных (сработает при нажатии Day/Week/Month или стрелок)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: chartData)
    }
}
