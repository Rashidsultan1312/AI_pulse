import SwiftUI

struct DisclaimerView: View {
    @Binding var isPresented: Bool
    @Binding var doNotShowAgain: Bool
    let onConfirm: () -> Void
    
    private let buttonGradient = LinearGradient(
        colors: [Color(hex: "FFA0B5"), Color(hex: "F3547E")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()   // ← тянет контент вниз
            
            VStack(spacing: 20) {
                
                Image("alert_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)
                
                Text("Important")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                
                Text("This application is for informational purposes only and should not be considered a substitute for medical advice.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    withAnimation { doNotShowAgain.toggle() }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: doNotShowAgain ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(doNotShowAgain ? Color(hex: "EF4874") : .gray.opacity(0.4))
                        
                        Text("Do not display again")
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 2)
                
                Button(action: {
                    onConfirm()
                    isPresented = false
                }) {
                    Text("Confirm")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(buttonGradient)
                        .clipShape(Capsule())
                        .padding(.horizontal, 25)
                }
            }
            
            Spacer()   // ← тянет контент вверх
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
}


// Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
