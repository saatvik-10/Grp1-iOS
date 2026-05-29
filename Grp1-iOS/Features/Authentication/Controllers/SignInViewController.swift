//
//  SignInViewController.swift
//  Grp1-iOS
//

import UIKit

class SignInViewController: UIViewController {

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue your financial journey"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        iconView.frame = CGRect(x: 12, y: 0, width: 20, height: 24)
        container.addSubview(iconView)
        field.leftView = container
        field.leftViewMode = .always

        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: "lock.fill"))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        iconView.frame = CGRect(x: 12, y: 0, width: 20, height: 24)
        container.addSubview(iconView)
        field.leftView = container
        field.leftViewMode = .always

        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return field
    }()

    private let accentColor = UIColor(red: 0.35, green: 0.45, blue: 0.82, alpha: 1.0)

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [.foregroundColor: UIColor.secondaryLabel,
                         .font: UIFont.systemFont(ofSize: 15)]
        )
        text.append(NSAttributedString(
            string: "Sign Up",
            attributes: [.foregroundColor: UIColor.systemBlue,
                         .font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
        ))
        button.setAttributedTitle(text, for: .normal)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
        applyGradientToButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToButton()
    }

    // MARK: - Gradient Button

    private func applyGradientToButton() {
        signInButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [accentColor.cgColor, UIColor.systemBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = signInButton.bounds
        gradient.cornerRadius = 14
        signInButton.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: - Actions

    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func goBack() {
        if let presentingVC = self.presentingViewController {
            self.dismiss(animated: true) {
                let signUpVC = SignUpViewController()
                signUpVC.modalPresentationStyle = .fullScreen
                presentingVC.present(signUpVC, animated: true)
            }
        } else {
            let signUpVC = SignUpViewController()
            signUpVC.modalPresentationStyle = .fullScreen
            self.present(signUpVC, animated: true)
        }
    }

    // MARK: - Sign In

    @objc private func signInTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }

        showLoading(true)

        AuthenticationService.shared.signIn(email: email, password: password) { [weak self] success, token, hasOnboarding, error in
            guard let self = self else { return }
            self.showLoading(false)

            if success, let token = token {
                // Save credentials to Keychain
                _ = CredentialStorageService.shared.saveCredentials(email: email, password: password)

                // Save session
                SessionManager.shared.authToken = token
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(token, forKey: "authToken")

                print("✅ Sign in successful")

                // Database hasOnboarding status
                if hasOnboarding {
                    self.navigateToHome()
                } else {
                    self.navigateToOnboarding()
                }
            } else {
                self.showAlert(title: "Sign In Failed", message: error ?? "Unknown error")
            }
        }
    }

    // MARK: - Navigation

    private func navigateToOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let onboardingVC = storyboard.instantiateViewController(
            withIdentifier: "OnboardingPageViewController"
        ) as? OnboardingPageViewController {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
            window.rootViewController = onboardingVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
        if let homeVC = storyboard.instantiateInitialViewController() {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
            window.rootViewController = homeVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - Helpers

    private func showLoading(_ loading: Bool) {
        signInButton.setTitle(loading ? "" : "Sign In", for: .normal)
        signInButton.isEnabled = !loading
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        signInButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor)
        ])

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            makeSpacer(height: 40),
            emailField,
            passwordField,
            makeSpacer(height: 24),
            signInButton,
            backButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            signInButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
}
