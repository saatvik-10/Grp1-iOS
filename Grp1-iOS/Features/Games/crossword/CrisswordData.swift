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

    // 4 Letters
    CrosswordData(name: "BANK", clue: "Financial institution"),
    CrosswordData(name: "CASH", clue: "Physical money"),
    CrosswordData(name: "DEBT", clue: "Money owed"),
    CrosswordData(name: "LOAN", clue: "Borrowed money"),
    CrosswordData(name: "BOND", clue: "Debt security"),
    CrosswordData(name: "FUND", clue: "Pool of investments"),
    CrosswordData(name: "RATE", clue: "Interest percentage"),
    CrosswordData(name: "RISK", clue: "Chance of loss"),
    CrosswordData(name: "GAIN", clue: "Increase in value"),
    CrosswordData(name: "LOSS", clue: "Decrease in value"),
    CrosswordData(name: "COST", clue: "Amount paid"),
    CrosswordData(name: "SALE", clue: "Exchange for money"),
    CrosswordData(name: "WAGE", clue: "Payment for labor"),
    CrosswordData(name: "BULL", clue: "Rising market trend"),
    CrosswordData(name: "BEAR", clue: "Falling market trend"),

    // 5 Letters
    CrosswordData(name: "ASSET", clue: "Valuable resource"),
    CrosswordData(name: "STOCK", clue: "Ownership share"),
    CrosswordData(name: "TRADE", clue: "Buying and selling"),
    CrosswordData(name: "VALUE", clue: "Worth of something"),
    CrosswordData(name: "PRICE", clue: "Amount charged"),
    CrosswordData(name: "MONEY", clue: "Medium of exchange"),
    CrosswordData(name: "LEASE", clue: "Rental contract"),
    CrosswordData(name: "YIELD", clue: "Investment return"),
    CrosswordData(name: "INDEX", clue: "Market benchmark"),
    CrosswordData(name: "SHARE", clue: "Unit of ownership"),
    CrosswordData(name: "AUDIT", clue: "Financial review"),
    CrosswordData(name: "CHECK", clue: "Written payment order"),
    CrosswordData(name: "REPAY", clue: "Pay back a debt"),
    CrosswordData(name: "SPEND", clue: "Use money"),
    CrosswordData(name: "SAVER", clue: "One who saves money"),

    // 6 Letters
    CrosswordData(name: "INCOME", clue: "Money earned"),
    CrosswordData(name: "MARKET", clue: "Trading place"),
    CrosswordData(name: "EQUITY", clue: "Ownership interest"),
    CrosswordData(name: "BUDGET", clue: "Spending plan"),
    CrosswordData(name: "RETURN", clue: "Investment profit"),
    CrosswordData(name: "LIQUID", clue: "Easy to convert to cash"),
    CrosswordData(name: "INSURE", clue: "Protect from loss"),
    CrosswordData(name: "SALARY", clue: "Regular pay"),
    CrosswordData(name: "BROKER", clue: "Trade intermediary"),
    CrosswordData(name: "CREDIT", clue: "Borrowing ability"),
    CrosswordData(name: "EXPORT", clue: "Sell abroad"),
    CrosswordData(name: "IMPORT", clue: "Buy from abroad"),
    CrosswordData(name: "MARGIN", clue: "Difference in value"),
    CrosswordData(name: "WEALTH", clue: "Accumulated assets"),
    CrosswordData(name: "REWARD", clue: "Financial benefit"),

    // 7 Letters
    CrosswordData(name: "FINANCE", clue: "Management of money"),
    CrosswordData(name: "CAPITAL", clue: "Investment wealth"),
    CrosswordData(name: "BALANCE", clue: "Account total"),
    CrosswordData(name: "BANKING", clue: "Financial services"),
    CrosswordData(name: "SAVINGS", clue: "Money set aside"),
    CrosswordData(name: "PAYMENT", clue: "Transfer of funds"),
    CrosswordData(name: "ACCOUNT", clue: "Financial record"),
    CrosswordData(name: "REVENUE", clue: "Business income"),
    CrosswordData(name: "EXPENSE", clue: "Money spent"),
    CrosswordData(name: "SURPLUS", clue: "Excess funds"),
    CrosswordData(name: "DEFICIT", clue: "Funding shortfall"),
    CrosswordData(name: "LENDING", clue: "Providing loans"),
    CrosswordData(name: "PAYROLL", clue: "Employee compensation"),
    CrosswordData(name: "TRADING", clue: "Buying and selling assets"),
    CrosswordData(name: "TARIFFS", clue: "Import taxes"),
    CrosswordData(name: "PREMIUM", clue: "Insurance payment"),
    CrosswordData(name: "PAYABLE", clue: "Amount owed"),
    CrosswordData(name: "RECEIPT", clue: "Proof of payment"),
    CrosswordData(name: "VOUCHER", clue: "Document of value"),
    CrosswordData(name: "TURNOVER", clue: "Business sales volume"),

    // 8 Letters
    CrosswordData(name: "INVESTOR", clue: "Person who invests"),
    CrosswordData(name: "SECURITY", clue: "Tradable asset"),
    CrosswordData(name: "ECONOMY", clue: "System of trade"),
    CrosswordData(name: "MORTGAGE", clue: "Property loan"),
    CrosswordData(name: "DIVIDEND", clue: "Shareholder payout"),
    CrosswordData(name: "INTEREST", clue: "Cost of borrowing"),
    CrosswordData(name: "TREASURY", clue: "Government funds"),
    CrosswordData(name: "CURRENCY", clue: "Official money"),
    CrosswordData(name: "EARNINGS", clue: "Profits made"),
    CrosswordData(name: "PROPERTY", clue: "Real estate asset"),
    CrosswordData(name: "HOLDINGS", clue: "Owned investments"),
    CrosswordData(name: "DEPOSITS", clue: "Money in bank"),
    CrosswordData(name: "TAXPAYER", clue: "One who pays taxes"),
    CrosswordData(name: "VENTURES", clue: "Business projects"),
    CrosswordData(name: "MERCHANT", clue: "Seller of goods"),
    CrosswordData(name: "BUSINESS", clue: "Commercial activity"),
    CrosswordData(name: "RECEIPTS", clue: "Records of payment"),
    CrosswordData(name: "FINTECHS", clue: "Finance technology firms"),
    CrosswordData(name: "MONETARY", clue: "Related to money"),
    CrosswordData(name: "RESERVES", clue: "Funds set aside"),
    CrosswordData(name: "INVOICES", clue: "Bills for payment"),
    CrosswordData(name: "TAXATION", clue: "Collection of taxes"),
    CrosswordData(name: "CAPGAINS", clue: "Profits from investments"),
    CrosswordData(name: "CUSTODIA", clue: "Asset safekeeping"),
    CrosswordData(name: "DEMANDER", clue: "One seeking goods"),
    CrosswordData(name: "SUPPLIER", clue: "Provider of goods"),
    CrosswordData(name: "CREDITOR", clue: "One who lends money"),
    CrosswordData(name: "DEBTORSS", clue: "People who owe money"),
    CrosswordData(name: "VALUABLE", clue: "Having high worth"),
    CrosswordData(name: "INSURERS", clue: "Insurance companies"),
    CrosswordData(name: "BALANCES", clue: "Account totals"),
    CrosswordData(name: "PROFITSX", clue: "Financial gains"),
    CrosswordData(name: "ECONOMIC", clue: "Related to economy"),
    CrosswordData(name: "FINANCED", clue: "Provided funding")
]
