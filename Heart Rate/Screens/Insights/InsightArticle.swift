//
//  InsightArticle.swift
//  Heart Rate
//
//  Created by Adlet Kanatbek on 11/12/25.
//


import SwiftUI

// 1. Модель данных (РАСШИРЕННАЯ и теперь Hashable)
struct InsightArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String     // Маленькая иконка для списка
    
    // --- Новые поля для детального экрана ---
    let heroImageName: String // Большое фото (название ассета)
    let articleText: String   // Полный текст статьи
    let sourceURL: String     // Ссылка на источник
}