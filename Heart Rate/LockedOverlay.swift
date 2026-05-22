//
//  LockedOverlay.swift
//  Heart Rate
//
//  Created by Adlet Kanatbek on 11/19/25.
//
import SwiftUI

// 2. МОДИФИКАТОР (БЛЮР + КНОПКА)
struct LockedOverlay: ViewModifier {
    @Binding var isLocked: Bool // Заблокировано или нет
    @State private var showPaywall = false
    
    private let pinkGradient = LinearGradient(
        colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func body(content: Content) -> some View {
        ZStack {
            // Контент (Размываем, если заблокировано)
            content
                .blur(radius: isLocked ? 15 : 0)
                .allowsHitTesting(!isLocked) // Запрещаем кликать по контенту, если блок
                .animation(.easeInOut, value: isLocked)
            
            // Кнопка поверх (Показываем только если заблокировано)
            if isLocked {
                Button(action: {
                    showPaywall = true
                }) {
                    HStack(spacing: 8) {
                        Text("See result")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(pinkGradient)
                        
                        ZStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(pinkGradient)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .offset(y: 1)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        Capsule()
                            .stroke(pinkGradient, lineWidth: 2)
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// Расширение для удобства использования .locked()
extension View {
    func locked(isLocked: Binding<Bool>) -> some View {
        self.modifier(LockedOverlay(isLocked: isLocked))
    }
}
