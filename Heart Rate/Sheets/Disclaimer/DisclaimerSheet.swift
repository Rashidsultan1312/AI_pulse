import SwiftUI

struct DisclaimerSheet: View {
    @Binding var isPresented: Bool
    @Binding var doNotShowAgain: Bool
    let onConfirm: () -> Void
    
    private let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "F9B8C2"),
            Color(hex: "EF4874")
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 0) {

            Spacer().frame(height: 40)

            // Иконка предупреждения
            Image("warning_big")
                .resizable()
                .scaledToFit()
                .frame(width: 145, height: 145)
                .offset(y: -20)

            VStack(spacing: 18) {

                Text("Important")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)

                Text("This application is for informational purposes only and should not be considered a substitute for medical advice.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal, 32)

                // Чекбокс
                Button(action: {
                    withAnimation(.spring(duration: 0.25)) {
                        doNotShowAgain.toggle()
                    }
                }) {
                    HStack(spacing: 14) {

                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 26, height: 26)

                            if doNotShowAgain {
                                Circle()
                                    .fill(Color(hex: "EF4874"))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .transition(.scale)
                            }
                        }

                        Text("Do not display again")
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                    }
                }
                .padding(.top, 2)

                // Кнопка Confirm
                Button(action: {
                    onConfirm()
                    isPresented = false
                }) {
                    Text("Confirm")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(buttonGradient)
                        .cornerRadius(28)
                        .padding(.horizontal, 28)
                }
                .padding(.top, 8)

            }
            .padding(.bottom, 20)

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(32)
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .background(.clear)
    }
}
