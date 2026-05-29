//
//  NewsWidget.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 09/03/26.
//

import WidgetKit
import SwiftUI

struct NewsEntry: TimelineEntry {
    let date: Date
    let articles: [WidgetArticle]
}

struct WidgetArticle: Codable {
    let title: String
    let source: String
    let imageName: String
    let relevanceScore: Double
}

struct NewsProvider: TimelineProvider {

    func placeholder(in context: Context) -> NewsEntry {
        NewsEntry(date: .now, articles: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> Void) {
        completion(NewsEntry(date: .now, articles: loadArticles()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> Void) {
        let entry = NewsEntry(date: .now, articles: loadArticles())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadArticles() -> [WidgetArticle] {
        guard
            let data = UserDefaults(suiteName: "group.com.yourcompany.newsapp")?
                .data(forKey: "widget_articles"),
            let articles = try? JSONDecoder().decode([WidgetArticle].self, from: data)
        else { return [] }
        return articles
    }
}

struct NewsWidgetEntryView: View {
    var entry: NewsEntry

    var body: some View {
        if let top = entry.articles.first {
            VStack(alignment: .leading, spacing: 4) {
                Text(top.source.uppercased())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(top.title)
                    .font(.headline)
                    .lineLimit(3)
                Spacer()
                Text("Score: \(Int(top.relevanceScore))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else {
            Text("Loading news...")
                .padding()
        }
    }
}

struct NewsWidget: Widget {
    let kind = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NewsProvider()) { entry in
            NewsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Top News")
        .description("Shows your most relevant news.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
