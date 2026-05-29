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

    @IBOutlet weak var chartOuterView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var currentData: [GameUsage] = []

    private let categories: [GameCategory] = [
        .init(
            title: "Scenario",
            icon: UIImage(named: "SceanrioImaghe")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Navigate real-world business situations and make critical decisions."
        ),
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

    private var fullWidthCategory: GameCategory? {
        categories.last
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GamesCategoryCollectionViewCell",
            for: indexPath
        ) as? GamesCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

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
            if DailyGameManager.shared.canPlay(.wordle) {
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

        case "Scenario":
            performSegue(withIdentifier: "scenario", sender: nil)

        case "Evaluate the Company":
            if DailyGameManager.shared.canPlay(.Evaluate) {
                performSegue(withIdentifier: "Evaluate", sender: nil)
            } else {
                showAlreadyPlayedAlert(for: "Evaluate the Company")
            }

        default:
            print("No screen connected for:", category.title)
        }
    }

}
