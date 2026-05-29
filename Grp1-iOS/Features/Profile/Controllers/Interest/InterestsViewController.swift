import UIKit

class InterestsViewController: UIViewController {

    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    // Render only the user's saved selections on this screen.
    // The Add flow still shows the full master list.
    var domains = UserInterests.domains
    //    let companies = InterestsDataSource.companies
    var preferences = UserInterests.preferences

    var currentSection: InterestType {
        segmented.selectedSegmentIndex == 0 ? .domain : .preference
    }

    var currentItems: [InterestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        currentItems = domains
        setupSegmented()
        setupCollectionView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userInterestsDidChange),
            name: .userInterestsDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let vc = navController.viewControllers.first as? AddInterestViewController {

            vc.interestType = (segmented.selectedSegmentIndex == 0) ? .domain : .preference
            // Add screen should show the full list to choose from.
            vc.sourceItems = (segmented.selectedSegmentIndex == 0) ? InterestsDataSource.domains : InterestsDataSource.preferences

        }
    }
}

// MARK: - Setup segmented + collectionview
extension InterestsViewController {

    private func setupSegmented() {
        segmented.removeAllSegments()
        //        segmented.insertSegment(withTitle: "Companies", at: 1, animated: false)
        segmented.insertSegment(withTitle: "Domains", at: 0, animated: false)
        segmented.insertSegment(withTitle: "Preferences", at: 1, animated: false)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        collectionView.register(
            UINib(nibName: "DomainViewCell", bundle: nil),
            forCellWithReuseIdentifier: "DomainViewCell"
        )
        //        collectionView.register(
        //            UINib(nibName: "CompaniesViewCell", bundle: nil),
        //            forCellWithReuseIdentifier: "CompaniesViewCell"
        //        )
        collectionView.register(
            UINib(nibName: "PreferencesViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PreferencesViewCell"
        )
    }

    @objc private func segmentChanged() {
        currentItems = (segmented.selectedSegmentIndex == 0) ? domains : preferences
        collectionView.reloadData()
    }

    @objc private func userInterestsDidChange() {
        // Pull the latest user selections and refresh.
        domains = UserInterests.domains
        preferences = UserInterests.preferences
        currentItems = (segmented.selectedSegmentIndex == 0) ? domains : preferences
        collectionView.reloadData()
    }

    private func makeDeleteHandler(for cell: UICollectionViewCell) -> (() -> Void) {
        return { [weak self, weak cell] in
            guard
                let self,
                let cell,
                let indexPath = self.collectionView.indexPath(for: cell)
            else { return }

            self.confirmDelete(at: indexPath)
        }
    }

}

// MARK: - CollectionView datasource & delegate
extension InterestsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = currentItems[indexPath.row]

        if segmented.selectedSegmentIndex == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DomainViewCell",
                for: indexPath
            ) as? DomainViewCell else { return UICollectionViewCell() }

            cell.configure(model)
            cell.onDelete = makeDeleteHandler(for: cell)
            return cell

        } else {
            //            let cell = collectionView.dequeueReusableCell(
            //                withReuseIdentifier: "CompaniesViewCell",
            //                for: indexPath
            //            ) as! CompaniesViewCell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PreferencesViewCell",
                for: indexPath
            ) as? PreferencesViewCell else { return UICollectionViewCell() }
            cell.configure(model)
            cell.onDelete = makeDeleteHandler(for: cell)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        print("Tapped → \(currentItems[indexPath.row].title)")
    }
}

// MARK: - Compositional Layout
extension InterestsViewController {
    func generateLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension InterestsViewController {

    func confirmDelete(at indexPath: IndexPath) {

        let title: String

        switch currentSection {
        case .domain:
            title = "Delete Domain?"
        case .preference:
            title = "Delete Preference?"
        }

        let alert = UIAlertController(
            title: title,
            message: "This action cannot be undone.",
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { _ in

                switch self.currentSection {

                case .domain:
                    self.domains.remove(at: indexPath.item)
                    UserInterests.domains = self.domains
                    self.currentItems = self.domains

                case .preference:
                    self.preferences.remove(at: indexPath.item)
                    UserInterests.preferences = self.preferences
                    self.currentItems = self.preferences
                }

                NotificationCenter.default.post(name: .userInterestsDidChange, object: nil)

                self.collectionView.reloadData()
            }
        )

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(alert, animated: true)
    }
}
