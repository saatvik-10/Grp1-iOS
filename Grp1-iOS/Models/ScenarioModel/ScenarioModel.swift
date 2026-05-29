//
//  ScenarioModel.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/01/26.
//

import Foundation

struct GameState {
    var capital: Int
    var node: DecisionNode
    var biasScore: Int
    var biasExposure: [CognitiveBias: Int] = [:]
    var ending: EndingType?
}

struct KahnemanQuote {
    let text: String
    let author: String
    let endingType: EndingType
}

struct BiasDefine {
    let bias: CognitiveBias
    let title: String
    let description: String
    let iconName: String
}
