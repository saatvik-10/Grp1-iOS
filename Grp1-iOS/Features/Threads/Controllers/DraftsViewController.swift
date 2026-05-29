//
//  DraftsViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class DraftsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // Backing store for fetched drafts
    private var drafts: [APIThreadDraft] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            collectionView.dataSource = self
            collectionView.delegate = self

            collectionView.register(
                UINib(nibName: "DraftCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "DraftCollectionViewCell"
            )

            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
                layout.scrollDirection = .vertical
            }

            collectionView.backgroundColor = .clear
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        APIService.shared.fetchDrafts(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let drafts):
                    print("✅ Fetched \(drafts.count) drafts successfully.")
                    self?.drafts = drafts
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching drafts: \(error)")
                }
            }
        }
    }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            collectionView.collectionViewLayout.invalidateLayout()
        }

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            // Frame check (critical)
            print("COLLECTION VIEW FRAME:", collectionView.frame)
        }

}

    extension DraftsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            return drafts.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DraftCollectionViewCell",
                for: indexPath
            ) as? DraftCollectionViewCell else { return UICollectionViewCell() }

            let draft = drafts[indexPath.item]
            cell.configure(imageUrl: draft.imageUrl)

            return cell
        }
    }

    extension DraftsViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let columns: CGFloat = 3
            let spacing: CGFloat = 12
            let horizontalInsets: CGFloat = 16 * 2

            let totalSpacing = (columns - 1) * spacing + horizontalInsets
            let itemWidth = (collectionView.bounds.width - totalSpacing) / columns

            return CGSize(width: itemWidth, height: itemWidth * 1.4)
        }
    }
extension DraftsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let draft = drafts[indexPath.item]

        let storyboard = UIStoryboard(name: "threadsMain", bundle: nil)
        guard let createVC = storyboard.instantiateViewController(
            withIdentifier: "CreatePostViewController"
        ) as? CreatePostViewController else { return }

        createVC.apiDraft = draft
        createVC.mode = .editDraft

        navigationController?.pushViewController(createVC, animated: true)
    }
}
