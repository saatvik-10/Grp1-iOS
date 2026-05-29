//
//  HeaderView.swift
//  TravelDestinationsApp
//
//  Created by SDC-USER on 21/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var arrowImageView: UIImageView!
//    @IBOutlet weak var arrowImageView: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGesture()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            arrowImageView.preferredSymbolConfiguration = config
            arrowImageView.tintColor = .systemGray

        headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerLabel.textColor = .label
    }

    private func setupTapGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
            self.addGestureRecognizer(tap)
            self.isUserInteractionEnabled = true
        }

        @objc private func headerTapped() {
            onTap?()
        }
}
