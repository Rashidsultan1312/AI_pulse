import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    // Состояние для показа Paywall
    @State private var showPaywall = false
    
    @Binding var hasCompletedOnboarding: Bool
    
    private let pages: [OnboardingPage] = [
        .init(imageName: "onb1", title: "Measure your\nHeart Rate", subtitle: "Use your camera to instantly measure and monitor your pulse."),
        .init(imageName: "onb2", title: "Track Your\nProgress", subtitle: "Keep an eye on your daily and weekly heart rate trends."),
        .init(imageName: "onb3", title: "See Full\nHistory", subtitle: "Access your full measurement history at any time."),
        .init(imageName: "onb4", title: "Stay Aware\nof Your Health", subtitle: "Understand how your lifestyle affects your heart rate.")
    ]
    
    private let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "F9B8C2"),
            Color(hex: "EF4874")
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    private let activeGradient = LinearGradient(
        colors: [Color(hex: "FF1C64"), Color(hex: "FFA4B1")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // IMAGE SECTION
                GeometryReader { geo in
                    Image(pages[currentPage].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.95)
                        .scaleEffect(pages[currentPage].imageName == "onb4" ? 1.25 : 1.0)
                        .offset(y: pages[currentPage].imageName == "onb4" ? 80 : 30)
                        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2 + 30)
                        .mask(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.95), .white.opacity(0.6), .white.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(height: UIScreen.main.bounds.height * 0.6)
                
                // BOTTOM BLOCK
                VStack(spacing: 22) {
                    
                    // INDICATORS
                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            if index == currentPage {
                                Capsule()
                                    .fill(activeGradient)
                                    .frame(width: 36, height: 10)
                                    .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // TEXT
                    VStack(spacing: 10) {
                        Text(pages[currentPage].title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(height: 68)
                        
                        Text(pages[currentPage].subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .frame(height: 44)
                    }
                    
                    // BUTTON
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        } else {
                            // ✅ ВМЕСТО ЗАВЕРШЕНИЯ -> ОТКРЫВАЕМ PAYWALL
                            showPaywall = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(buttonGradient)
                            .clipShape(Capsule())
                            .padding(.horizontal, 44)
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.38)
                .background(Color.white.shadow(color: .black.opacity(0.15), radius: 25, y: -10))
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .transaction { transaction in
            transaction.animation = .spring()
        }
        // ✅ ПОКАЗЫВАЕМ PAYWALL
        .fullScreenCover(isPresented: $showPaywall, onDismiss: {
            // Когда Paywall закроется (крестиком или после покупки),
            // мы завершаем онбординг и переходим в MainView
            withAnimation {
                hasCompletedOnboarding = true
            }
        }) {
            PaywallView()
        }
    }
}
