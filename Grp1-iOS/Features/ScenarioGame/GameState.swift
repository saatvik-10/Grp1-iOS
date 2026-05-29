//
//  GameState.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 27/01/26.
//

enum DecisionNode {
    case act1

    // Loyalist branch
    case loyalistFollowup
    case loyalistDoubleDown
    case loyalistTimeWillTell
    case loyalistExit
    case loyalistDoubleDownLoss

    // Pragmatist branch
    case pragmatistFollowup
    case pragmatistExit
    case pragmatistStay
    case pragmaticLoss

    case evPivot
    case evPivotLoss
    case evPivotProfit
    case evProfitBook
}

enum CognitiveBias: String {
    case lossAversion = "Loss Aversion"
    case sunkCost = "Sunk Cost Fallacy"
    case overconfidence = "Overconfidence"
    case statusQuo = "Status Quo Bias"
    case anchoring = "Anchoring"
    case adaptability = "Adaptability"
}

enum EndingType {
    case success
    case partialFailure
    case failure
    case criticalFailure
}
