//
//  PuzzleGenerator.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 13/05/26.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Built-in fictional company pool (used when AI is unavailable)

private let companyPool: [String: [(name: String, desc: String)]] = [
    "IT/Software": [
        ("Zenlogic Infotech", "Enterprise cloud solutions provider"),
        ("Nexvista Technologies", "AI-driven SaaS platform company"),
        ("CodeMatrix Systems", "Full-stack digital transformation firm"),
        ("Riviera Softlabs", "B2B analytics and automation suite"),
        ("Optiqon Digital", "Mobile-first product engineering company"),
        ("Infotrek Solutions", "IT consulting and managed services"),
        ("CloudNest Technologies", "Hybrid cloud infrastructure provider"),
        ("PixelBridge Software", "UI/UX design and frontend engineering")
    ],
    "FMCG": [
        ("DailyBite Consumer", "Packaged snacks and beverages brand"),
        ("PureGlow Naturals", "Organic personal care products maker"),
        ("FreshCart Industries", "Ready-to-eat meals and grocery staples"),
        ("UrbanHarvest Foods", "Health-focused processed food company"),
        ("KisanPure Products", "Farm-to-table FMCG distributor"),
        ("TrueSpice India", "Spices and condiments manufacturer"),
        ("VitaNest Consumer", "Nutrition supplements and wellness brand"),
        ("GreenLeaf Essentials", "Eco-friendly household products maker")
    ],
    "Banking/NBFC": [
        ("TrustVault Finance", "Retail and MSME lending institution"),
        ("Pinnacle Credit Corp", "Vehicle and gold loan NBFC"),
        ("EquiGrowth Bank", "Small finance bank for rural markets"),
        ("CapitalBridge NBFC", "Microfinance and group lending arm"),
        ("PrimeEdge Finance", "Consumer durables financing company"),
        ("SilverArc Capital", "Housing finance and mortgage lender"),
        ("SwiftLend Financial", "Digital-first personal loan platform"),
        ("MeridianBank India", "Full-service private sector bank")
    ],
    "Pharma": [
        ("MediGenix Pharma", "Generic formulations and API exporter"),
        ("CureNova Life Sciences", "Oncology-focused drug developer"),
        ("VitalChem Labs", "Contract research and manufacturing org"),
        ("PharmaEdge Biotech", "Biosimilar and vaccine producer"),
        ("NeoSynth Healthcare", "Specialty APIs and intermediates"),
        ("AyuVeda Naturals", "Ayurvedic and herbal medicine maker"),
        ("HealTech Pharmaceuticals", "Generic medicines manufacturer"),
        ("LifePlus Biomedics", "Medical devices and diagnostics")
    ],
    "Infrastructure/Capital Goods": [
        ("BuildWell Infra", "Highway and bridge EPC contractor"),
        ("SteelRise Engineering", "Heavy fabrication and structural steel"),
        ("CoreMech Industries", "Industrial turbine and boiler maker"),
        ("MetroLink Projects", "Urban metro rail system integrator"),
        ("FoundEdge Construction", "Real estate and township developer"),
        ("PowerGrid Technics", "Transmission tower and substation builder"),
        ("AquaBuild Infrastructure", "Water treatment and pipeline projects"),
        ("SkyHigh Constructions", "Commercial real estate developer")
    ]
]

// MARK: - Template explanations (used when AI is unavailable)

private let explanationTemplates: [String] = [
    "Strong margins and consistent growth drove compounding returns.",
    "Superior capital efficiency and low debt positioned this company to outperform peers in the sector.",
    "A combination of high revenue growth and lean operations gave this company a clear edge over competitors.",
    "Consistent earnings growth paired with disciplined capital allocation made this the top pick in the sector.",
    "Better-than-average profitability metrics and a favorable valuation made this the strongest performer.",
    "Efficient asset utilization and strong cash flows resulted in sector-leading total returns."
]

@available(iOS 26.0, *)
class PuzzleGenerator {
    static let shared = PuzzleGenerator()
    
    /// Generates a fresh DailyPuzzle. Uses on-device AI for company names/explanations
    /// when available; otherwise falls back to a built-in pool. Always returns a valid puzzle.
    func generate() async -> DailyPuzzle? {
        let sectors = ["IT/Software", "FMCG", "Banking/NBFC", "Pharma", "Infrastructure/Capital Goods"]
        let sector = sectors.randomElement()!
        
        // ── Step 1: Get company names ──────────────────────────
        var generatedCompanies = getCompaniesFromPool(sector: sector)
        
        #if canImport(FoundationModels)
        if SystemLanguageModel.default.isAvailable {
            if let aiCompanies = await generateCompaniesWithAI(sector: sector) {
                generatedCompanies = aiCompanies
            }
        }
        #endif
        
        // ── Step 2–3: Engine generates base variables + derives indicators ──
        let engineData = PuzzleEngine.generatePuzzleData(for: sector)
        
        var companies: [Company] = []
        var visibleIndicators: [IndicatorValue] = []
        var twistIndicators: [IndicatorValue] = []
        var results: [Result1] = []
        
        let pillars: [Pillar] = [.growthConsistency, .financialStrength, .debtLevels, .valuation]
        
        let growthNames = ["Revenue Growth YoY", "EPS Growth (YoY)", "5Y Sales CAGR", "5Y Profit CAGR", "Operating CF Growth"]
        let finNames = ["Net Profit Margin", "Return on Equity", "Return on Capital Employed", "Operating Margin", "Asset Turnover"]
        let debtNames = ["Debt-to-Equity", "Interest Coverage", "Debt-to-EBITDA", "Current Ratio", "FCF-to-Debt"]
        let valNames = ["P/E Ratio", "Price-to-Book", "EV/EBITDA", "Price-to-Sales", "PEG Ratio"]
        
        // Pick 1 visible + 1 twist per pillar (shuffle then take first two)
        let selectedGrowth = Array(growthNames.shuffled().prefix(2))
        let selectedFin = Array(finNames.shuffled().prefix(2))
        let selectedDebt = Array(debtNames.shuffled().prefix(2))
        let selectedVal = Array(valNames.shuffled().prefix(2))
        
        let twistPillar = pillars.randomElement()!
        
        var selectedVisibleNames: [Pillar: String] = [:]
        selectedVisibleNames[.growthConsistency] = selectedGrowth[0]
        selectedVisibleNames[.financialStrength] = selectedFin[0]
        selectedVisibleNames[.debtLevels] = selectedDebt[0]
        selectedVisibleNames[.valuation] = selectedVal[0]
        
        // Twist must be from the same pillar but a different indicator
        var twistName = ""
        switch twistPillar {
        case .growthConsistency: twistName = selectedGrowth[1]
        case .financialStrength: twistName = selectedFin[1]
        case .debtLevels: twistName = selectedDebt[1]
        case .valuation: twistName = selectedVal[1]
        }
        
        // ── Step 4: Score, rank, assign returns ──────────────────
        var bestCompanyId = ""
        var bestCompanyReturn = 0
        var bestCompanyData: PuzzleEngine.GeneratedCompanyData? = nil
        var bestCompanyName = ""
        
        for (i, data) in engineData.enumerated() {
            let rank = i + 1
            let retPct = PuzzleEngine.getReturnPercent(forRank: rank)
            let companyId = "c\(i+1)"
            let comp = Company(id: companyId, name: generatedCompanies[i].name, description: generatedCompanies[i].desc)
            companies.append(comp)
            
            if rank == 1 {
                bestCompanyId = companyId
                bestCompanyReturn = retPct
                bestCompanyData = data
                bestCompanyName = comp.name
            }
            
            for pillar in pillars {
                let indName = selectedVisibleNames[pillar]!
                let val = data.indicators[indName] ?? 0.0
                visibleIndicators.append(IndicatorValue(
                    indicatorName: indName, pillar: pillar,
                    companyId: companyId,
                    displayValue: PuzzleEngine.formatIndicatorValue(indName, value: val)
                ))
            }
            
            let tVal = data.indicators[twistName] ?? 0.0
            twistIndicators.append(IndicatorValue(
                indicatorName: twistName, pillar: twistPillar,
                companyId: companyId,
                displayValue: PuzzleEngine.formatIndicatorValue(twistName, value: tVal)
            ))
            
            results.append(Result1(companyId: companyId, returnPercent: retPct, explanation: ""))
        }
        
        // ── Step 5: Generate explanation ──────────────────────────
        var bestExplanation = explanationTemplates.randomElement() ?? "Strong fundamentals across the board."
        
        #if canImport(FoundationModels)
        if SystemLanguageModel.default.isAvailable, let bData = bestCompanyData {
            if let aiExpl = await generateExplanationWithAI(
                companyName: bestCompanyName, sector: sector, returnPct: bestCompanyReturn,
                visibleNames: selectedVisibleNames, twistName: twistName, data: bData
            ) {
                bestExplanation = aiExpl
            }
        }
        #endif
        
        var finalResults: [Result1] = []
        for r in results {
            if r.companyId == bestCompanyId {
                finalResults.append(Result1(
                    companyId: r.companyId, returnPercent: r.returnPercent,
                    explanation: bestExplanation.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                ))
            } else {
                finalResults.append(Result1(
                    companyId: r.companyId, returnPercent: r.returnPercent,
                    explanation: "Did not perform optimally compared to sector peers."
                ))
            }
        }
        
        let puzzle = DailyPuzzle(
            sector: sector, companies: companies.shuffled(),
            visibleIndicators: visibleIndicators,
            twistIndicators: twistIndicators,
            results: finalResults
        )
        
        saveToCache(puzzle)
        return puzzle
    }
    
    // MARK: - Offline fallback: pick 4 random companies from the pool
    
    private func getCompaniesFromPool(sector: String) -> [(name: String, desc: String)] {
        let pool = companyPool[sector] ?? companyPool["IT/Software"]!
        return Array(pool.shuffled().prefix(4))
    }
    
    // MARK: - AI helpers (only called when FoundationModels is available)
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateCompaniesWithAI(sector: String) async -> [(name: String, desc: String)]? {
        let prompt = """
        Generate 4 fictional Indian company names that sound like BSE/NSE-listed companies but are not real, for the \(sector) sector. Provide a one-line business description for each.
        Output EXACTLY 4 lines, formatted exactly as:
        CompanyName|Description
        Do not output any other text or markdown.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            let text = String(describing: response.content)
            let lines = text.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            var result: [(name: String, desc: String)] = []
            for line in lines {
                let parts = line.components(separatedBy: "|")
                if parts.count >= 2 {
                    result.append((
                        name: parts[0].trimmingCharacters(in: .whitespaces),
                        desc: parts[1].trimmingCharacters(in: .whitespaces)
                    ))
                }
            }
            return result.count >= 4 ? Array(result.prefix(4)) : nil
        } catch {
            print("⚠️ AI company generation failed (using pool): \(error)")
            return nil
        }
    }
    
    @available(iOS 26.0, *)
    private func generateExplanationWithAI(
        companyName: String, sector: String, returnPct: Int,
        visibleNames: [Pillar: String], twistName: String,
        data: PuzzleEngine.GeneratedCompanyData
    ) async -> String? {
        let prompt = """
        You are a financial analyst. The company '\(companyName)' in the '\(sector)' sector generated a \(returnPct)% return.
        Its key metrics were:
        \(visibleNames[.growthConsistency]!): \(PuzzleEngine.formatIndicatorValue(visibleNames[.growthConsistency]!, value: data.indicators[visibleNames[.growthConsistency]!] ?? 0.0))
        \(visibleNames[.financialStrength]!): \(PuzzleEngine.formatIndicatorValue(visibleNames[.financialStrength]!, value: data.indicators[visibleNames[.financialStrength]!] ?? 0.0))
        \(visibleNames[.debtLevels]!): \(PuzzleEngine.formatIndicatorValue(visibleNames[.debtLevels]!, value: data.indicators[visibleNames[.debtLevels]!] ?? 0.0))
        \(visibleNames[.valuation]!): \(PuzzleEngine.formatIndicatorValue(visibleNames[.valuation]!, value: data.indicators[visibleNames[.valuation]!] ?? 0.0))
        Twist indicator - \(twistName): \(PuzzleEngine.formatIndicatorValue(twistName, value: data.indicators[twistName] ?? 0.0))
        
        Provide a 2-3 sentence plain-English explanation of why it outperformed peers based on these metrics.
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return String(describing: response.content)
        } catch {
            print("⚠️ AI explanation generation failed (using template): \(error)")
            return nil
        }
    }
    #endif
    
    // MARK: - Cache
    
    private func saveToCache(_ puzzle: DailyPuzzle) {
        let fileManager = FileManager.default
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = cacheURL.appendingPathComponent("generated_puzzle.json")
            do {
                let data = try JSONEncoder().encode(puzzle)
                try data.write(to: fileURL)
                print("✅ Saved puzzle to cache: \(fileURL)")
            } catch {
                print("❌ Failed to save puzzle to cache: \(error)")
            }
        }
    }
}
