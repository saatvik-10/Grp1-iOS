import Foundation

struct RealityScenario: Codable {
    let id: String
    let type: String
    let meta: ScenarioMeta // Reusing from Model1
    let events: [RealityEvent]
    let summary: RealitySummary
}

struct RealityEvent: Codable {
    let id: String
    let title: String
    let messages: [String]
    let question: String
    let stateKey: String
    let options: [EventOption]
}

struct EventOption: Codable {
    let id: String
    let text: String
}

struct RealitySummary: Codable {
    let title: String
    let stats: [SummaryStat]
    let finalQuestion: String
    let stateKey: String
    let finalOptions: [EventOption]
}

struct SummaryStat: Codable {
    let label: String
    let value: String
}
