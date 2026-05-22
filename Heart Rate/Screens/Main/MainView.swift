import SwiftUI
import AVFoundation

enum Tab {
    case measuring
    case insights
}

struct MainView: View {
    @EnvironmentObject var historyStore: HistoryStore
    
    @State private var selectedTab: Tab = .measuring
    @State private var showDisclaimer = false
    @State private var showCameraAccessAlert = false
    @State private var showMeasurementGuide = false
    
    @State private var showResultSheet = false
    @State private var lastBPM: Int? = nil
    @State private var selectedDetailItem: MeasurementHistoryItem? = nil
    
    @State private var navigateToChat = false
    @State private var chatContextItem: MeasurementHistoryItem?
    @State private var chatExistingID: UUID?
    
    @AppStorage("doNotShowDisclaimerAgain") private var doNotShowDisclaimerAgain = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // MAIN CONTENT
                VStack(spacing: 0) {
                    HStack {
                        Text(currentTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Image("settings")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.gray.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    Rectangle()
                        .fill(Color(hex: "DEDEDE"))
                        .frame(height: 1)
                        .padding(.top, 15)
                    
                    ZStack {
                        MeasuringView(selectedItem: $selectedDetailItem)
                            .opacity(selectedTab == .measuring ? 1 : 0)
                            .allowsHitTesting(selectedTab == .measuring)
                            .animation(.easeInOut, value: selectedTab)
                        
                        InsightsView()
                            .opacity(selectedTab == .insights ? 1 : 0)
                            .allowsHitTesting(selectedTab == .insights)
                            .animation(.easeInOut, value: selectedTab)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // TABBAR
                VStack {
                    Spacer()
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        onMeasureTap: {
                            if !doNotShowDisclaimerAgain {
                                showDisclaimer = true
                            } else {
                                startMeasurement()
                            }
                        }
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }

            // CHAT FROM HISTORY
            .navigationDestination(isPresented: $navigateToChat) {
                if let id = chatExistingID, let item = chatContextItem {
                    ChatAIView(
                        existingItemID: id,
                        contextItem: item
                    )
                } else {
                    ChatAIView()
                }
            }

            // DISCLAIMER SHEET
            .sheet(isPresented: $showDisclaimer) {
                DisclaimerView(
                    isPresented: $showDisclaimer,
                    doNotShowAgain: $doNotShowDisclaimerAgain,
                    onConfirm: {
                        startMeasurementAfterDelay()
                    }
                )
                .frame(height: UIScreen.main.bounds.height * 0.50)
                .presentationDetents([.fraction(0.50)], selection: .constant(.fraction(0.50)))
                .presentationDragIndicator(.hidden)
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled()
                .presentationCornerRadius(32)
                .ignoresSafeArea(edges: .bottom)
            }

            // CAMERA ALERT SHEET
            .sheet(isPresented: $showCameraAccessAlert) {
                CameraAccessAlert(isPresented: $showCameraAccessAlert)
                    .frame(height: UIScreen.main.bounds.height * 0.55)
                    .presentationDetents([.fraction(0.55)], selection: .constant(.fraction(0.50)))
                    .presentationDragIndicator(.hidden)
                    .presentationBackgroundInteraction(.disabled)
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(32)
                    .ignoresSafeArea(edges: .bottom)
            }

            // RESULT SHEET
            .sheet(isPresented: $showResultSheet, onDismiss: {
                lastBPM = nil
            }) {
                NavigationStack {
                    if let bpm = lastBPM {
                        ResultFlowView(
                            result: MeasurementResult(bpm: bpm),
                            onMeasureAgain: {
                                showResultSheet = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showMeasurementGuide = true
                                }
                            },
                            onAskAI: {}
                        )
                        .environmentObject(historyStore)
                    }
                }
                .presentationDetents([.fraction(0.69)])
                .presentationCornerRadius(32)
                .ignoresSafeArea(edges: .bottom)
            }

            // DETAIL SHEET
            .sheet(item: $selectedDetailItem) { item in
                MeasurementDetailView(
                    item: item,
                    onAskAI: {
                        selectedDetailItem = nil
                        chatContextItem = item
                        chatExistingID = item.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigateToChat = true
                        }
                    }
                )
                .presentationDetents([.fraction(0.66)])
                .presentationCornerRadius(32)
                .presentationBackground(.regularMaterial)
                .id(item.id)
                .ignoresSafeArea(edges: .bottom)
            }

            // FULLSCREEN MEASUREMENT GUIDE
            .fullScreenCover(isPresented: $showMeasurementGuide) {
                MeasurementGuideView(
                    isPresented: $showMeasurementGuide,
                    onComplete: { bpm in
                        handleMeasurementResult(bpm)
                    }
                )
            }

            // ARTICLE DESTINATION (можно оставить, но теперь не обязательно)
            .navigationDestination(for: InsightArticle.self) { article in
                ArticleDetailView(article: article)
            }
            
            .navigationBarHidden(true)
        }
    }

    private var currentTitle: String {
        switch selectedTab {
        case .measuring: return "Heart Rate"
        case .insights: return "Insights"
        }
    }
    
    private func startMeasurementAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startMeasurement()
        }
    }
    
    private func handleMeasurementResult(_ bpm: Int) {
        self.lastBPM = bpm
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showResultSheet = true
        }
    }
    
    private func startMeasurement() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showMeasurementGuide = true
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showMeasurementGuide = true
                    } else {
                        showCameraAccessAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            showCameraAccessAlert = true
            
        @unknown default:
            fatalError("Unknown camera permission state")
        }
    }
}
