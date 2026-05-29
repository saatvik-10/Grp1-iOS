//
//  LoginViewController.swift
//  Grp1-iOS
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subheadingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        headingLabel.text = "Stay on top of your finance with us"
        subheadingLabel.text = "Understand the news, simplify complex jargon, "
            + "practice with interactive games, and join a vibrant investor community."
    }

    // MARK: - Actions

    // Connect this to your "Continue with Apple" or "Sign Up" button in Storyboard
    @IBAction func appleSignInTapped(_ sender: UIButton) {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        present(signUpVC, animated: true)
    }

    // Connect this to your "Already have an account?" Storyboard button
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        present(signInVC, animated: true)
    }
}
