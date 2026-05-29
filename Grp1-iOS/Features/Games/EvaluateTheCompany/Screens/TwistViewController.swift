//
//  TwistViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 09/02/26.
//

import UIKit

final class TwistViewController: UIViewController {

    var puzzle: DailyPuzzle!

    let mainStack     = UIStackView()
    let cagrContainer = UIView()
    let valuesStack   = UIStackView()

    // ── Connect this in Storyboard ──
    @IBOutlet weak var proceedButton: UIButton!

    var shouldAutoAdvanceToSelection = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldAutoAdvanceToSelection {
            DispatchQueue.main.async {
                self.shouldAutoAdvanceToSelection = false
                self.performSegue(withIdentifier: "showInvest", sender: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)

        // Persist active step as twist
        EvaluateGameStateManager.shared.saveState(step: "twist", puzzle: self.puzzle)

        setupQuitButton()

        // Shadow must stay in code (Storyboard can't do shadows)
        proceedButton.layer.shadowColor   = UIColor.black.cgColor
        proceedButton.layer.shadowOpacity = 0.15
        proceedButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
        proceedButton.layer.shadowRadius  = 10
        setupUI()
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

    // MARK: - Navigation

    @IBAction func proceedTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showInvest", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInvest",
           let vc = segue.destination as? InvestViewController {
            vc.puzzle = puzzle
        }
    }

    // MARK: - UI

    private func setupUI() {
        mainStack.axis      = .vertical
        mainStack.spacing   = 4
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -45)
        ])

        // ── "TWIST" primary page title (enlarged for strong hierarchy) ──

        let twistBadge = UILabel()
        twistBadge.text          = "TWIST"
        twistBadge.font          = UIFont.systemFont(ofSize: 40, weight: .bold)
        twistBadge.textColor     = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        twistBadge.textAlignment = .center
        twistBadge.letterSpacing(2)
        mainStack.addArrangedSubview(twistBadge)
        mainStack.setCustomSpacing(16, after: twistBadge)

        // ── "Wait!" — Georgia serif, matches screen 1 title ──
        let waitLabel = UILabel()
        waitLabel.text          = "Wait!"
        waitLabel.font          = UIFont.systemFont(ofSize: 22, weight: .bold)
        waitLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        waitLabel.textAlignment = .center
        mainStack.addArrangedSubview(waitLabel)
        mainStack.setCustomSpacing(4, after: waitLabel)

        // ── Subtitle ──
        let subtitle = UILabel()
        subtitle.text          = "This might help your decision"
        subtitle.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitle.textColor     = .secondaryLabel
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        mainStack.addArrangedSubview(subtitle)
        mainStack.setCustomSpacing(4, after: subtitle)

        // ── Sector ──
        let sector = UILabel()
        sector.text          = "Sector — \(puzzle.sector)"
        sector.font          = UIFont.systemFont(ofSize: 15, weight: .medium)
        sector.textColor     = .secondaryLabel
        sector.textAlignment = .center
        mainStack.addArrangedSubview(sector)

        setupCAGRSection()
    }
}

// MARK: - UILabel helper

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        attributedText = NSAttributedString(string: text, attributes: [.kern: spacing])
    }
}
