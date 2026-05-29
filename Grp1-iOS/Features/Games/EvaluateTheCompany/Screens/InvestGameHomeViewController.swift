//
//  InvestGameHomeViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit

class InvestGameHomeViewController: UIViewController {

    // ── Storyboard outlets ───────────────────────────────────
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var startEvaluationButton: UIButton!

        private var puzzle: DailyPuzzle!
        private var collectionView: UICollectionView!
        private var flippedCards = Set<Int>()
        private var collectionViewTopRef: UILabel?
        private var indicatorPillButton: UIButton?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    private var loadingOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)

        Task {
            await loadPuzzleAsync()
        }
    }

    private func loadPuzzleAsync() async {
        showLoadingOverlay()

        if #available(iOS 26.0, *) {
            if let generated = await PuzzleGenerator.shared.generate() {
                self.puzzle = generated
            } else {
                self.puzzle = DailyPuzzleLoader.loadDailyPuzzle()
            }
        } else {
            self.puzzle = DailyPuzzleLoader.loadDailyPuzzle()
        }

        hideLoadingOverlay()

        setupHeader()
        setupIndicatorInfoButton()
        setupCollectionView()
        setupHintLabel()
        styleStartButton()
    }

    private func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = view.backgroundColor
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        spinner.startAnimating()

        let label = UILabel()
        label.text = "Generating today's puzzle…"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray

        let badgeStack = UIStackView()
        badgeStack.axis = .horizontal
        badgeStack.spacing = 6
        badgeStack.alignment = .center

        let icon = UIImageView(image: UIImage(systemName: "sparkles"))
        icon.tintColor = .systemPurple
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let badgeLabel = UILabel()
        badgeLabel.text = "Apple Intelligence"
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        badgeLabel.textColor = .systemPurple

        badgeStack.addArrangedSubview(icon)
        badgeStack.addArrangedSubview(badgeLabel)

        let badgeContainer = UIView()
        badgeContainer.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.1)
        badgeContainer.layer.cornerRadius = 12
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.addSubview(badgeStack)
        badgeStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            badgeStack.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 4),
            badgeStack.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -4),
            badgeStack.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 10),
            badgeStack.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -10)
        ])

        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(badgeContainer)

        overlay.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])

        view.addSubview(overlay)
        self.loadingOverlay = overlay
    }

    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingOverlay?.alpha = 0
        }, completion: { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        })
    }

}

// MARK: - Header

extension InvestGameHomeViewController {

    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text = "Evaluate The\nCompany"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        sectorLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        sectorLabel.textColor = .secondaryLabel
        sectorLabel.textAlignment = .center
        sectorLabel.text = "Sector — \(puzzle.sector)"
        sectorLabel.translatesAutoresizingMaskIntoConstraints = false

        if let superviewConstraints = sectorLabel.superview?.constraints {
            let toRemove = superviewConstraints.filter {
                $0.firstItem === sectorLabel || $0.secondItem === sectorLabel
            }
            NSLayoutConstraint.deactivate(toRemove)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sectorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            sectorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sectorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        collectionViewTopRef = sectorLabel
    }
}

// MARK: - Indicator Info Button

extension InvestGameHomeViewController {

    private func setupIndicatorInfoButton() {
            let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

            let dot = UIView()
            dot.backgroundColor    = green
            dot.layer.cornerRadius = 3.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 7).isActive  = true
            dot.heightAnchor.constraint(equalToConstant: 7).isActive = true

            let lbl = UILabel()
            lbl.text      = "What do these indicators mean?"
            lbl.font      = UIFont.systemFont(ofSize: 13, weight: .medium)
            lbl.textColor = green

            let row = UIStackView(arrangedSubviews: [dot, lbl])
            row.axis                 = .horizontal
            row.spacing              = 6
            row.alignment            = .center
            row.isUserInteractionEnabled = false
            row.translatesAutoresizingMaskIntoConstraints = false

            let pill = UIButton(type: .custom)
            pill.backgroundColor    = green.withAlphaComponent(0.10)
            pill.layer.cornerRadius = 16
            pill.layer.borderWidth  = 1
            pill.layer.borderColor  = green.withAlphaComponent(0.25).cgColor
            pill.translatesAutoresizingMaskIntoConstraints = false
            pill.addSubview(row)
            pill.addTarget(self, action: #selector(indicatorInfoTapped), for: .touchUpInside)

            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: pill.topAnchor, constant: 8),
                row.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -8),
                row.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 14),
                row.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -14)
            ])

            view.addSubview(pill)
            NSLayoutConstraint.activate([
                pill.topAnchor.constraint(equalTo: sectorLabel.bottomAnchor, constant: 14),
                pill.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

            collectionViewTopRef   = nil
            indicatorPillButton    = pill
        }

    @objc private func indicatorInfoTapped() {
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
}

// MARK: - Collection view

extension InvestGameHomeViewController {

    private func setupCollectionView() {
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
            collectionView.topAnchor.constraint(equalTo: topRef, constant: 4),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
}

// MARK: - Hint row

extension InvestGameHomeViewController {

    private func setupHintLabel() {
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
            row.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
}

// MARK: - Start button

extension InvestGameHomeViewController {

    private func styleStartButton() {
        startEvaluationButton?.setTitle("Start Evaluation  →", for: .normal)
        startEvaluationButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        startEvaluationButton?.backgroundColor  = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        startEvaluationButton?.setTitleColor(.white, for: .normal)
        startEvaluationButton?.layer.cornerRadius  = 16
        startEvaluationButton?.alpha               = 0.4
        startEvaluationButton?.layer.shadowColor   = UIColor.black.cgColor
        startEvaluationButton?.layer.shadowOpacity = 0.15
        startEvaluationButton?.layer.shadowOffset  = CGSize(width: 0, height: 4)
        startEvaluationButton?.layer.shadowRadius  = 10
    }
}

// MARK: - Navigation

extension InvestGameHomeViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwist",
           let vc = segue.destination as? TwistViewController {
            vc.puzzle = puzzle
        }
    }

    @IBAction func startEvaluationTapped(_ sender: UIButton) {
        guard flippedCards.count >= puzzle.companies.count else {
            return
        }
        performSegue(withIdentifier: "showTwist", sender: nil)
    }
}

// MARK: - Flip tracking

extension InvestGameHomeViewController {

    func cardFlipped(at index: Int) {
        flippedCards.insert(index)
        guard flippedCards.count >= puzzle.companies.count else { return }
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.startEvaluationButton?.alpha           = 1.0
            self.startEvaluationButton?.backgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
            self.startEvaluationButton?.transform       = CGAffineTransform(scaleX: 1.04, y: 1.04)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.startEvaluationButton?.transform = .identity
            }
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

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
