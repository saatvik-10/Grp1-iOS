//
//  CrisswordData.swift
//  IOS-App
//
//  Created by SDC-USER on 29/01/26.
//
//
//  FinanceData.swift
//  IOS-App
//
//  Created by SDC-USER on 14/01/26.
//

import Foundation

public struct CrosswordData {
    let name: String
    let clue: String
}

let financeData: [CrosswordData] = [

    // 4-letter finance terms
    CrosswordData(name: "LOAN", clue: "Money borrowed and repaid with interest"),
    CrosswordData(name: "TAXS", clue: "Government charges on income or goods"),
    CrosswordData(name: "BOND", clue: "Debt investment with fixed returns"),
    CrosswordData(name: "CASH", clue: "Physical money"),
    CrosswordData(name: "BANK", clue: "Financial institution"),
    CrosswordData(name: "RATE", clue: "Interest percentage"),
    CrosswordData(name: "DEBT", clue: "Money owed"),
    CrosswordData(name: "FUND", clue: "Pooled investment money"),

    // 5-letter finance terms
    CrosswordData(name: "ASSET", clue: "Something valuable owned"),
    CrosswordData(name: "STOCK", clue: "Company ownership share"),
    CrosswordData(name: "CREDIT", clue: "Borrowing capacity"),
    CrosswordData(name: "PROFIT", clue: "Financial gain"),
    CrosswordData(name: "TRADE", clue: "Buying and selling activity"),
    CrosswordData(name: "VALUE", clue: "Worth of an investment"),
    CrosswordData(name: "SAVES", clue: "Money set aside"),
    CrosswordData(name: "SPEND", clue: "Use money to buy"),

    // 6-letter finance terms
    CrosswordData(name: "INCOME", clue: "Money earned"),
    CrosswordData(name: "MARKET", clue: "Place for buying and selling"),
    CrosswordData(name: "EQUITY", clue: "Ownership interest"),
    CrosswordData(name: "BUDGET", clue: "Planned spending"),
    CrosswordData(name: "RETURN", clue: "Profit from an investment"),
    CrosswordData(name: "LIQUID", clue: "Easy to convert into cash"),
    CrosswordData(name: "FINALS", clue: "Closing accounts period"),
    CrosswordData(name: "INSURE", clue: "Protect against loss"),

    // 7-letter finance terms
    CrosswordData(name: "FINANCE", clue: "Management of money"),
    CrosswordData(name: "CAPITAL", clue: "Wealth used for investment"),
    CrosswordData(name: "BALANCE", clue: "Amount remaining in account"),
    CrosswordData(name: "INTEREST", clue: "Cost of borrowing money"),
    CrosswordData(name: "DIVIDEND", clue: "Company profit paid to shareholders"),
    CrosswordData(name: "MORTGAG", clue: "Home loan (short form)"),
    CrosswordData(name: "BANKING", clue: "Financial services industry"),

    // 8-letter finance terms
    CrosswordData(name: "INFLATION", clue: "Rising prices over time"),
    CrosswordData(name: "PORTFOLIO", clue: "Collection of investments"),
    CrosswordData(name: "ECONOMY", clue: "System of money and trade"),
    CrosswordData(name: "SECURITY", clue: "Tradable financial asset"),
    CrosswordData(name: "INVESTOR", clue: "Person who puts money to grow")
]
