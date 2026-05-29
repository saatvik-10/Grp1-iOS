import UIKit

extension InvestGameHomeViewController {

    // MARK: - Header (title + sector)

    func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text          = "Evaluate The\nCompany"
        titleLabel.font          = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        sectorLabel.font          = UIFont.systemFont(ofSize: 16, weight: .medium)
        sectorLabel.textColor     = .secondaryLabel
        sectorLabel.textAlignment = .center
        sectorLabel.text          = "Sector — \(puzzle.sector)"
        sectorLabel.translatesAutoresizingMaskIntoConstraints = false

        if let superviewConstraints = sectorLabel.superview?.constraints {
            let toRemove = superviewConstraints.filter {
                $0.firstItem === sectorLabel || $0.secondItem === sectorLabel
            }
            NSLayoutConstraint.deactivate(toRemove)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -45),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            sectorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            sectorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sectorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        collectionViewTopRef = sectorLabel
    }

    // MARK: - Indicator Info Button

    func setupIndicatorInfoButton() {
        let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

        let dot = UIView()
        dot.backgroundColor    = green
        dot.layer.cornerRadius = 2.5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 5).isActive  = true
        dot.heightAnchor.constraint(equalToConstant: 5).isActive = true

        let lbl = UILabel()
        lbl.text      = "What do these indicators mean?"
        lbl.font      = UIFont.systemFont(ofSize: 11.5, weight: .medium)
        lbl.textColor = green

        let row = UIStackView(arrangedSubviews: [dot, lbl])
        row.axis                 = .horizontal
        row.spacing              = 5
        row.alignment            = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false

        let pill = UIButton(type: .custom)
        pill.backgroundColor    = green.withAlphaComponent(0.10)
        pill.layer.cornerRadius = 12
        pill.layer.borderWidth  = 1
        pill.layer.borderColor  = green.withAlphaComponent(0.25).cgColor
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(row)
        pill.addTarget(self, action: #selector(indicatorInfoTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: pill.topAnchor, constant: 5),
            row.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -5),
            row.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -10),
        ])

        view.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: sectorLabel.bottomAnchor, constant: 10),
            pill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        collectionViewTopRef   = nil
        indicatorPillButton    = pill
    }

    @objc func indicatorInfoTapped() {
        let visibleNames = Array(Set(puzzle.visibleIndicators.map { $0.indicatorName })).sorted()
        let vc = IndicatorInfoViewController(visibleIndicatorNames: visibleNames)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents               = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 24
        }
        present(vc, animated: true)
    }

    // MARK: - Collection view

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing      = 14
        layout.sectionInset            = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor              = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.register(
            UINib(nibName: "CompanyCardCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CompanyCardCollectionViewCell"
        )

        view.addSubview(collectionView)

        let topRef = indicatorPillButton?.bottomAnchor
                  ?? collectionViewTopRef?.bottomAnchor
                  ?? view.safeAreaLayoutGuide.topAnchor

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topRef, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -105)
        ])
    }

    // MARK: - Hint row

    func setupHintLabel() {
        let dotBg = UIView()
        dotBg.backgroundColor    = UIColor.systemGray5
        dotBg.layer.cornerRadius = 10
        dotBg.translatesAutoresizingMaskIntoConstraints = false
        dotBg.widthAnchor.constraint(equalToConstant: 20).isActive  = true
        dotBg.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let dotLabel = UILabel()
        dotLabel.text          = "↔"
        dotLabel.font          = UIFont.systemFont(ofSize: 10)
        dotLabel.textColor     = .tertiaryLabel
        dotLabel.textAlignment = .center
        dotLabel.translatesAutoresizingMaskIntoConstraints = false
        dotBg.addSubview(dotLabel)
        NSLayoutConstraint.activate([
            dotLabel.centerXAnchor.constraint(equalTo: dotBg.centerXAnchor),
            dotLabel.centerYAnchor.constraint(equalTo: dotBg.centerYAnchor)
        ])

        let hintLabel = UILabel()
        hintLabel.text      = "Flip all cards to start evaluation"
        hintLabel.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        hintLabel.textColor = .tertiaryLabel

        let row = UIStackView(arrangedSubviews: [dotBg, hintLabel])
        row.axis      = .horizontal
        row.spacing   = 6
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(row)
        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            row.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -74)
        ])
        self.hintStackView = row
    }

    // MARK: - Start button

    func styleStartButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        config.background.cornerRadius = 16

        var titleAttr = AttributedString("Start Evaluation  →")
        titleAttr.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = titleAttr

        startEvaluationButton?.configuration = config
        startEvaluationButton?.alpha               = 1.0
        startEvaluationButton?.layer.shadowColor   = UIColor.black.cgColor
        startEvaluationButton?.layer.shadowOpacity = 0.15
        startEvaluationButton?.layer.shadowOffset  = CGSize(width: 0, height: 4)
        startEvaluationButton?.layer.shadowRadius  = 10
    }

    // MARK: - Segue

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.puzzle != nil {
            EvaluateGameStateManager.shared.saveState(step: "home", puzzle: self.puzzle, flippedCards: self.flippedCards)
        }
    }

}
