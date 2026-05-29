//
//  InvestViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 12/02/26.
//

import UIKit

final class InvestViewController: UIViewController {
    
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var puzzle: DailyPuzzle!
        private var selectedCompanyId: String?
     
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
            
            // Persist active step as selection
            EvaluateGameStateManager.shared.saveState(step: "selection", puzzle: self.puzzle)
            
            setupQuitButton()
            
            setupHeader()
            setupTable()
            styleSubmitButton()
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
     
        // MARK: - Header
     
        private func setupHeader() {
            // "PICK" badge
            let badge = UILabel()
            badge.text          = "PICK"
            badge.font          = UIFont.systemFont(ofSize: 20, weight: .semibold)
            badge.textColor     = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
            badge.translatesAutoresizingMaskIntoConstraints = false
     
            // Serif title
            let title = UILabel()
            title.text          = "Which company\ndo you back?"
            title.font          = UIFont.systemFont(ofSize: 32, weight: .bold)
            title.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
            title.numberOfLines = 2
            title.translatesAutoresizingMaskIntoConstraints = false
     
            // Subtitle
            let subtitle = UILabel()
            subtitle.text      = "Select one to invest"
            subtitle.font      = UIFont.systemFont(ofSize: 18, weight: .regular)
            subtitle.textColor = .systemGray
            subtitle.translatesAutoresizingMaskIntoConstraints = false
     
            let stack = UIStackView(arrangedSubviews: [badge, title, subtitle])
            stack.axis    = .vertical
            stack.spacing = 4
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.setCustomSpacing(6, after: badge)
            stack.setCustomSpacing(6, after: title)
     
            view.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
     
        // MARK: - Table
     
        private func setupTable() {
            tableView.dataSource        = self
            tableView.delegate          = self
            tableView.tableFooterView   = UIView()
            tableView.separatorStyle    = .none
            tableView.backgroundColor   = .clear
            tableView.contentInset      = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            tableView.showsVerticalScrollIndicator = false
        }
     
        // MARK: - Submit button
     
        private func styleSubmitButton() {
            submitButton.setTitle("Submit  →", for: .normal)
            submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            submitButton.backgroundColor  = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.layer.cornerRadius = 16
            submitButton.alpha = 0.4
     
            submitButton.layer.shadowColor   = UIColor.black.cgColor
            submitButton.layer.shadowOpacity = 0.15
            submitButton.layer.shadowOffset  = CGSize(width: 0, height: 4)
            submitButton.layer.shadowRadius  = 10
        }
     
        private func unlockSubmitButton() {
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.submitButton.alpha           = 1.0
                self.submitButton.backgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
                self.submitButton.transform       = CGAffineTransform(scaleX: 1.03, y: 1.03)
            } completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.submitButton.transform = .identity
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
     
        private func lockSubmitButton() {
            UIView.animate(withDuration: 0.2) {
                self.submitButton.alpha           = 0.4
                self.submitButton.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
            }
        }
     
        // MARK: - Actions
     
        @IBAction func didTapSubmit(_ sender: UIButton) {
            guard let selectedCompanyId else {
                let alert = UIAlertController(
                    title: "No company selected",
                    message: "Please select a company before submitting.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            performSegue(withIdentifier: "showResult", sender: selectedCompanyId)
        }
     
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showResult",
               let vc = segue.destination as? ResultViewController {
                vc.selectedCompanyId = sender as? String
                vc.puzzle            = puzzle
            }
        }
    }
     
    // MARK: - UITableViewDataSource & Delegate
     
    extension InvestViewController: UITableViewDataSource, UITableViewDelegate {
     
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            puzzle.companies.count
        }
     
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CompanySelectCell",
                for: indexPath
            ) as? CompanySelectCell else { return UITableViewCell() }
     
            let company    = puzzle.companies[indexPath.row]
            let isSelected = selectedCompanyId == company.id
            cell.configure(company: company, isSelected: isSelected)
            return cell
        }
     
        func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {
            let company = puzzle.companies[indexPath.row]
     
            if selectedCompanyId == company.id {
                selectedCompanyId = nil
                lockSubmitButton()
            } else {
                selectedCompanyId = company.id
                unlockSubmitButton()
            }
     
            tableView.reloadData()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
     
        func tableView(_ tableView: UITableView,
                       heightForRowAt indexPath: IndexPath) -> CGFloat { 82 }
    }
