//
//  BiasCardView.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 03/02/26.
//
import UIKit

final class BiasCardView: UIView {

    init(title: String, description: String) {
        super.init(frame: .zero)
        setup(title: title, description: description)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(title: String, description: String) {
        backgroundColor = UIColor.white.withAlphaComponent(0.95)
        layer.cornerRadius = 20
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = .systemOrange

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .darkGray

        let bar = UIView()
        bar.backgroundColor = .systemOrange
        bar.layer.cornerRadius = 2
        bar.heightAnchor.constraint(equalToConstant: 4).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel, bar])
        stack.axis = .vertical
        stack.spacing = 12

        let hStack = UIStackView(arrangedSubviews: [icon, stack])
        hStack.spacing = 12
        hStack.alignment = .top

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
