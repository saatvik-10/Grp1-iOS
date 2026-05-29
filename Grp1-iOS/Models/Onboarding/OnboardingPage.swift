//
//  OnboardingPage.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//
import Foundation

struct OnboardingPage {
    let title: String
    let options: [(title: String, subtitle: String)]
}

struct OnboardingInterestModel {
    let icon: String?
    let title: String
    let subtitle: String
}
var preferences: [OnboardingInterestModel] = [
    OnboardingInterestModel(icon: "chart.line.uptrend.xyaxis", title: "Stock Market", subtitle: ""),
    OnboardingInterestModel(icon: "bitcoinsign", title: "Crypto", subtitle: ""),
    OnboardingInterestModel(icon: "building.2", title: "Real Estate", subtitle: ""),
    OnboardingInterestModel(icon: "cpu", title: "Tech Sector", subtitle: ""),
    OnboardingInterestModel(icon: "cylinder", title: "Commodities", subtitle: ""),
    OnboardingInterestModel(icon: "leaf", title: "Sustainability", subtitle: "")

]

struct DomainModel {
    let icon: String?
    let title: String
}
var domains: [DomainModel] = [
    DomainModel(icon: "chart.line.uptrend.xyaxis", title: "Stocks"),
    DomainModel(icon: "building.columns", title: "Mutual Funds"),
    DomainModel(icon: "bitcoinsign.circle", title: "Crypto"),
    DomainModel(icon: "globe", title: "Macroeconomy"),
    DomainModel(icon: "banknote", title: "Banking"),
    DomainModel(icon: "cube.box", title: "Commodities")
]
