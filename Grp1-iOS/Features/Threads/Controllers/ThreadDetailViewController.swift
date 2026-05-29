//
//  ThreadDetailViewController.swift
//  Grp1-iOS
//

import UIKit

class ThreadDetailViewController: UIViewController {

    var thread: APIThread!

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let scrollContent = UIView()
    private let cardView = UIView()

    private let profileImageView = UIImageView()
    private let usernameLabel    = UILabel()
    private let timeLabel        = UILabel()

    private let tagsStackView    = UIStackView()
    private let titleLabel       = UILabel()
    private let postImageView    = UIImageView()
    private let descriptionLabel = UILabel()

    private let divider          = UIView()

    private let likeButton        = UIButton(type: .system)
    private let likeCountLabel    = UILabel()
    private let commentButton     = UIButton(type: .system)
    private let commentCountLabel = UILabel()
   private let shareButton       = UIButton(type: .system)
   private let shareCountLabel   = UILabel()
    private let actionsStackView  = UIStackView()

    private var isLiked = false
    private var currentLikesCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 250/255, alpha: 1)
        setupScrollView()
        setupCard()
        setupActionButtons()
        configureWithData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshThread),
            name: .commentAdded,
            object: nil
        )
    }
}

// MARK: - Data Refresh
extension ThreadDetailViewController {

    @objc func refreshThread() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        APIService.shared.fetchForYouThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result,
                   let updated = threads.first(where: { $0.id == self?.thread.id }) {
                    self?.thread = updated
                    self?.configureWithData()
                }
            }
        }
    }
}

// MARK: - Card Setup
extension ThreadDetailViewController {

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContent.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContent)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        scrollContent.addSubview(cardView)

        let shadowHost = UIView()
        shadowHost.translatesAutoresizingMaskIntoConstraints = false
        shadowHost.backgroundColor = .clear
        shadowHost.layer.shadowColor  = UIColor.gray.cgColor
        shadowHost.layer.shadowOpacity = 0.08
        shadowHost.layer.shadowOffset  = CGSize(width: 0, height: 2)
        shadowHost.layer.shadowRadius  = 4
        shadowHost.layer.cornerRadius  = 16
        shadowHost.layer.masksToBounds = false
        scrollContent.insertSubview(shadowHost, belowSubview: cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: scrollContent.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor, constant: -24),

            shadowHost.topAnchor.constraint(equalTo: cardView.topAnchor),
            shadowHost.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            shadowHost.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            shadowHost.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .systemFont(ofSize: 20)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel

        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .center
        tagsStackView.distribution = .equalSpacing

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        titleLabel.numberOfLines = 0

        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 12

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .preferredFont(forTextStyle: .title3)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .label
        descriptionLabel.lineBreakMode = .byWordWrapping

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray5

        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 24
        actionsStackView.alignment = .center

        addCardSubviews()
    }

    func addCardSubviews() {
        [profileImageView, usernameLabel, timeLabel,
         tagsStackView, titleLabel, postImageView,
         descriptionLabel, divider, actionsStackView].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),

            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),

            tagsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.6),

            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 14),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            divider.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            actionsStackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            actionsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    func setupActionButtons() {
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        [likeButton, commentButton, shareButton].forEach {
            $0.tintColor = .systemBlue
        }

        [likeCountLabel, commentCountLabel, shareCountLabel].forEach {
            $0.font = .systemFont(ofSize: 15)
            $0.textColor = .secondaryLabel
        }

        actionsStackView.addArrangedSubview(makeActionPair(button: likeButton, label: likeCountLabel))
        actionsStackView.addArrangedSubview(makeActionPair(button: commentButton, label: commentCountLabel))

        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
    }

    func makeActionPair(button: UIButton, label: UILabel) -> UIStackView {
        let pairStack = UIStackView(arrangedSubviews: [button, label])
        pairStack.axis = .horizontal
        pairStack.spacing = 4
        pairStack.alignment = .center
        return pairStack
    }

    func makeTagPill(text: String) -> TagLabel {
        let pill = TagLabel()
        pill.text = text
        pill.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        pill.textColor = .black
        pill.backgroundColor = .systemGray6
        pill.layer.cornerRadius = 12
        pill.clipsToBounds = true
        pill.textAlignment = .center
        pill.setContentHuggingPriority(.required, for: .horizontal)
        pill.setContentCompressionResistancePriority(.required, for: .horizontal)
        pill.setContentHuggingPriority(.required, for: .vertical)
        pill.setContentCompressionResistancePriority(.required, for: .vertical)
        return pill
    }
}

// MARK: - Data Configuration
extension ThreadDetailViewController {

    func configureWithData() {
        guard let thread else { return }

        usernameLabel.text = thread.user?.name ?? thread.user?.username ?? thread.userId

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: thread.createdAt) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            timeLabel.text = rel.localizedString(for: date, relativeTo: Date())
        } else {
            timeLabel.text = String(thread.createdAt.prefix(10))
        }

        titleLabel.text    = thread.title
        descriptionLabel.text = thread.description

        if let urlStr = thread.user?.profileImageUrl, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let img = UIImage(data: data) {
                    DispatchQueue.main.async { self?.profileImageView.image = img }
                }
            }.resume()
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        if let imageUrlStr = thread.imageUrl, let url = URL(string: imageUrlStr) {
            postImageView.isHidden = false
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.postImageView.image = img }
            }.resume()
        } else {
            postImageView.isHidden = true
            descriptionLabel.topAnchor
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
                .isActive = true
        }

        tagsStackView.arrangedSubviews.forEach {
            tagsStackView.removeArrangedSubview($0); $0.removeFromSuperview()
        }
        let tags = thread.tags ?? []
        for tag in tags.prefix(3) {
            tagsStackView.addArrangedSubview(makeTagPill(text: tag))
        }
        tagsStackView.isHidden = tags.isEmpty

        currentLikesCount = thread.likesCount
        likeCountLabel.text    = "\(currentLikesCount)"
        commentCountLabel.text = "\(thread.commentsCount)"
        shareCountLabel.text   = "0"

        isLiked = thread.isLiked ?? false
        updateLikeUI()
    }
}

// MARK: - Like & Comment Actions
extension ThreadDetailViewController {

    @objc func didTapLike() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }

        isLiked.toggle()
        currentLikesCount += isLiked ? 1 : -1
        updateLikeUI()

        APIService.shared.toggleLike(threadId: thread.id, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.isLiked = response.liked
                    self?.currentLikesCount = response.likesCount
                    self?.updateLikeUI()
                case .failure:
                    self?.isLiked.toggle()
                    self?.currentLikesCount += (self?.isLiked == true ? 1 : -1)
                    self?.updateLikeUI()
                }
            }
        }
    }

    func updateLikeUI() {
        likeButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .systemBlue
        likeCountLabel.text = "\(currentLikesCount)"
    }

    @objc func didTapComment() {
        let vc = CommentsViewController()
        vc.threadId = thread.id
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 40
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
        }
        present(vc, animated: true)
    }
}
