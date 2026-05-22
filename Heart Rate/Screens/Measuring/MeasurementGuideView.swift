import SwiftUI
import Combine

struct MeasurementGuideView: View {
    @Binding var isPresented: Bool
    let onComplete: (Int) -> Void
    
    @StateObject private var heartRateManager = HeartRateManager()
    
    @State private var isMeasuring = false
    
    @State private var remainingTime = 30
    @State private var progress: CGFloat = 1.0
    @State private var timerSubscription: AnyCancellable?

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            VStack {
                // --- Кастомный Navigation Bar ---
                HStack {
                    Button(action: {
                        heartRateManager.stop()
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Measurement")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    Rectangle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                if isMeasuring {
                    measuringContent
                } else {
                    guideContent
                }
                
                Spacer()
                Spacer()
            }
            .transition(.opacity.animation(.easeInOut))
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                heartRateManager.start()
            }
        }
        .onDisappear {
            heartRateManager.stop()
            stopTimer()
        }
        .onChange(of: heartRateManager.isFingerDetected) { newValue in
            
            if newValue {
                print("Палец обнаружен, ЗАПУСКАЕМ 30-сек таймер...")
                withAnimation { isMeasuring = true }
                startTimer()
            } else {
                print("Палец убран, ОСТАНАВИЛИВАЕМ таймер...")
                withAnimation { isMeasuring = false }
                stopTimer()
            }
        }
    }
    
    // --- Функции таймера (ОБНОВЛЕНЫ) ---
    
    func startTimer() {
        remainingTime = 30
        progress = 1.0
        stopTimer()
        
        self.timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard isMeasuring else { return }
            
                if remainingTime > 0 {
                    withAnimation(.linear(duration: 1.0)) {
                        remainingTime -= 1
                        progress = CGFloat(remainingTime) / 30.0
                    }
                } else {
                    stopTimer()
                    print("Измерение завершено. BPM: \(heartRateManager.bpm)")
                    
                    heartRateManager.stop()
                    isPresented = false
                    onComplete(heartRateManager.bpm)
                }
            }
    }
    
    func stopTimer() {
        self.timerSubscription?.cancel()
        self.timerSubscription = nil
        remainingTime = 30
        progress = 1.0
    }

    // --- Вспомогательные Views (guideContent, measuringContent) ---
    
    var guideContent: some View {
        VStack {
            Text("Starting measurement")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text("Place your finger on the camera")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 5)
            Image("guide_hand")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .padding(.top, 40)
        }
    }
    
    var measuringContent: some View {
        VStack {
            Text("Measuring...")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text("Hold your finger on camera")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            ZStack { // Таймер
                Circle().stroke(lineWidth: 20).foregroundColor(Color.gray.opacity(0.2))
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .fill(LinearGradient(colors: [Color(hex: "FFA0B5"), Color(hex: "F3547E")], startPoint: .top, endPoint: .bottom))
                    .rotationEffect(Angle(degrees: 270.0))
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    
                    Text("\(remainingTime)")
                        .font(.system(size: 50, weight: .bold))
                        .contentTransition(.opacity)
                    
                    Text("SEC")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.black)
                .animation(.easeInOut(duration: 0.3), value: remainingTime)
            }
            .frame(width: 200, height: 200)
            .padding(.vertical, 40)
            
            // ✅ Используем компонент из ReusableViews.swift
            HeartbeatAnimationView()
                .frame(height: 100)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
