//
//  SignUpViewController.swift
//  Grp1-iOS
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - Properties
    private var selectedGender: Gender = .male
    private var maleButton: UIButton!
    private var femaleButton: UIButton!
    private var selectedImage: UIImage?
    // MARK: - Colors
    private let accentColor = UIColor(red: 0.35, green: 0.45, blue: 0.82, alpha: 1.0)
    private let accentColorLight = UIColor.systemBlue
    private let unselectedColor = UIColor.tertiarySystemBackground
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up to start your financial journey"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 55
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let cameraBadge: UIView = {
        let badge = UIView()
        badge.backgroundColor = UIColor(red: 0.35, green: 0.45, blue: 0.82, alpha: 1.0)
        badge.layer.cornerRadius = 16
        badge.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
        return badge
    }()

    private let tapToChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to add photo"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let nameField = SignUpViewController.makeTextField(placeholder: "Full Name", icon: "person.fill")
    private let emailField = SignUpViewController.makeTextField(placeholder: "Email", icon: "envelope.fill", keyboard: .emailAddress)
    private let passwordField: UITextField = {
        let field = SignUpViewController.makeTextField(placeholder: "Password (min 8 chars)", icon: "lock.fill")
        field.isSecureTextEntry = true
        return field
    }()
    private let confirmPasswordField: UITextField = {
        let field = SignUpViewController.makeTextField(placeholder: "Confirm Password", icon: "lock.shield.fill")
        field.isSecureTextEntry = true
        return field
    }()
    private let phoneField = SignUpViewController.makeTextField(placeholder: "Phone Number", icon: "phone.fill", keyboard: .phonePad)
    private let dobField = SignUpViewController.makeTextField(placeholder: "Date of Birth", icon: "calendar")

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()
        return picker
    }()

    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
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

    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: UIColor.secondaryLabel,
                         .font: UIFont.systemFont(ofSize: 15)]
        )
        text.append(NSAttributedString(
            string: "Sign In",
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
        setupGenderButtons()
        setupLayout()
        setupDatePicker()
        setupActions()
        applyGradientToButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToButton()
    }

    // MARK: - Profile Image Tap

    @objc private func profileImageTapped() {
        let alert = UIAlertController(title: "Profile Photo", message: "Choose a source", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "📷 Camera", style: .default) { [weak self] _ in
                self?.presentImagePicker(source: .camera)
            })
        }
        alert.addAction(UIAlertAction(title: "🖼️ Photo Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(source: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    // MARK: - Actions

    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(goBackToSignIn), for: .touchUpInside)

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func goBackToSignIn() {
        if let presentingVC = self.presentingViewController {
            self.dismiss(animated: true) {
                let signInVC = SignInViewController()
                signInVC.modalPresentationStyle = .fullScreen
                presentingVC.present(signInVC, animated: true)
            }
        } else {
            let signInVC = SignInViewController()
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true)
        }
    }

    @objc private func signUpTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let dob = dobField.text, !dob.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }

        guard password.count >= 8 else {
            showAlert(title: "Weak Password", message: "Password must be at least 8 characters.")
            return
        }

        guard password == confirmPassword else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return
        }

        showLoading(true)

        let genderString = selectedGender == .male ? "MALE" : "FEMALE"

        // ✅ FIXED: Convert selectedImage to JPEG Data and pass it
        // If user skipped photo, selectedImage is nil → imageData is nil → no image uploaded (that's fine)
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        print("[SignUp] Profile image data size: \(imageData?.count ?? 0) bytes")

        AuthenticationService.shared.signUp(
            params: AuthenticationService.SignUpParameters(
                name: name,
                email: email,
                password: password,
                phone: phone,
                level: "BEGINNER",
                dob: dob,
                gender: genderString,
                hasOnboarding: false,
                profileImageData: imageData,
                profileImageFileName: "avatar.jpg"
            )
        ) { [weak self] success, errorMessage in
            guard let self = self else { return }

            if success {
                print("✅ Sign up successful — now auto signing in...")

                AuthenticationService.shared.signIn(email: email, password: password) { signInSuccess, token, _, signInError in
                    self.showLoading(false)

                    if signInSuccess, let token = token {
                        _ = CredentialStorageService.shared.saveCredentials(email: email, password: password)
                        SessionManager.shared.authToken = token
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(token, forKey: "authToken")
                        UserDefaults.standard.set(false, forKey: "hasOnboarding")

                        print("✅ Auto sign-in successful — navigating to Onboarding")
                        self.navigateToOnboarding()
                    } else {
                        self.showAlert(title: "Sign In Failed",
                                       message: signInError ?? "Account created but auto sign-in failed. Please sign in manually.")
                    }
                }
            } else {
                self.showLoading(false)
                self.showAlert(title: "Sign Up Failed", message: errorMessage ?? "Unknown error")
            }
        }
    }

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
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profileImageView.image = originalImage
        }
        tapToChangeLabel.text = "Tap to change photo"
        profileImageView.layer.borderColor = accentColor.cgColor
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension SignUpViewController {
    private func setupGenderButtons() {
        maleButton = makeGenderOption(title: "Male", icon: "figure.stand")
        femaleButton = makeGenderOption(title: "Female", icon: "figure.stand.dress")
        maleButton.addTarget(self, action: #selector(maleSelected), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleSelected), for: .touchUpInside)
        updateGenderSelection()
    }

    private func makeGenderOption(title: String, icon: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseForegroundColor = .label
        config.baseBackgroundColor = unselectedColor
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    @objc private func maleSelected() {
        selectedGender = .male
        updateGenderSelection()
    }

    @objc private func femaleSelected() {
        selectedGender = .female
        updateGenderSelection()
    }

    private func updateGenderSelection() {
        let selectedBg = accentColor.withAlphaComponent(0.15)
        maleButton.configuration?.baseBackgroundColor = selectedGender == .male ? selectedBg : unselectedColor
        maleButton.configuration?.baseForegroundColor = selectedGender == .male ? accentColor : .label
        maleButton.layer.borderWidth = selectedGender == .male ? 1.5 : 0
        maleButton.layer.borderColor = selectedGender == .male ? accentColor.cgColor : UIColor.clear.cgColor
        maleButton.layer.cornerRadius = 24
        femaleButton.configuration?.baseBackgroundColor = selectedGender == .female ? selectedBg : unselectedColor
        femaleButton.configuration?.baseForegroundColor = selectedGender == .female ? accentColor : .label
        femaleButton.layer.borderWidth = selectedGender == .female ? 1.5 : 0
        femaleButton.layer.borderColor = selectedGender == .female ? accentColor.cgColor : UIColor.clear.cgColor
        femaleButton.layer.cornerRadius = 24
    }

    private func setupDatePicker() {
        dobField.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        dobField.inputAccessoryView = toolbar
    }

    @objc private func datePickerDone() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobField.text = formatter.string(from: datePicker.date)
        dobField.resignFirstResponder()
    }

    private func applyGradientToButton() {
        signUpButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [accentColor.cgColor, accentColorLight.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = signUpButton.bounds
        gradient.cornerRadius = 14
        signUpButton.layer.insertSublayer(gradient, at: 0)
    }

    private func showLoading(_ loading: Bool) {
        signUpButton.setTitle(loading ? "" : "Sign Up", for: .normal)
        signUpButton.isEnabled = !loading
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

    static func makeTextField(placeholder: String, icon: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
        field.keyboardType = keyboard
        field.autocapitalizationType = keyboard == .emailAddress ? .none : .words
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 12
        let iconView = UIImageView(image: UIImage(systemName: icon))
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
    }

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
        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(profileImageView)
        imageContainer.addSubview(cameraBadge)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 110),
            profileImageView.heightAnchor.constraint(equalToConstant: 110),
            profileImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            cameraBadge.widthAnchor.constraint(equalToConstant: 32),
            cameraBadge.heightAnchor.constraint(equalToConstant: 32),
            cameraBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2),
            cameraBadge.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2)
        ])
        let genderStack = UIStackView(arrangedSubviews: [maleButton, femaleButton])
        genderStack.axis = .horizontal
        genderStack.spacing = 12
        genderStack.distribution = .fillEqually
        signUpButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor)
        ])
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, makeSpacer(height: 12), imageContainer,
            tapToChangeLabel, makeSpacer(height: 16), nameField, emailField,
            passwordField, confirmPasswordField, phoneField, dobField,
            makeSpacer(height: 8), genderLabel, genderStack, makeSpacer(height: 30),
            signUpButton, signInButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            signUpButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
}
