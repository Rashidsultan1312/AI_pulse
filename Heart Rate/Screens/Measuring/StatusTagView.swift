import SwiftUI

struct StatusTagView: View {
    let status: MeasurementHistoryItem.Status
    
    private var textColor: Color {
        switch status {
        case .high: return Color(hex: "FF3B30")
        case .normal: return Color(hex: "34C759")
        case .low: return Color(hex: "919191")
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .high: return Color(hex: "FF3B30").opacity(0.30)
        case .normal: return Color(hex: "34C759").opacity(0.30)
        case .low: return Color(hex: "919191").opacity(0.30)
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(textColor)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(textColor, lineWidth: 1)
            )
    }
}

// MARK: - Gradient Button (из OnboardingView / DisclaimerView)
struct GradientButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "F9B8C2"),
                            Color(hex: "EF4874")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 40)
    }
}

// MARK: - Tab Button (из CustomTabBar)
struct TabButton: View {
    let imageName: String
    let text: String
    let isActive: Bool
    let activeGradient: LinearGradient?
    let inactiveColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                
                let icon = Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()

                if isActive && activeGradient != nil {
                    // Состояние 1: Активно (Measuring) - 38x38
                    icon
                        .frame(width: 38, height: 38)
                        .foregroundStyle(activeGradient!)
                    
                } else if isActive {
                    // Состояние 2: Активно (Insights) - 33x33
                    icon
                        .frame(width: 33, height: 33)
                        .foregroundColor(Color(hex: "EF4874"))
                        
                } else {
                    // Состояние 3: Неактивно - 33x33
                    icon
                        .frame(width: 33, height: 33)
                        .foregroundColor(inactiveColor)
                }

                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isActive ? Color(hex: "EF4874") : inactiveColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Picker Button (из MeasuringView)
struct PickerButton: View {
    let title: String
    let isSelected: Bool
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                // ✅ 1. ШРИФТ СТАЛ БОЛЬШЕ И ЖИРНЕЕ
                .font(.system(size: 18, weight: .bold))
                // ✅ 2. НЕАКТИВНЫЙ ЦВЕТ ТЕПЕРЬ .black
                .foregroundColor(isSelected ? .white : .black)
                // ✅ 3. УМЕНЬШИЛ ПАДДИНГ, ТАК КАК ШРИФТ БОЛЬШЕ
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background {
                    if isSelected { Capsule().fill(gradient) }
                    else { Capsule().fill(Color.clear) }
                }
        }
    }
}

// MARK: - Heartbeat Animation (из MeasurementGuideView)
struct HeartbeatAnimationView: View {
    @State private var scanOffset: CGFloat = -0.5
    
    private let pulseGradient = LinearGradient(
        colors: [Color(hex: "F3547E"), Color(hex: "FFA0B5")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            PulseLifeShape()
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            
            PulseLifeShape()
                .stroke(pulseGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .mask(
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: geo.size.width * 0.4)
                            .offset(x: scanOffset * geo.size.width)
                    }
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                scanOffset = 1.1
            }
        }
    }
}

// Фигура (Shape) самого пульса
struct PulseLifeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * 0.5
        
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: width * 0.1, y: midY))
        path.addCurve(to: CGPoint(x: width * 0.15, y: midY * 0.9),
                      control1: CGPoint(x: width * 0.12, y: midY),
                      control2: CGPoint(x: width * 0.13, y: midY * 0.9))
        path.addCurve(to: CGPoint(x: width * 0.2, y: midY),
                      control1: CGPoint(x: width * 0.17, y: midY * 0.9),
                      control2: CGPoint(x: width * 0.18, y: midY))
        path.addLine(to: CGPoint(x: width * 0.25, y: midY))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.9))
        path.addLine(to: CGPoint(x: width * 0.45, y: midY))
        path.addLine(to: CGPoint(x: width * 0.55, y: midY))
        path.addCurve(to: CGPoint(x: width * 0.65, y: midY * 0.8),
                      control1: CGPoint(x: width * 0.6, y: midY),
                      control2: CGPoint(x: width * 0.63, y: midY * 0.8))
        path.addCurve(to: CGPoint(x: width * 0.75, y: midY),
                      control1: CGPoint(x: width * 0.67, y: midY * 0.8),
                      control2: CGPoint(x: width * 0.72, y: midY))
        path.addLine(to: CGPoint(x: width * 1.0, y: midY))
        
        return path
    }
}

// MARK: - Gradient Heart Icon
struct GradientHeartIcon: View {
    var width: CGFloat = 26
    var height: CGFloat = 26
    
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// MARK: - Detail Tag (для экрана деталей)
struct DetailTagView: View {
    let text: String
    let icon: String // Имя ассета
    let style: TagStyle
    
    enum TagStyle {
        case mood
        case activity
    }
    
    // Цвета на основе вашего скриншота
    private var strokeColor: Color {
        style == .mood ? Color(hex: "FFC700") : Color(hex: "007AFF") // Yellow / Blue
    }
    
    private var backgroundColor: Color {
        strokeColor.opacity(0.1)
    }
    
    private var iconColor: Color? {
        // Иконки настроения (mood) - цветные, иконки активности - шаблонные (синие)
        style == .mood ? nil : strokeColor
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(strokeColor)
            
            Image(icon)
                .resizable()
                // .original, если иконка настроения, .template, если активности
                .renderingMode(iconColor == nil ? .original : .template)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(iconColor) // Окрашивает только иконки активности
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(strokeColor, lineWidth: 1)
        )
    }
}
