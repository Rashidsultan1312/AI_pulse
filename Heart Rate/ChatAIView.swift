import SwiftUI

struct ChatAIView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyStore: HistoryStore
    
    // --- ПАРАМЕТРЫ ---
    // Если мы открыли чат из существующей истории, сюда прилетит ID
    var existingItemID: UUID?
    
    // Если мы в процессе нового измерения (ResultFlowView), мы используем Binding
    // Это позволяет передать переписку обратно в родителя, чтобы сохранить её потом
    @Binding var temporaryChatHistory: [ChatMessage]
    
    // Конкретный элемент для контекста (нужен для формирования промпта)
    var contextItem: MeasurementHistoryItem?
    
    // --- ВНУТРЕННЕЕ СОСТОЯНИЕ ---
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var isLoading = false
    
    // Локальное отображение сообщений
    @State private var localMessages: [ChatMessage] = []
    
    private let claudeService = ClaudeService()
    private let primaryGradient = LinearGradient(colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    // Кастомный инит, чтобы удобно создавать View
    init(existingItemID: UUID? = nil, contextItem: MeasurementHistoryItem? = nil, tempHistory: Binding<[ChatMessage]>? = nil) {
        self.existingItemID = existingItemID
        self.contextItem = contextItem
        // Если Binding не передан, создаем "пустышку"
        self._temporaryChatHistory = tempHistory ?? Binding.constant([])
    }

    var body: some View {
        VStack(spacing: 0) {
            // ... NAVBAR (Тот же код, что и раньше) ...
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Heart Rate")
                            .font(.system(size: 20, weight: .bold))
                        Text("AI")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(primaryGradient)
                    }
                    Spacer()
                    Rectangle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Rectangle().fill(Color.clear).frame(height: 1).padding(.top, 15)
            }
            
            // MARK: - Chat Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if localMessages.isEmpty {
                            Text("Hello! I can analyze this specific measurement. How can I help?")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                                .padding(.horizontal, 24)
                        }
                        
                        ForEach(localMessages) { message in
                            if message.isUser {
                                HStack {
                                    Spacer()
                                    Text(message.text)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(primaryGradient)
                                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight, .bottomLeft]))
                                        .clipShape(RoundedCorner(radius: 4, corners: [.bottomRight]))
                                }
                            } else {
                                Text(message.text)
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                    .lineSpacing(4)
                            }
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView().tint(Color(hex: "FF1C64"))
                                Text("AI is typing...").font(.caption).foregroundColor(.gray)
                            }
                            .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .onChange(of: localMessages.count) { _ in
                    if let lastId = localMessages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
            }
            
            // ... INPUT AREA (Тот же код) ...
            VStack(spacing: 0) {
                Divider().opacity(0)
                HStack(spacing: 12) {
                    TextField("Ask about this result...", text: $inputText, axis: .vertical)
                        .focused($isInputFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.gray.opacity(0.15)))
                        .overlay(Capsule().stroke(primaryGradient, lineWidth: isInputFocused || !inputText.isEmpty ? 1.5 : 0))
                        .accentColor(Color(hex: "FF1C64"))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(!inputText.isEmpty ? AnyShapeStyle(primaryGradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty || isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .onTapGesture { isInputFocused = false }
        .onAppear {
            loadInitialMessages()
        }
    }
    
    // MARK: - Logic
    
    func loadInitialMessages() {
        // Сценарий 1: Открыли старую запись
        if let id = existingItemID,
           let item = historyStore.history.first(where: { $0.id == id }) {
            self.localMessages = item.chatHistory
        }
        // Сценарий 2: Новая запись (ResultFlowView)
        else {
            self.localMessages = temporaryChatHistory
        }
        
        // Авто-промпт при первом входе, если чат пустой
        if localMessages.isEmpty, let item = contextItem {
             inputText = "Analyze this measurement: \(item.bpm) BPM, Status: \(item.status.rawValue)"
             sendMessage()
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMsg = ChatMessage(text: inputText, isUser: true)
        appendMessage(userMsg)
        
        let promptText = inputText
        inputText = ""
        isLoading = true
        
        // Формируем контекст ТОЛЬКО для этого замера
        let contextData: String
        if let item = contextItem {
            contextData = """
            FOCUSED MEASUREMENT:
            Date: \(item.formattedDate)
            BPM: \(item.bpm)
            Status: \(item.status.rawValue)
            Mood: \(item.mood ?? "Not set")
            Activity: \(item.activity ?? "Not set")
            """
        } else {
            contextData = "No measurement context provided."
        }
        
        Task {
            do {
                let response = try await claudeService.sendMessage(userMessage: promptText, historyContext: contextData)
                await MainActor.run {
                    let aiMsg = ChatMessage(text: response, isUser: false)
                    appendMessage(aiMsg)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    appendMessage(ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false))
                    isLoading = false
                }
            }
        }
    }
    
    // Единая точка сохранения сообщений
    func appendMessage(_ msg: ChatMessage) {
        withAnimation {
            localMessages.append(msg)
        }
        
        // Сохраняем:
        
        // 1. Если это существующая запись в истории
        if let id = existingItemID {
            historyStore.updateChatHistory(for: id, newHistory: localMessages)
        }
        
        // 2. Если это новая запись (мы еще в ResultFlowView), обновляем Binding
        temporaryChatHistory = localMessages
    }
}
