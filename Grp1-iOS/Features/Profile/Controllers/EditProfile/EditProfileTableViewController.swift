//
//  EditProfileTableViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var genderField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAndPopulate()
    }

    var onProfileUpdated: (() -> Void)?

    private func setupUI() {
        let fields = [nameField, phoneField, emailField, dobField, genderField]

        for textField in fields {
            textField?.borderStyle = .none
            textField?.textAlignment = .right
            textField?.isUserInteractionEnabled = false
            textField?.textColor = .secondaryLabel
        }

        phoneField.keyboardType = .numberPad
        emailField.keyboardType = .emailAddress
    }

    private func fetchAndPopulate() {
        guard let token = SessionManager.shared.authToken else {
            populateFromLocal()
            return
        }

        APIService.shared.fetchProfile(token: token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.populateFromAPI(profile)
            case .failure:
                self?.populateFromLocal()
            }
        }
    }

    private func populateFromAPI(_ profile: APIProfileResponse) {
        nameField.text = profile.name
        phoneField.text = profile.phone
        emailField.text = profile.email
        dobField.text = profile.dob
        genderField.text = profile.gender.capitalized

        userImage.layer.cornerRadius = userImage.bounds.width / 2
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleAspectFill

        if let urlString = profile.profileImageUrl, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.userImage.image = image
                }
            }.resume()
        }
    }

    private func populateFromLocal() {
        let user = User.current

        userImage.image = UIImage(named: user.image)
        nameField.text = user.name
        phoneField.text = user.phone
        emailField.text = user.email
        dobField.text = user.dob
        genderField.text = user.gender.rawValue

        userImage.layer.cornerRadius =
        userImage.bounds.width / 2
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleAspectFill
    }

    private var isEditingProfile = false

    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        sender.title = isEditingProfile ? "Save" : "Edit"

        setEditingState(isEditingProfile)

        if !isEditingProfile {
            save()
        }
    }
    private func setEditingState(_ enabled: Bool) {
        let fields = [nameField, phoneField, emailField, dobField, genderField]

        for textField in fields {
            textField?.isUserInteractionEnabled = enabled
            textField?.textColor = enabled ? .label : .secondaryLabel
        }

        if enabled {
            nameField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    // MARK: - Save

    private func save() {
        let name = nameField.text ?? ""
        let phone = phoneField.text ?? ""
        let email = emailField.text ?? ""
        let dob = dobField.text ?? ""
        let gender = genderField.text ?? ""

        if let token = SessionManager.shared.authToken {
            let payload = APIEditProfileRequest(
                name: name,
                email: email,
                phone: phone,
                dob: dob,
                gender: gender.uppercased()
            )

            APIService.shared.editProfile(payload: payload, token: token) { [weak self] result in
                switch result {
                case .success(let profile):
                    User.current = UserProfile(
                        image: User.current.image,
                        name: profile.name,
                        phone: profile.phone,
                        email: profile.email,
                        level: UserLevel(rawValue: profile.level.capitalized) ?? User.current.level,
                        dob: profile.dob,
                        gender: Gender(rawValue: profile.gender.capitalized) ?? .male
                    )
                    self?.onProfileUpdated?()
                case .failure(let error):
                    print("EditProfile: failed to save - \(error)")
                }
            }
        } else {
            User.current = UserProfile(
                image: User.current.image,
                name: name,
                phone: phone,
                email: email,
                level: User.current.level,
                dob: dob,
                gender: Gender(rawValue: gender) ?? .male
            )
            onProfileUpdated?()
        }
    }

    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

// MARK: - Table View

override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
}
}
