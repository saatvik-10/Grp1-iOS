//
//  QuizResultViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class QuizResultViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var score: Int = 0
    var totalQuestions: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        let percent = scorePercentage()
        greetingLabel.text = "You have scored \(percent)%"
        scoreLabel.text = "\(score) / \(totalQuestions)"
        if percent <= 50 {
            scoreLabel.textColor = .red
            messageLabel.text = "Don't worry—every attempt is part of the learning process. "
                + "Take a moment to revisit the article and reflect on the key ideas. "
                + "With a little more practice, you'll see steady improvement."

        } else {
            scoreLabel.textColor = .systemGreen
            messageLabel.text = "Great job! You've understood the core ideas of the article really well. "
                + "Your effort is clearly paying off, so keep building on this momentum and stay curious."
        }
    }
    func scorePercentage() -> Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(score) / Double(totalQuestions)) * 100)
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }

}
