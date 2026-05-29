//
//  ProfileInputViewController.swift
//  Grp1-iOS
//

import UIKit

class ProfileInputViewController: UIViewController {

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
        label.text = "Complete Your Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us a bit about yourself"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    // Profile Image View
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

    // Camera badge overlay
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

    private let nameField = ProfileInputViewController.makeTextField(placeholder: "Full Name", icon: "person.fill")
    private let emailField = ProfileInputViewController.makeTextField(placeholder: "Email", icon: "envelope.fill", keyboard: .emailAddress)
    private let phoneField = ProfileInputViewController.makeTextField(placeholder: "Phone Number", icon: "phone.fill", keyboard: .phonePad)
    private let dobField = ProfileInputViewController.makeTextField(placeholder: "Date of Birth", icon: "calendar")

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

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
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
        prefillFromSession()
        updateGenderSelection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToButton()
    }
}

// MARK: - Profile Image Tap
extension ProfileInputViewController {
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
}

// MARK: - Gradient Button
extension ProfileInputViewController {
    private func applyGradientToButton() {
        continueButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [accentColor.cgColor, accentColorLight.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = continueButton.bounds
        gradient.cornerRadius = 14
        continueButton.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - Prefill
extension ProfileInputViewController {
    private func prefillFromSession() {
        if let user = SessionManager.shared.currentUser {
            nameField.text = user.name
            emailField.text = user.email
        }
    }
}

// MARK: - Actions
extension ProfileInputViewController {
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func continueTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let dob = dobField.text, !dob.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }

        // Save profile image locally
        let imagePath = saveProfileImage()

        let profile = UserProfile(
            image: imagePath ?? "",
            name: name,
            phone: phone,
            email: email,
            level: .beginner,
            dob: dob,
            gender: selectedGender
        )

        saveProfileLocally(profile)
        print("✅ Profile saved: \(profile.name), \(profile.email)")

        showAlert(title: "Profile Saved! ✅", message: "Welcome, \(name)!") { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - Save Profile Image to Documents
extension ProfileInputViewController {
    private func saveProfileImage() -> String? {
        guard let image = selectedImage,
              let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        let filename = "profile_picture.jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("❌ Failed to save profile image: \(error)")
            return nil
        }
    }

    private func saveProfileLocally(_ profile: UserProfile) {
        let defaults = UserDefaults.standard
        defaults.set(profile.image, forKey: "user_profileImage")
        defaults.set(profile.name, forKey: "user_name")
        defaults.set(profile.email, forKey: "user_email")
        defaults.set(profile.phone, forKey: "user_phone")
        defaults.set(profile.dob, forKey: "user_dob")
        defaults.set(profile.gender.rawValue, forKey: "user_gender")
        defaults.set(profile.level.rawValue, forKey: "user_level")
        defaults.set(true, forKey: "profileComplete")
    }
}

// MARK: - Helpers
extension ProfileInputViewController {
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }

    private static func makeTextField(placeholder: String, icon: String, keyboard: UIKeyboardType = .default) -> UITextField {
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
}

// MARK: - Layout
extension ProfileInputViewController {
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

        // Profile image container
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
        genderStack.alignment = .leading
        genderStack.spacing = 12
        genderStack.distribution = .fillEqually

        let genderContainer = UIView()
        genderContainer.backgroundColor = .secondarySystemBackground
        genderContainer.layer.cornerRadius = 12
        genderContainer.translatesAutoresizingMaskIntoConstraints = false

        let innerStack = UIStackView(arrangedSubviews: [genderLabel, genderStack])
        innerStack.axis = .vertical
        innerStack.spacing = 12
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        genderContainer.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: genderContainer.topAnchor, constant: 16),
            innerStack.leadingAnchor.constraint(equalTo: genderContainer.leadingAnchor, constant: 16),
            innerStack.trailingAnchor.constraint(equalTo: genderContainer.trailingAnchor, constant: -16),
            innerStack.bottomAnchor.constraint(equalTo: genderContainer.bottomAnchor, constant: -16)
        ])

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            makeSpacer(height: 12),
            imageContainer,
            tapToChangeLabel,
            makeSpacer(height: 16),
            nameField,
            emailField,
            phoneField,
            dobField,
            genderContainer,
            makeSpacer(height: 30),
            continueButton
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
            continueButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
}

// MARK: - Gender Selection
extension ProfileInputViewController {
    fileprivate func setupGenderButtons() {
        maleButton = makeGenderOption(title: "Male", icon: "figure.stand")
        femaleButton = makeGenderOption(title: "Female", icon: "figure.stand.dress")
        maleButton.addTarget(self, action: #selector(maleSelected), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleSelected), for: .touchUpInside)
    }

    private func makeGenderOption(title: String, icon: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: "circle")
        config.imagePadding = 12
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
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

    fileprivate func updateGenderSelection() {
        maleButton.configuration?.image = UIImage(systemName: selectedGender == .male ? "circle.inset.filled" : "circle")
        maleButton.configuration?.baseForegroundColor = selectedGender == .male ? accentColor : .label
        maleButton.layer.borderWidth = 0

        femaleButton.configuration?.image = UIImage(systemName: selectedGender == .female ? "circle.inset.filled" : "circle")
        femaleButton.configuration?.baseForegroundColor = selectedGender == .female ? accentColor : .label
        femaleButton.layer.borderWidth = 0
    }
}

// MARK: - Date Picker
extension ProfileInputViewController {
    fileprivate func setupDatePicker() {
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
}

extension ProfileInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
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
