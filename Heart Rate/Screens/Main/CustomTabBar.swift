import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    let onMeasureTap: () -> Void
    
    private let activeHeartGradient = LinearGradient(
        colors: [Color(hex: "F9B8C2"), Color(hex: "EF4874")],
        startPoint: .top,
        endPoint: .bottom
    )
    private let inactiveColor = Color.gray.opacity(0.8)
    private let centerButtonGradient = LinearGradient(
        colors: [Color(hex: "FFA0B5"), Color(hex: "F3547E")],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            // 1. ФОН
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(Color(hex: "DDDEE2").opacity(0.7))
                .frame(height: 95)
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)

            // 2. Кнопки таб-бара
            HStack(spacing: 0) {
                // ✅ Используем компонент из ReusableViews.swift
                TabButton(
                    imageName: "tab_heart",
                    text: "Measuring",
                    isActive: selectedTab == .measuring,
                    activeGradient: activeHeartGradient,
                    inactiveColor: inactiveColor,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .measuring
                        }
                    }
                )
                
                Spacer()
                
                // ✅ Используем компонент из ReusableViews.swift
                TabButton(
                    imageName: "tab_insights",
                    text: "Insights",
                    isActive: selectedTab == .insights,
                    activeGradient: nil,
                    inactiveColor: inactiveColor,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .insights
                        }
                    }
                )
            }
            .padding(.horizontal, 35)

            // 3. Центральная плавающая кнопка
            Button(action: {
                onMeasureTap()
            }) {
                ZStack {
                    Circle()
                        .fill(centerButtonGradient)
                        .frame(width: 68, height: 68)
                        .shadow(color: Color(hex: "F3547E").opacity(0.5), radius: 10, y: 5)
                    
                    Image("tab_measure")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundColor(.white)
                }
            }
            .offset(y: -40)
        }
        .frame(height: 95) // Общая высота
    }
}

// ✅
// ❗️ 'struct TabButton' УДАЛЕНА ОТСЮДА
// ❗️ Убедитесь, что у вас есть файл ReusableViews.swift
// ✅
