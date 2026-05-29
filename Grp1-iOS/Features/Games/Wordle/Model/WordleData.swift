import Foundation

struct WordleItem {
    let word: String
    let hints: [String]
    let definition: String
}
// swiftlint:disable:next type_body_length
struct WordleData {
    static let items: [WordleItem] = [

        WordleItem(
            word: "BANK",
            hints: [
                "A place where people store and manage money.",
                "Offers accounts, loans, and financial services daily."
            ],
            definition: "A financial institution that accepts deposits and provides loans."
        ),

        WordleItem(
            word: "CASH",
            hints: [
                "The most liquid form of money available.",
                "Used immediately for purchases without conversion required."
            ],
            definition: "Physical currency and readily available funds."
        ),

        WordleItem(
            word: "LOAN",
            hints: [
                "Money borrowed today and repaid over time.",
                "Usually requires additional interest payments from borrower."
            ],
            definition: "Money borrowed with an agreement to repay."
        ),

        WordleItem(
            word: "DEBT",
            hints: [
                "Money owed by one person or organization.",
                "Created when funds are borrowed from others."
            ],
            definition: "An obligation to repay borrowed money."
        ),

        WordleItem(
            word: "PRICE",
            hints: [
                "The amount paid to obtain a product.",
                "Changes according to supply and demand forces."
            ],
            definition: "The monetary value assigned to something."
        ),

        WordleItem(
            word: "TRADE",
            hints: [
                "Exchange of goods, services, or financial assets.",
                "Occurs between buyers and sellers in markets."
            ],
            definition: "The act of buying and selling."
        ),

        WordleItem(
            word: "STOCK",
            hints: [
                "Represents ownership in a publicly listed company.",
                "Investors purchase these seeking long-term growth."
            ],
            definition: "A share of ownership in a corporation."
        ),

        WordleItem(
            word: "BOND",
            hints: [
                "A common investment that pays regular interest.",
                "Governments often issue these to raise funds."
            ],
            definition: "A debt security issued to investors."
        ),

        WordleItem(
            word: "ASSET",
            hints: [
                "Something valuable owned by an individual or company.",
                "Can include cash, property, equipment, or investments."
            ],
            definition: "A resource with economic value."
        ),

        WordleItem(
            word: "VALUE",
            hints: [
                "Represents how much something is worth financially.",
                "Investors constantly attempt to estimate this accurately."
            ],
            definition: "The worth of an asset or investment."
        ),

        WordleItem(
            word: "PROFIT",
            hints: [
                "Money remaining after all costs are deducted.",
                "Businesses strive to increase this every year."
            ],
            definition: "Financial gain after expenses are paid."
        ),

        WordleItem(
            word: "LOSS",
            hints: [
                "Occurs when expenses exceed revenue or income.",
                "Investors try to minimize this whenever possible."
            ],
            definition: "A negative financial result."
        ),

        WordleItem(
            word: "INCOME",
            hints: [
                "Money earned from work or investments regularly.",
                "Often used to cover expenses and savings."
            ],
            definition: "Money received from various sources."
        ),

        WordleItem(
            word: "BUDGET",
            hints: [
                "A plan for managing spending and savings.",
                "Helps individuals avoid unnecessary financial problems."
            ],
            definition: "A financial plan for income and expenses."
        ),

        WordleItem(
            word: "SALARY",
            hints: [
                "Fixed payment received from an employer regularly.",
                "Usually paid monthly or biweekly to workers."
            ],
            definition: "Regular compensation paid to employees."
        ),

        WordleItem(
            word: "SAVINGS",
            hints: [
                "Money set aside instead of being spent.",
                "Provides security for future needs and goals."
            ],
            definition: "Funds reserved for future use."
        ),

        WordleItem(
            word: "CREDIT",
            hints: [
                "Ability to borrow money based on trust.",
                "Often measured using a numerical score system."
            ],
            definition: "Borrowing power granted by lenders."
        ),

        WordleItem(
            word: "MARKET",
            hints: [
                "Place where buyers and sellers interact freely.",
                "Prices change based on demand and supply."
            ],
            definition: "A system where assets are traded."
        ),

        WordleItem(
            word: "EQUITY",
            hints: [
                "Ownership value remaining after liabilities are deducted.",
                "Commonly associated with company shares and stocks."
            ],
            definition: "Ownership interest in an asset or company."
        ),

        WordleItem(
            word: "RETURN",
            hints: [
                "Profit generated from an investment over time.",
                "Usually measured as a percentage of capital."
            ],
            definition: "The gain or loss on an investment."
        ),

        WordleItem(
            word: "INDEX",
            hints: [
                "Tracks performance of selected groups of assets.",
                "Used as a benchmark for market performance."
            ],
            definition: "A statistical measure of market movement."
        ),

        WordleItem(
            word: "BROKER",
            hints: [
                "Acts as intermediary between buyers and sellers.",
                "Facilitates trading of stocks and investments."
            ],
            definition: "A person or firm executing trades."
        ),

        WordleItem(
            word: "AUDIT",
            hints: [
                "Independent review of financial records and reports.",
                "Ensures statements are accurate and compliant."
            ],
            definition: "An examination of financial information."
        ),

        WordleItem(
            word: "REVENUE",
            hints: [
                "Total money earned before expenses are deducted.",
                "Often appears at the top of statements."
            ],
            definition: "Income generated from business activities."
        ),

        WordleItem(
            word: "EXPENSE",
            hints: [
                "Money spent while operating a business activity.",
                "Reducing these can improve overall profitability greatly."
            ],
            definition: "Costs incurred during operations."
        ),

        WordleItem(
            word: "CAPITAL",
            hints: [
                "Money available for investment and business growth.",
                "Essential resource for starting new ventures."
            ],
            definition: "Financial resources used to generate income."
        ),

        WordleItem(
            word: "LIQUID",
            hints: [
                "Can be converted into cash very quickly.",
                "Cash itself is the most common example."
            ],
            definition: "Easily converted into cash."
        ),

        WordleItem(
            word: "YIELD",
            hints: [
                "Measures income generated by an investment annually.",
                "Frequently expressed as a percentage return figure."
            ],
            definition: "Investment income relative to cost."
        ),

        WordleItem(
            word: "BEAR",
            hints: [
                "Market participant expecting prices to fall soon.",
                "Associated with pessimistic investment outlooks generally."
            ],
            definition: "An investor expecting declining markets."
        ),

        WordleItem(
            word: "BULL",
            hints: [
                "Market participant expecting prices to rise significantly.",
                "Associated with optimism about future performance."
            ],
            definition: "An investor expecting rising markets."
        ),

        WordleItem(
            word: "DIVIDEND",
            hints: [
                "Payment distributed to shareholders from company profits.",
                "Often received regularly by long-term investors."
            ],
            definition: "A share of profits paid to shareholders."
        ),

        WordleItem(
            word: "MARGIN",
            hints: [
                "Borrowed funds used to increase trading exposure.",
                "Can amplify both gains and losses significantly."
            ],
            definition: "Money borrowed for investing purposes."
        ),

        WordleItem(
            word: "HEDGE",
            hints: [
                "Strategy designed to reduce potential investment losses.",
                "Often involves offsetting positions in related assets."
            ],
            definition: "A risk management investment strategy."
        ),

        WordleItem(
            word: "TRUST",
            hints: [
                "Legal arrangement for managing assets on behalf.",
                "Commonly used in inheritance and estate planning."
            ],
            definition: "A fiduciary arrangement holding assets."
        ),

        WordleItem(
            word: "TREND",
            hints: [
                "General direction of market prices over time.",
                "Can move upward, downward, or sideways."
            ],
            definition: "The prevailing market direction."
        ),

        WordleItem(
            word: "CRASH",
            hints: [
                "Sudden and severe decline across financial markets.",
                "Often causes panic selling among investors."
            ],
            definition: "A rapid market collapse."
        ),

        WordleItem(
            word: "RALLY",
            hints: [
                "Strong upward movement following previous market weakness.",
                "Investors become increasingly optimistic during these."
            ],
            definition: "A significant market rise."
        ),

        WordleItem(
            word: "SHARE",
            hints: [
                "Single unit representing company ownership rights.",
                "Usually purchased and sold on stock exchanges."
            ],
            definition: "A unit of stock ownership."
        ),

        WordleItem(
            word: "QUOTE",
            hints: [
                "Current market price information for a security.",
                "Includes both buying and selling price details."
            ],
            definition: "Displayed market price of an asset."
        ),

        WordleItem(
            word: "PORTFOLIO",
            hints: [
                "Collection of investments owned by one investor.",
                "May contain stocks, bonds, and other assets."
            ],
            definition: "A group of investments held together."
        )
    ]
}
