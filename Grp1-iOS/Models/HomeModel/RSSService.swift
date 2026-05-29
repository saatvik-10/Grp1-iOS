//
//  RSSService.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation

extension String {
    func stripHTML() -> String {
        replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        .replacingOccurrences(of: "&nbsp;", with: " ")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class TOIRSSParser: NSObject, XMLParserDelegate {

    private var items: [RSSItem] = []
    private var currentItem: RSSItem?
    private var currentElement = ""
    private var buffer = ""

    func parse(data: Data) -> [RSSItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        buffer = ""

        if elementName == "item" {
            currentItem = RSSItem()
        }

        if elementName == "enclosure",
           let url = attributeDict["url"] {
            currentItem?.imageURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard currentItem != nil else { return }
        let value = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentItem?.title += value

        case "description":
            currentItem?.description += value.stripHTML()

        case "link":
            currentItem?.link += value

        case "pubDate":
            currentItem?.pubDate += value

        case "item":
            if let item = currentItem {
                items.append(item)
            }
            currentItem = nil

        default:
            break
        }
    }
}

final class RSSService {

    static let shared = RSSService()
    private init() {}

    private let toiRSSURL =
        "https://timesofindia.indiatimes.com/rssfeeds/1898055.cms"

    func fetchTOINews(completion: @escaping ([RSSItem]) -> Void) {

        guard let url = URL(string: toiRSSURL) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }

            let parser = TOIRSSParser()
            let items = parser.parse(data: data)

            DispatchQueue.main.async {
                completion(items)
            }
        }.resume()
    }
}

// MARK: - Article Content Service

final class ArticleContentService {

    static let shared = ArticleContentService()
    private init() {}

    func fetchArticleHTML(
        from urlString: String,
        completion: @escaping (String?) -> Void
    ) {
        print("🌐 Fetching article from URL:")
            print(urlString)
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  error == nil,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                completion(html)
            }
        }.resume()
    }
}

extension String {

    func extractTOIArticleBody(minWords: Int = 12) -> String {

        var results: [String] = []
        var isInsideArticle = false
        var isInsideScript = false

        let tokens = self.components(separatedBy: "<")

        for token in tokens {

            let lower = token.lowercased()

            if lower.contains("data-articlebody") {
                isInsideArticle = true
                continue
            }

//            if isInsideArticle && lower.hasPrefix("p") {
//                break
//            }

            if lower.hasPrefix("script") {
                isInsideScript = true
                continue
            }

            if lower.hasPrefix("/script") {
                isInsideScript = false
                continue
            }

            if !isInsideArticle || isInsideScript {
                continue
            }

            guard let textPart = token.split(separator: ">", maxSplits: 1).last else {
                continue
            }

            let cleaned = String(textPart)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let wordCount = cleaned.split(separator: " ").count
            guard wordCount >= minWords else { continue }

            guard cleaned.range(of: "[{};=<>]", options: .regularExpression) == nil else {
                continue
            }

            results.append(cleaned)
        }

        return results.joined(separator: "\n\n")
    }
}
