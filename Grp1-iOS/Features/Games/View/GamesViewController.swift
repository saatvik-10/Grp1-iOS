//
//  GamesViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit
import Charts
import SwiftUI

struct GameCategory {
    let title: String
    let icon: UIImage
    let colors: [UIColor]
    let description: String
}

final class GamesViewController: UIViewController {

    @IBOutlet weak var gamesInfoButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ChartOuterView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var currentData: [GameUsage] = []


    private let categories: [GameCategory] = [
        .init(
            title: "Wordle",
            icon: UIImage(named: "WordleImage")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Guess the hidden word in six tries. One word, six chances."
        ),
        .init(
            title: "Evaluate the Company",
            icon: UIImage(named: "EvaluateImage")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Analyse financials and judge whether a company is worth investing in."
        ),
        .init(
            title: "Crossword",
            icon: UIImage(named: "CrosswordImage")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Fill the grid using clues across and down. Test your vocabulary."
        )
    ]
    private var gridCategories: [GameCategory] {
        Array(categories.prefix(4))
    }

    private var fullWidthCategory: GameCategory {
        categories.last!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupCollectionView()

        gamesInfoButton.target = self
        gamesInfoButton.action = #selector(gamesInfoButtonTapped)
    }

    @objc private func gamesInfoButtonTapped() {
        let vc = GamesInfoModalViewController(gameTitles: categories.map { $0.title })
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .systemGray6

        // Register the cell
        collectionView.register(
            UINib(nibName: "GamesCategoryCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GamesCategoryCollectionViewCell"
        )

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func makeLayout() -> UICollectionViewLayout {

        let layout = UICollectionViewCompositionalLayout { section, _ in
            
            // 🔹 FULL-WIDTH CELL (matching trending section)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(270)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            return section
        }

        return layout
    }
    private func showAlreadyPlayedAlert(for game: String) {
        let alert = UIAlertController(
            title: "Come Back Tomorrow",
            message: "You've already played \(game) today. Your streak is safe — see you tomorrow!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Games Info Modals

private enum GameHowTo {
    case wordle
    case evaluate
    case crossword

    init?(title: String) {
        switch title {
        case "Wordle": self = .wordle
        case "Evaluate the Company": self = .evaluate
        case "Crossword": self = .crossword
        default: return nil
        }
    }

    var title: String {
        switch self {
        case .wordle: return "Wordle"
        case .evaluate: return "Evaluate the Company"
        case .crossword: return "Crossword"
        }
    }

    var body: String {
        switch self {
        case .wordle:
            return [
                "Guess the hidden word in up to 6 tries.",
                "Each guess must be a valid word.",
                "After each guess, tiles change color to show correctness.",
                "Use feedback to narrow down the answer."
            ].joined(separator: "\n\n")
        case .evaluate:
            return [
                "Review the provided company information.",
                "Look at fundamentals: revenue, profit, growth, and key ratios.",
                "Decide whether you would invest and why.",
                "Use it to practice analysis and reasoning."
            ].joined(separator: "\n\n")
        case .crossword:
            return [
                "Read the Across and Down clues.",
                "Tap a cell to start typing.",
                "Answers must fit the grid length.",
                "Complete the puzzle to strengthen vocabulary and recall."
            ].joined(separator: "\n\n")
        }
    }

    var iconSystemName: String {
        switch self {
        case .wordle: return "textformat.abc"
        case .evaluate: return "chart.bar.doc.horizontal"
        case .crossword: return "square.grid.3x3"
        }
    }

    var summary: String {
        switch self {
        case .wordle:
            return "Guess the hidden word using feedback from each attempt. Improve pattern recognition and vocabulary."
        case .evaluate:
            return "Practice reading fundamentals and judging if a company looks investable."
        case .crossword:
            return "Solve clues across and down to fill the grid. Build recall and financial vocabulary."
        }
    }

    var rules: [String] {
        switch self {
        case .wordle:
            return [
                "You have up to 6 guesses.",
                "Each guess must be a valid word.",
                "Tile colors indicate correctness and placement."
            ]
        case .evaluate:
            return [
                "Review the company info shown.",
                "Look for profitability, growth, and key ratios.",
                "Make a final Invest/Avoid call with reasoning."
            ]
        case .crossword:
            return [
                "Use Across and Down clues to fill the grid.",
                "Answers must match the exact length.",
                "Use crossings to verify and correct."
            ]
        }
    }

    var steps: [String] {
        switch self {
        case .wordle:
            return [
                "Start with a strong first guess (common letters help).",
                "Use the color feedback to eliminate letters and lock positions.",
                "Tighten guesses until you solve it within 6 tries."
            ]
        case .evaluate:
            return [
                "Identify the business: what does it sell and how does it grow?",
                "Check the numbers: revenue trend, profit, debt, and margins.",
                "Decide and write a 1 line reason (the habit matters)."
            ]
        case .crossword:
            return [
                "Start with the easiest clues to build momentum.",
                "Use crossing letters to solve tougher clues.",
                "Review the grid for typos and finish the puzzle."
            ]
        }
    }

    var tips: [String] {
        switch self {
        case .wordle:
            return [
                "Avoid repeating letters early unless you have strong evidence.",
                "Use a guess to test multiple new letters when stuck."
            ]
        case .evaluate:
            return [
                "Be suspicious of high growth with no path to profitability.",
                "One metric never tells the full story. Look for consistency."
            ]
        case .crossword:
            return [
                "If a clue feels off, skip it and come back with more letters.",
                "Plural/singular and tense usually matter."
            ]
        }
    }
}

private final class GamesInfoModalViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case info
        case howToPlay
    }

    private let gameTitles: [String]

    init(gameTitles: [String]) {
        self.gameTitles = gameTitles
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Games Info"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .info:
            return 1
        case .howToPlay:
            return gameTitles.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .info:
            return "About Games"
        case .howToPlay:
            return "How To Play"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .default

        switch Section(rawValue: indexPath.section)! {
        case .info:
            var config = UIListContentConfiguration.subtitleCell()
            config.text = "Play daily, improve faster"
            config.secondaryText = [
                "Each game is designed to sharpen your investing and reasoning skills.",
                "Some games are playable once per day to encourage consistency.",
                "Keep a streak by coming back daily and practicing." 
            ].joined(separator: "\n")
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .none
        case .howToPlay:
            let title = gameTitles[indexPath.row]
            var config = UIListContentConfiguration.valueCell()
            config.text = title
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .howToPlay else { return }

        let title = gameTitles[indexPath.row]
        guard let howTo = GameHowTo(title: title) else { return }
        let vc = GameHowToPlayViewController(howTo: howTo)
        navigationController?.pushViewController(vc, animated: true)
    }
}

private final class GameHowToPlayViewController: UIViewController {
    private let howTo: GameHowTo

    init(howTo: GameHowTo) {
        self.howTo = howTo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = howTo.title
        view.backgroundColor = .systemGroupedBackground

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIStackView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .vertical
        content.spacing = 14
        scrollView.addSubview(content)

        content.addArrangedSubview(makeHeader())
        content.addArrangedSubview(makeSection(title: "Rules", rows: howTo.rules, numbered: false))
        content.addArrangedSubview(makeSection(title: "Steps", rows: howTo.steps, numbered: true))
        content.addArrangedSubview(makeSection(title: "Tips", rows: howTo.tips, numbered: false))

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    private func makeHeader() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 22

        let icon = UIImageView(image: UIImage(systemName: howTo.iconSystemName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .systemBlue

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = howTo.title

        let summaryLabel = UILabel()
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 16, weight: .regular)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 0
        summaryLabel.text = howTo.summary

        card.addSubview(iconBg)
        iconBg.addSubview(icon)
        card.addSubview(titleLabel)
        card.addSubview(summaryLabel)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),

            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            summaryLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    private func makeSection(title: String, rows: [String], numbered: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16

        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.font = .systemFont(ofSize: 13, weight: .semibold)
        header.textColor = .secondaryLabel
        header.text = title.uppercased()

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        for (idx, text) in rows.enumerated() {
            stack.addArrangedSubview(makeRow(text: text, index: numbered ? (idx + 1) : nil))
        }

        container.addSubview(header)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        return container
    }

    private func makeRow(text: String, index: Int?) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10

        if let index {
            let badge = UILabel()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.text = "\(index)"
            badge.font = .systemFont(ofSize: 13, weight: .bold)
            badge.textColor = .systemBlue
            badge.textAlignment = .center
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            badge.layer.cornerRadius = 12
            badge.layer.masksToBounds = true
            NSLayoutConstraint.activate([
                badge.widthAnchor.constraint(equalToConstant: 24),
                badge.heightAnchor.constraint(equalToConstant: 24),
            ])
            row.addArrangedSubview(badge)
        } else {
            // A fixed-height container lets us position the bullet nicely without
            // fighting UIStackView's top alignment.
            let dotContainer = UIView()
            dotContainer.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dotContainer.widthAnchor.constraint(equalToConstant: 6),
                dotContainer.heightAnchor.constraint(equalToConstant: 24),
            ])

            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = .tertiaryLabel
            dot.layer.cornerRadius = 3
            dotContainer.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6),
                dot.topAnchor.constraint(equalTo: dotContainer.topAnchor, constant: 7),
                dot.leadingAnchor.constraint(equalTo: dotContainer.leadingAnchor),
            ])

            row.addArrangedSubview(dotContainer)
        }

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.text = text
        row.addArrangedSubview(label)

        return row
    }
}

extension GamesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GamesCategoryCollectionViewCell",
            for: indexPath
        ) as! GamesCategoryCollectionViewCell

        cell.configure(with: categories[indexPath.item])
        return cell
    }
}

extension GamesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Current streak: \(DailyGameManager.shared.getStreak())") // ← add this



        let category = categories[indexPath.item]

        switch category.title {
        case "Wordle":
            if DailyGameManager.shared.canPlay(.Wordle) {
                performSegue(withIdentifier: "Wordle", sender: nil)
            } else {
                print("Already played today")
                showAlreadyPlayedAlert(for: "Wordle")

            }


        case "Crossword":
            if DailyGameManager.shared.canPlay(.crossword) {
                performSegue(withIdentifier: "crossword", sender: nil)

            } else {
                showAlreadyPlayedAlert(for: "Crossword")
            }


        case "Evaluate the Company":
            performSegue(withIdentifier: "Evaluate", sender: nil)

        default:
            print("No screen connected for:", category.title)
        }
    }

}
