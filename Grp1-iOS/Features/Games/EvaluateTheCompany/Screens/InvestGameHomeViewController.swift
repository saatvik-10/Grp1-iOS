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

        var puzzle: DailyPuzzle!
        var collectionView: UICollectionView!
        var flippedCards = Set<Int>()
        var collectionViewTopRef: UILabel?
        var indicatorPillButton: UIButton?
        var hintStackView: UIStackView?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    private var loadingOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)

        #if DEBUG
        if #available(iOS 26.0, *) {
            PuzzleGenerator.runSelfSanityChecks()
        }
        #endif

        setupQuitButton()

        Task {
            await loadPuzzleAsync()
        }
    }

    private func loadPuzzleAsync() async {
        if self.puzzle != nil {
            return
        }

        showLoadingOverlay()

        if let savedState = EvaluateGameStateManager.shared.loadState() {
            self.puzzle = savedState.puzzle
            self.flippedCards = Set(savedState.flippedCards)
            print("🔄 Resumed game from saved state: step=\(savedState.currentStep)")

            hideLoadingOverlay()
            setupHeader()
            setupIndicatorInfoButton()
            setupCollectionView()
            setupHintLabel()
            styleStartButton()

            // Check if we need to auto-advance to twist or selection
            if savedState.currentStep == "twist" {
                self.performSegue(withIdentifier: "showTwist", sender: nil)
            } else if savedState.currentStep == "selection" {
                self.performSegue(withIdentifier: "showTwist", sender: "autoAdvance")
            }
            return
        }

        if #available(iOS 26.0, *) {
            if let generated = await PuzzleGenerator.shared.generate() {
                self.puzzle = generated
            } else {
                self.puzzle = DailyPuzzleLoader.loadDailyPuzzle()
            }
        } else {
            self.puzzle = DailyPuzzleLoader.loadDailyPuzzle()
        }

        // Save initial state
        EvaluateGameStateManager.shared.saveState(step: "home", puzzle: self.puzzle, flippedCards: self.flippedCards)

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

        private func setupQuitButton() {
            let quitBtn = UIBarButtonItem(
                title: "Quit",
                style: .plain,
                target: self,
                action: #selector(quitButtonTapped)
            )
            quitBtn.tintColor = .systemRed
            navigationItem.rightBarButtonItem = quitBtn
        }

        @objc private func quitButtonTapped() {
            let alert = UIAlertController(
                title: "Quit Game?",
                message: "You can resume this daily challenge later today from where you left off. Quitting will not reset your progress.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Resume Game", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Quit Game", style: .destructive, handler: { [weak self] _ in
                self?.exitToGames()
            }))
            present(alert, animated: true)
        }

        private func exitToGames() {
            if let nav = self.navigationController {
                if nav.presentingViewController != nil {
                    nav.dismiss(animated: true, completion: nil)
                } else {
                    nav.popToRootViewController(animated: true)
                    nav.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showTwist",
               let vc = segue.destination as? TwistViewController {
                vc.puzzle = puzzle
                if let str = sender as? String, str == "autoAdvance" {
                    vc.shouldAutoAdvanceToSelection = true
                }
            }
        }

        @IBAction func startEvaluationTapped(_ sender: UIButton) {
            guard flippedCards.count >= puzzle.companies.count else {
                return
            }
            performSegue(withIdentifier: "showTwist", sender: nil)
        }

        // MARK: - Flip tracking

        func cardFlipped(at index: Int) {
            flippedCards.insert(index)

            // Persist flips in state
            EvaluateGameStateManager.shared.saveState(step: "home", puzzle: self.puzzle, flippedCards: self.flippedCards)

            guard flippedCards.count >= puzzle.companies.count else { return }
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.startEvaluationButton?.alpha = 1.0

                // Update configuration base background color to green
                if var config = self.startEvaluationButton?.configuration {
                    config.baseBackgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
                    self.startEvaluationButton?.configuration = config
                }

                self.startEvaluationButton?.transform       = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.startEvaluationButton?.transform = .identity
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
