import SwiftUI

struct ArticleDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    let article: InsightArticle
    
    // --- ✅ 1. КАСТОМНЫЙ NAV BAR (как на скриншоте) ---
    private var customNavBar: some View {
        VStack(spacing: 0) {
            HStack {
                // Кнопка "Назад"
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
                
                // Заголовок "Insights"
                Text("Insights")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Rectangle().fill(Color.clear).frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // ✅ 2. ПОЛОСА-РАЗДЕЛИТЕЛЬ
            Rectangle()
                .fill(Color(hex: "DEDEDE"))
                .frame(height: 1)
                .padding(.top, 15)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 3. ✅ ДОБАВИЛИ кастомный nav bar
                customNavBar
                
                Image(article.heroImageName)
                    .resizable()
                    .scaledToFit()            // НЕ обрезает
                    .frame(height: 220)       // ← фиксированная высота для всех
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                
                // 5. Контент
                VStack(alignment: .leading, spacing: 15) {
                    Text(article.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(article.articleText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black.opacity(0.8))
                        .lineSpacing(5)
                    
                    if let url = URL(string: article.sourceURL) {
                        Link("Source: \(article.sourceURL)", destination: url)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "F3547E"))
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .navigationBarHidden(true) // 6. ✅ Скрываем нативный nav bar
    }
}

#Preview {
    ArticleDetailView(
        article: .init(
            title: "What should my heart rate be?",
            imageName: "insight_1",
            heroImageName: "hero_1",
            articleText: "A normal resting heart rate for adults ranges from 60 to 100 beats per minute...",
            sourceURL: "https://www.mayoclinic.org"
        )
    )
}
