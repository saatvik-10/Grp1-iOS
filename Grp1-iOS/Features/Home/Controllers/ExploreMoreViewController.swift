//
//  ExploreMoreViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class ExploreMoreViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    let newsStore = NewsDataStore.shared

        var exploreTrending: [NewsArticle] = []
        var exploreList: [NewsArticle] = []
        var exploreGrid: [NewsArticle] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .systemBackground

            registerCells()

            let all = newsStore.getAllNews()
            exploreTrending = Array(all.prefix(4))
            exploreList     = Array(all.dropFirst(4).prefix(5))
            exploreGrid     = Array(all.dropFirst(9))

            collectionView.setCollectionViewLayout(generateLayout(), animated: false)
            collectionView.delegate = self
            collectionView.dataSource = self
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            var selected: NewsArticle?

            switch indexPath.section {
            case 0: selected = exploreTrending[indexPath.row]
            case 1: selected = exploreList[indexPath.row]
            case 2: selected = exploreGrid[indexPath.row]
            default: break
            }

            performSegue(withIdentifier: "showArticleDetail", sender: selected)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showArticleDetail",
               let vc = segue.destination as? news1ViewController,
               let article = sender as? NewsArticle {
                vc.article = article
            }
        }

}

extension ExploreMoreViewController {

    func registerCells() {

        collectionView.register(
            UINib(nibName: "TrendingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "trending_cell"
        )

        collectionView.register(
            UINib(nibName: "ExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_cell"
        )

        collectionView.register(
            UINib(nibName: "RealExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "realexplore_cell"
        )
    }
}

extension ExploreMoreViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0: return exploreTrending.count
        case 1: return exploreList.count
        case 2: return exploreGrid.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "trending_cell",
                for: indexPath
            ) as? TrendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configureCell(with: exploreTrending[indexPath.row])

            cell.onArticleLensTapped = { [weak self] in
                guard let self = self else { return }
                let popup = ArticleLensPopupViewController(nibName: "ArticleLensPopupViewController", bundle: nil)
                popup.modalPresentationStyle = .overFullScreen
                popup.modalTransitionStyle = .crossDissolve
                self.present(popup, animated: true)
            }

            cell.onRecommendTapped = { [weak self] in
                self?.showToast(message: "Recommendation sent!")
            }

            return cell

        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "explore_cell",
                for: indexPath
            ) as? ExploreCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configureCell(with: exploreList[indexPath.row])

            cell.onArticleLensTapped = { [weak self] in
                guard let self = self else { return }
                let popup = ArticleLensPopupViewController(nibName: "ArticleLensPopupViewController", bundle: nil)
                popup.modalPresentationStyle = .overFullScreen
                popup.modalTransitionStyle = .crossDissolve
                self.present(popup, animated: true)
            }

            cell.onRecommendTapped = { [weak self] in
                self?.showToast(message: "Recommendation sent!")
            }

            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "realexplore_cell",
                for: indexPath
            ) as? RealExploreCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.configureCell(with: exploreGrid[indexPath.row])
            return cell
        }
    }
}

extension ExploreMoreViewController {

    func generateLayout() -> UICollectionViewLayout {

        return UICollectionViewCompositionalLayout { section, _ in

            switch section {

            case 0:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                item.contentInsets = .init(top: 0, leading: 10, bottom: 15, trailing: 10)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(320)
                    ),
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)

            case 1:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                item.contentInsets = .init(top: 0, leading: 10, bottom: 10, trailing: 10)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(170)
                    ),
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)

            default:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )

                item.contentInsets = .init(top: 0, leading: 10, bottom: 10, trailing: 10)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(250)
                    ),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .groupPagingCentered
                return section
            }
        }
    }
}
