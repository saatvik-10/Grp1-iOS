//
//  FollowersFollowingViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/03/26.
//

import UIKit

final class FollowersFollowingViewController: UIViewController {

    // MARK: - Input
    var initialSegment: Int = 0          // 0 = Followers, 1 = Following
    var targetUserId: String = ""

    // MARK: - Data
    private var followers: [APIUserBasicInfo] = []
    private var following: [APIUserBasicInfo] = []
    private var currentUserFollowingIds: Set<String> = []
    private var currentUsers: [APIUserBasicInfo] { selectedIndex == 0 ? followers : following }
    private var selectedIndex: Int = 0

    // MARK: - UI
    private let segmentControl = UISegmentedControl(items: ["Followers", "Following"])
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Connections"
        selectedIndex = initialSegment
        setupSegmentControl()
        setupTableView()
        loadData()
    }

    private func loadData() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }

        let group = DispatchGroup()

        group.enter()
        APIService.shared.fetchUserFollowers(userId: targetUserId, token: token) { [weak self] result in
            if case .success(let users) = result { self?.followers = users }
            group.leave()
        }

        group.enter()
        APIService.shared.fetchUserFollowing(userId: targetUserId, token: token) { [weak self] result in
            if case .success(let users) = result { self?.following = users }
            group.leave()
        }

        group.enter()
        let currentUserId = UserDefaults.standard.string(forKey: "userId") ?? ""
        APIService.shared.fetchUserFollowing(userId: currentUserId, token: token) { [weak self] result in
            if case .success(let users) = result { self?.currentUserFollowingIds = Set(users.map { $0.id }) }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
    }

    // MARK: - Setup
    private func setupSegmentControl() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = initialSegment
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentControl)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FollowUserCell.self, forCellReuseIdentifier: "FollowUserCell")
        tableView.rowHeight = 72
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No users found."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !currentUsers.isEmpty
    }
}

// MARK: - UITableViewDataSource
extension FollowersFollowingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FollowUserCell", for: indexPath
        ) as? FollowUserCell else { return UITableViewCell() }
        let user = currentUsers[indexPath.row]
        let currentUserId = UserDefaults.standard.string(forKey: "userId")

        let isFollowing = currentUserFollowingIds.contains(user.id)
        let isOwnProfile = user.id == currentUserId

        cell.configure(with: user, isFollowing: isFollowing, isOwnProfile: isOwnProfile)

        cell.onFollowTapped = { [weak self] in
            guard let self, let token = UserDefaults.standard.string(forKey: "authToken") else { return }

            let wasFollowing = self.currentUserFollowingIds.contains(user.id)
            if wasFollowing {
                self.currentUserFollowingIds.remove(user.id)
            } else {
                self.currentUserFollowingIds.insert(user.id)
            }
            tableView.reloadRows(at: [indexPath], with: .none)

            APIService.shared.updateFollow(followingId: user.id, token: token) { result in
                DispatchQueue.main.async {
                    if case .failure = result {
                        if wasFollowing {
                            self.currentUserFollowingIds.insert(user.id)
                        } else {
                            self.currentUserFollowingIds.remove(user.id)
                        }
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension FollowersFollowingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = currentUsers[indexPath.row]
        let currentUserId = UserDefaults.standard.string(forKey: "userId")
        guard user.id != currentUserId else { return }
        let profileVC = BloggerProfileViewController()
        profileVC.bloggerUserId = user.id
        profileVC.bloggerUserName = user.name.isEmpty ? user.username : user.name
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - FollowUserCell
final class FollowUserCell: UITableViewCell {

    var onFollowTapped: (() -> Void)?

    private let profileImageView = UIImageView()
    private let labelsStackView  = UIStackView()
    private let usernameLabel    = UILabel()
    private let nameLabel        = UILabel()
    private let followButton     = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    private func setupUI() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray3)
        contentView.addSubview(profileImageView)

        usernameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.textColor = .label

        nameLabel.font = .systemFont(ofSize: 14, weight: .regular)
        nameLabel.textColor = .secondaryLabel

        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 2
        labelsStackView.addArrangedSubview(usernameLabel)
        labelsStackView.addArrangedSubview(nameLabel)
        contentView.addSubview(labelsStackView)

        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.layer.cornerRadius = 10
        followButton.layer.borderWidth = 1
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        contentView.addSubview(followButton)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),

            labelsStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),

            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(with user: APIUserBasicInfo, isFollowing: Bool, isOwnProfile: Bool) {
        usernameLabel.text = user.name.isEmpty ? user.username : user.name
        nameLabel.text = "@\(user.username)"

        profileImageView.image = UIImage(systemName: "person.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray3)

        if let profileUrlStr = user.profileImageUrl, let url = URL(string: profileUrlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.profileImageView.image = img }
            }.resume()
        }

        followButton.isHidden = isOwnProfile

        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.label, for: .normal)
            followButton.backgroundColor = .clear
            followButton.layer.borderColor = UIColor.systemGray3.cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = .systemBlue
            followButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    @objc private func followTapped() {
        onFollowTapped?()
    }
}
