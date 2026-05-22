import SwiftUI
import Combine

// MARK: - 1. Модель Сообщения (Для чата)
struct ChatMessage: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let text: String
    let isUser: Bool
}

// MARK: - 2. Единая Модель Данных
struct MeasurementHistoryItem: Identifiable, Codable, Hashable {
    let id: UUID
    let bpm: Int
    let date: Date
    let status: Status
    let mood: String?
    let activity: String?
    
    // ✅ Храним историю чата для этого конкретного измерения
    var chatHistory: [ChatMessage] = []
    
    enum Status: String, Codable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
    }
    
    init(id: UUID = UUID(), bpm: Int, date: Date = Date(), status: Status, mood: String?, activity: String?, chatHistory: [ChatMessage] = []) {
        self.id = id
        self.bpm = bpm
        self.date = date
        self.status = status
        self.mood = mood
        self.activity = activity
        self.chatHistory = chatHistory
    }
    
    // Хелперы для UI
    var statusColor: Color {
        switch status {
        case .high: return Color(hex: "FFD9D9")
        case .normal: return Color(hex: "D9FFE5")
        case .low: return Color(hex: "E0E0E0")
        }
    }
    
    var statusTextColor: Color {
        switch status {
        case .high: return Color(hex: "F3547E")
        case .normal: return Color(hex: "00B031")
        case .low: return Color(hex: "5E5E5E")
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - 3. Класс-Хранилище
class HistoryStore: ObservableObject {
    @AppStorage("measurementHistory") private var historyData: Data?
    
    // ✅ Основной массив данных
    @Published var history: [MeasurementHistoryItem] = [] {
        didSet {
            saveHistory()
        }
    }
    
    init() {
        loadHistory()
    }
    
    // Добавление нового измерения (с чатом)
    func addMeasurement(bpm: Int, resultStatus: MeasurementHistoryItem.Status, mood: String?, activity: String?, chatHistory: [ChatMessage] = []) {
        let newItem = MeasurementHistoryItem(
            bpm: bpm,
            status: resultStatus,
            mood: mood,
            activity: activity,
            chatHistory: chatHistory
        )
        history.insert(newItem, at: 0)
    }
    
    // Обновление чата у существующего элемента
    func updateChatHistory(for itemId: UUID, newHistory: [ChatMessage]) {
        if let index = history.firstIndex(where: { $0.id == itemId }) {
            history[index].chatHistory = newHistory
            // saveHistory сработает автоматически через didSet
        }
    }
    
    private func loadHistory() {
        guard let data = historyData else { return }
        do {
            let decoder = JSONDecoder()
            let decodedHistory = try decoder.decode([MeasurementHistoryItem].self, from: data)
            self.history = decodedHistory.sorted(by: { $0.date > $1.date })
        } catch {
            print("⚠️ Ошибка декодирования истории: \(error)")
        }
    }
    
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            historyData = data
        } catch {
            print("⚠️ Ошибка кодирования истории: \(error)")
        }
    }
}

// MARK: - 4. Расширение для AI (Контекст)
extension HistoryStore {
    func getHistoryContextString() -> String {
        // Используем правильное имя массива: 'history' (не measurements)
        let recentItems = history.sorted(by: { $0.date > $1.date }).prefix(20)
        
        if recentItems.isEmpty {
            return "No previous measurements recorded."
        }
        
        var contextString = "USER HISTORY DATA (Last 20 records):\n"
        
        for item in recentItems {
            let moodStr = item.mood ?? "No mood"
            let activityStr = item.activity ?? "No activity"
            
            contextString += "- [\(item.formattedDate) | \(item.bpm) BPM | \(item.status.rawValue) | \(moodStr) | \(activityStr)]\n"
        }
        
        return contextString
    }
}
