//
//  MintRSSService.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 05/03/26.
//

import Foundation

// MARK: - Mint RSS Parser

final class MintRSSParser: NSObject, XMLParserDelegate {

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

        // Mint uses <media:content url="..." /> for images
        if elementName == "media:content",
           let url = attributeDict["url"],
           currentItem?.imageURL.isEmpty == true {
            currentItem?.imageURL = url
        }

        // Fallback: <enclosure url="..." /> (same as TOI)
        if elementName == "enclosure",
           let url = attributeDict["url"],
           currentItem?.imageURL.isEmpty == true {
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

// MARK: - Mint RSS Service

final class MintRSSService {

    static let shared = MintRSSService()
    private init() {}

    private let mintRSSURL = "https://www.livemint.com/rss/markets"

    func fetchMintNews(completion: @escaping ([RSSItem]) -> Void) {

        guard let url = URL(string: mintRSSURL) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }

            let parser = MintRSSParser()
            let items = parser.parse(data: data)

            DispatchQueue.main.async {
                completion(items)
            }
        }.resume()
    }
}

extension String {

    func extractMintArticleBody(minWords: Int = 12) -> String {
        var results: [String] = []
        var isInsideArticle = false
        var isInsideScript = false
        var isInsideStyle = false

        let tokens = components(separatedBy: "<")

        for token in tokens {
            let lower = token.lowercased()
            let cleanup = MintHTMLCleanup(lower: lower)

            if cleanup.isArticleBodyMarker {
                isInsideArticle = true
                continue
            }

            if isInsideArticle && cleanup.isStopMarker { break }

            let isTagClosed = lower.hasPrefix("/")
            if lower.hasPrefix("script") || lower.hasPrefix("/script") {
                isInsideScript = !isTagClosed
                continue
            }
            if lower.hasPrefix("style") || lower.hasPrefix("/style") {
                isInsideStyle = !isTagClosed
                continue
            }

            if !isInsideArticle || isInsideScript || isInsideStyle { continue }

            guard let textPart = token.split(separator: ">", maxSplits: 1).last else {
                continue
            }

            let cleaned = String(textPart)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#8217;", with: "'")
                .replacingOccurrences(of: "&#8216;", with: "'")
                .replacingOccurrences(of: "&#8220;", with: "\"")
                .replacingOccurrences(of: "&#8221;", with: "\"")
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

private struct MintHTMLCleanup {
    let lower: String

    var isArticleBodyMarker: Bool {
        lower.contains("itemprop=\"articlebody\"")
            || lower.contains("class=\"storydetailssec\"")
            || lower.contains("class=\"storycontent\"")
            || lower.contains("class=\"contentsec\"")
            || lower.contains("data-articlebody")
    }

    var isStopMarker: Bool {
        lower.contains("class=\"also-read\"")
            || lower.contains("class=\"tagsection\"")
            || lower.contains("class=\"disclaimer\"")
    }
}
