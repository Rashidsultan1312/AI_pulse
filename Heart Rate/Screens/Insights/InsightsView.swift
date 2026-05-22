import SwiftUI

// (Модель 'InsightArticle' должна быть в своем файле 'InsightArticle.swift')
// (Данные 'ArticleContent.articles' должны быть в своем файле 'ArticleContent.swift')

struct InsightsView: View {
    
    // Список статей
    private let articles: [InsightArticle] = ArticleContent.articles
    
    private let arrowColor = Color(hex: "F3547E")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 🔹 Информационный блок про источники
                VStack(alignment: .leading, spacing: 8) {
                    Text("About medical information")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("""
Each article in Insights is based on evidence-based medical sources: clinical guidelines, peer-reviewed studies, and trusted health organizations. At the end of every article you’ll find a “Sources” section with links to the research we used, so you can verify the information or read more.
""")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                // 🔹 Сами статьи
                ForEach(articles) { article in
                    NavigationLink(
                        destination: ArticleDetailView(article: article)
                    ) {
                        HStack(spacing: 16) {
                            Image(article.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)

                            Text(article.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(arrowColor)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
}
