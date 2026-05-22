import SwiftUI
import StoreKit

struct SettingsView: View {
    
    private let themeColor = Color(hex: "F3547E")
    
    // ✅ 1. Добавили состояние для открытия Paywall
    @State private var showPaywall = false
    
    @ViewBuilder
    private func SettingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeColor)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Custom Nav Bar
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Settings")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Rectangle()
                        .fill(Color(hex: "DEDEDE"))
                        .frame(height: 1)
                        .padding(.top, 15)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: — REAL WORKING BUTTONS
                        
                        // CONTACT US
                        Button(action: {
                            openEmail()
                        }) {
                            SettingsRow(icon: "contact", title: "Contact Us")
                        }
                        
                        // RATE APP
                        Button(action: {
                            rateApp()
                        }) {
                            SettingsRow(icon: "rate", title: "Rate App")
                        }
                        
                        // ✅ SUBSCRIPTION (Теперь работает)
                        Button(action: {
                            showPaywall = true
                        }) {
                            SettingsRow(icon: "subscription", title: "Subscription")
                        }
                        
                        // ✅ RESTORE (Теперь работает, открывает Paywall)
                        Button(action: {
                            showPaywall = true
                        }) {
                            SettingsRow(icon: "restore", title: "Restore Purchases")
                        }
                        
                        
                        // NAVIGATION PAGES
                        NavigationLink(destination: TermsOfUseView()) {
                            SettingsRow(icon: "terms", title: "Terms of Use")
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            SettingsRow(icon: "privacy", title: "Privacy Policy")
                        }
                        
                    }
                    .padding()
                }
            }
            .buttonStyle(.plain)
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            // ✅ 2. Открытие Paywall поверх настроек
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

extension SettingsView {
    
    // MARK: — CONTACT US
    func openEmail() {
        let email = "support@heartrateapp.com"
        let subject = "Support Request"
        
        let urlString = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}


// 2. INFO PAGE VIEW (Без изменений)
struct InfoPageView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @ViewBuilder let content: Content
    
    private var customNavBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Rectangle().fill(Color.clear).frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Rectangle()
                .fill(Color(hex: "DEDEDE"))
                .frame(height: 1)
                .padding(.top, 15)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}


// 3. TERMS OF USE (Без изменений)
struct TermsOfUseView: View {
    var body: some View {
        InfoPageView(title: "Terms of Use") {
            Text("Welcome to Heart Rate. By downloading or using this application, you agree to the following Terms of Use.")
            
            Text("1. Purpose of the App")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("Heart Rate is designed for wellness and informational purposes only. It allows you to estimate your heart rate using your device's camera. This app is not a medical device and should not be used for diagnosis or treatment of any health conditions.")
            
            Text("2. User Responsibility")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 8) {
                Text("• You use this app at your own discretion and risk.")
                Text("• You should always consult a qualified healthcare professional if you have concerns about your health.")
                Text("• Do not rely on this app as a substitute for professional medical advice.")
            }
            .padding(.leading, 10)
            
            Text("3. Permissions")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("The app requires access to your camera to measure your heart rate. No data is stored or shared. You may disable this permission at any time in your device settings.")
            
            Text("4. No Liability")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("We are not responsible for any direct or indirect damages, health issues, or consequences resulting from the use or inability to use this app. The app is provided \"as is\", without warranties of any kind.")
            
            Text("5. Intellectual Property")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("All content, design, and functionality of the app are the property of the app's creators.")
        }
        .font(.system(size: 16))
        .foregroundColor(Color(white: 0.2))
    }
}


// 4. PRIVACY POLICY (Без изменений)
struct PrivacyPolicyView: View {
    var body: some View {
        InfoPageView(title: "Privacy Policy") {
            Text("We value your privacy and are committed to protecting it. This Privacy Policy explains how Heart Rate handles your information.")
            
            Text("1. No Data Collection")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("We do not collect, store, or share any personal or usage data. All heart rate measurements are processed locally on your device and are never transmitted to our servers or any third parties.")
            
            Text("2. Camera Usage")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("The app uses your device's camera only to measure your heart rate. Camera access is required for this functionality, but no images, videos, or biometric data are recorded or stored.")
            
            Text("3. Third Parties")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("We do not use any third-party analytics, advertising, or tracking services.")
            
            Text("4. Security and Control")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("Because no data is collected, there is nothing stored on our servers. You can revoke camera permissions at any time through your device settings.")
            
            Text("5. Policy Changes")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 5)
            Text("If we ever make changes to this Privacy Policy, they will be updated on this page with a new effective date.")
        }
        .font(.system(size: 16))
        .foregroundColor(Color(white: 0.2))
    }
}

#Preview {
    SettingsView()
}
