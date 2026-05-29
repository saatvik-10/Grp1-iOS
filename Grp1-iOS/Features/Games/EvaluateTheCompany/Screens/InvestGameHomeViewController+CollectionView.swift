import UIKit

// MARK: - UICollectionViewDataSource

    extension InvestGameHomeViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            puzzle.companies.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CompanyCardCollectionViewCell",
                for: indexPath
            ) as? CompanyCardCollectionViewCell else { return UICollectionViewCell() }

            let company    = puzzle.companies[indexPath.item]
            let indicators = puzzle.visibleIndicators.filter { $0.companyId == company.id }
            cell.configureFront(company: company)
            cell.configureBack(indicators: indicators)
            return cell
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    extension InvestGameHomeViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let spacing: CGFloat = 20 + 20 + 14
            let width = (collectionView.bounds.width - spacing) / 2
            return CGSize(width: width, height: width * 1.28)
        }

        func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath)
                    as? CompanyCardCollectionViewCell else { return }
            cell.flip()
            cardFlipped(at: indexPath.item)
        }
    }

