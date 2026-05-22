//
//  CameraAccessAlert.swift
//  Heart Rate
//
//  Created by Adlet Kanatbek on 11/7/25.
//

import SwiftUI

struct CameraAccessAlert: View {
    @Binding var isPresented: Bool
    
    private let buttonGradient = LinearGradient(
        colors: [Color(hex: "FFA0B5"), Color(hex: "F3547E")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()   // ← тянет всё к середине
            
            VStack(spacing: 20) {
                
                Image("settings_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
                
                Text("Camera access required")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                
                Text("To assess your heart rate, please ensure that Camera permissions are enabled in your iPhone settings.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    withAnimation { isPresented = false }
                }) {
                    Text("Open settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(buttonGradient)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 25)
                
                Button(action: {
                    withAnimation { isPresented = false }
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.gray.opacity(0.18))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 25)
                
            }
            
            Spacer()   // ← тянет вверх, центрируя идеально
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
}
