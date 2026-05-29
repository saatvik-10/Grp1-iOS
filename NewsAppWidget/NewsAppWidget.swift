//
//  NewsWidget.swift
//  NewsAppWidget
//

import WidgetKit
import SwiftUI

// MARK: - Shared Model (must match what main app writes to shared UserDefaults)

struct WidgetArticle: Codable {
    let title: String
    let source: String
    let relevanceScore: Double
}

// MARK: - Timeline Entry

struct NewsEntry: TimelineEntry {
    let date: Date
    let articles: [WidgetArticle]
}

// MARK: - Provider

struct NewsProvider: TimelineProvider {

    private let suiteName = "group.grp1.project"   // ✅ must match your App Group ID
    private let key       = "widget_articles"

    func placeholder(in context: Context) -> NewsEntry {
        NewsEntry(date: .now, articles: [
            WidgetArticle(title: "Markets rise on strong earnings data", source: "Economic Times", relevanceScore: 47),
            WidgetArticle(title: "RBI holds repo rate steady", source: "LiveMint", relevanceScore: 38)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> Void) {
        completion(NewsEntry(date: .now, articles: loadArticles()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> Void) {
        let entry = NewsEntry(date: .now, articles: loadArticles())
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadArticles() -> [WidgetArticle] {
        guard
            let defaults = UserDefaults(suiteName: suiteName),
            let data     = defaults.data(forKey: key),
            let articles = try? JSONDecoder().decode([WidgetArticle].self, from: data)
        else { return [] }
        return articles
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: NewsEntry

    var body: some View {
        if let article = entry.articles.first {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.source.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)

                Text(article.title)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(4)
                    .foregroundColor(.primary)

                Spacer()

                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 10))
                    Text("Score \(Int(article.relevanceScore))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "newspaper")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
                Text("Open app to\nload news")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: NewsEntry

    var body: some View {
        if entry.articles.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "newspaper")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
                Text("Open app to load news")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(entry.articles.prefix(3).enumerated()), id: \.offset) { index, article in
                    HStack(alignment: .top, spacing: 10) {

                        // Rank number
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(index == 0 ? .orange : .secondary)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(article.source.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(article.title)
                                .font(.system(size: 13, weight: index == 0 ? .bold : .regular))
                                .lineLimit(2)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        Text("\(Int(article.relevanceScore))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 6)

                    if index < min(entry.articles.count, 3) - 1 {
                        Divider()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Entry View (switches based on family)

struct NewsWidgetEntryView: View {
    var entry: NewsEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget (no @main here — bundle handles that)

struct NewsWidget: Widget {
    let kind = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NewsProvider()) { entry in
            NewsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Top News")
        .description("Shows your most relevant news based on your interests.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
