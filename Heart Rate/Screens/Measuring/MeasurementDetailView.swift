import SwiftUI

struct MeasurementDetailView: View {
    let item: MeasurementHistoryItem
    
    // ✅ New Callback
    var onAskAI: () -> Void
    
    private let aiButtonGradient = LinearGradient(
        colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private var statusColor: Color {
        switch item.status {
        case .low: return .gray
        case .normal: return Color(hex: "00B031")
        case .high: return Color(hex: "F3547E")
        }
    }
    
    // MARK: - Helpers
    private func remap(_ value: CGFloat, fromLow: CGFloat, fromHigh: CGFloat, toLow: CGFloat, toHigh: CGFloat) -> CGFloat {
        let fromPercentage = (value - fromLow) / (fromHigh - fromLow)
        let toValue = (fromPercentage * (toHigh - toLow)) + toLow
        return toValue
    }

    private func thumbPosition(width: CGFloat) -> CGFloat {
        let bpm = CGFloat(item.bpm)
        let normalized: CGFloat
        
        let lowAnchor: CGFloat = 0.15
        let normalStart: CGFloat = 0.35
        let normalEnd: CGFloat = 0.65
        let highAnchor: CGFloat = 0.85

        switch item.status {
        case .low:
            normalized = remap(bpm, fromLow: 40, fromHigh: 60, toLow: lowAnchor, toHigh: normalStart)
        case .normal:
            normalized = remap(bpm, fromLow: 61, fromHigh: 100, toLow: normalStart, toHigh: normalEnd)
        case .high:
            normalized = remap(bpm, fromLow: 101, fromHigh: 180, toLow: normalEnd, toHigh: highAnchor)
        }
        
        let clampedNormalized = max(lowAnchor, min(highAnchor, normalized))
        let padding: CGFloat = 20
        return (width - padding * 2) * clampedNormalized + padding
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Top indicator
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 28)

            // --- Main Content ---
            VStack {
                // 1. BPM + Ask AI Button
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("\(item.bpm)")
                            .font(.system(size: 85, weight: .bold))
                            .foregroundColor(.black)
                       
                        VStack(spacing: 6) {
                            GradientHeartIcon()
                            Text("BPM")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // ✅ Ask AI Button (Action triggers callback)
                    Button(action: {
                        onAskAI()
                    }) {
                        HStack(spacing: 8) {
                            Text("Ask AI")
                                .font(.system(size: 18, weight: .semibold))
                            Image("askai")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        .foregroundStyle(aiButtonGradient)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(Capsule())
                        )
                        .overlay(
                            Capsule()
                                .stroke(aiButtonGradient, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    }
                }
                .padding(.horizontal, 28)
              
                // 2. Tags
                HStack(spacing: 12) {
                    if let mood = item.mood {
                        DetailTagView(text: mood, icon: "mood_\(mood.lowercased())", style: .mood)
                    }
                    if let activity = item.activity {
                        DetailTagView(text: activity, icon: "act_\(activity.lowercased())", style: .activity)
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
              
                Spacer(minLength: 30)
              
                // 3. Status
                VStack(spacing: 8) {
                    Text(item.status.rawValue)
                        .font(.system(size: 38, weight: .heavy))
                        .foregroundColor(statusColor)
                    Text(item.formattedDate)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
              
                Spacer(minLength: 35)
              
                // 4. Gauge
                VStack(spacing: 14) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.25), Color(hex: "C8FFC8"), Color(hex: "58FF58"), Color(hex: "FFE76B"), Color(hex: "FF6565")]), startPoint: .leading, endPoint: .trailing))
                            .frame(height: 28)
                       
                        GeometryReader { geo in
                            let x = thumbPosition(width: geo.size.width)
                            Circle()
                                .fill(statusColor)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.white, lineWidth: 5))
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
                                .position(x: x, y: geo.size.height / 2)
                        }
                    }
                    .frame(height: 28)
                    .padding(.horizontal, 16)
                   
                    HStack {
                        Text("Low").font(.system(size: 19, weight: .medium)).foregroundColor(.gray)
                        Spacer()
                        Text("Normal").font(.system(size: 19, weight: .medium)).foregroundColor(Color(hex: "00C851"))
                        Spacer()
                        Text("High").font(.system(size: 19, weight: .medium)).foregroundColor(Color(hex: "F44336"))
                    }
                    .padding(.horizontal, 28)
                }
              
                Spacer(minLength: 20)
            }
            .frame(maxHeight: .infinity)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
    }
}
