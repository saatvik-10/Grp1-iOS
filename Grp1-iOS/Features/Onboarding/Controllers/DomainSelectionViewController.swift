//
//  DomainSelectionViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class DomainSelectionViewController: UIViewController {

    @IBOutlet weak var stepLabel: UILabel!
    var onNextTapped: (() -> Void)?
    var onBackTapped: (() -> Void)?
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view.
        stepLabel.layer.masksToBounds = true
        stepLabel.layer.cornerRadius = 12
        updateNextButtonState()
    }
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.allowsMultipleSelection = true
    }
    func updateNextButtonState() {
        let hasSelection = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        nextButton.isEnabled = hasSelection
        nextButton.alpha = hasSelection ? 1.0 : 0.5

    }

    @IBAction func backTapped(_ sender: UIButton) {
        onBackTapped?()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        onNextTapped?()
    }

}

extension DomainSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return domains.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DomainCollectionViewCell",
            for: indexPath
        ) as? DomainCollectionViewCell else { return UICollectionViewCell() }

        cell.configure(domains[indexPath.item])
        return cell
    }
}
extension DomainSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
extension DomainSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        updateNextButtonState()
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        updateNextButtonState()
    }
}
