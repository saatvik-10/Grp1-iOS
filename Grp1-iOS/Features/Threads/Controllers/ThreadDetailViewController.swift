//
//  ThreadDetailViewController.swift
//  Grp1-iOS
//

import UIKit

class ThreadDetailViewController: UIViewController {

    var thread: APIThread!

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let scrollContent = UIView()          // scroll container
 
    // ── Card (white rounded shadow box) ──────────────────────────────
    private let cardView = UIView()
 
    private let profileImageView = UIImageView()
    private let usernameLabel    = UILabel()
    private let timeLabel        = UILabel()
 
    private let tagsStackView    = UIStackView()
    private let titleLabel       = UILabel()
    private let postImageView    = UIImageView()
    private let descriptionLabel = UILabel()
 
    private let divider          = UIView()
 
    // Action row
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

    @objc private func refreshThread() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        // Fetch the full thread again if we had a dedicated "fetch thread" endpoint.
        // For now, we can just fetch all for-you threads and find this one, or just increment locally.
        // Since we want accuracy, let's fetch for-you threads.
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
 
    // MARK: - ScrollView + outer container
    private func setupScrollView() {
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
            scrollContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
 
    // MARK: - Card setup (mirrors feed card style)
    private func setupCard() {
        // ── Card container ───────────────────────────────────────────
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true        
        scrollContent.addSubview(cardView)
 
        // Shadow lives on scrollContent (not cardView) so masksToBounds doesn't clip it
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
            shadowHost.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])
 
        // ── Profile image ────────────────────────────────────────────
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5
 
        // ── Username ─────────────────────────────────────────────────
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .systemFont(ofSize: 20)               // System 20 Default
 
        // ── Time ─────────────────────────────────────────────────────
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
 
        // ── Tags ─────────────────────────────────────────────────────
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .center
        tagsStackView.distribution = .equalSpacing   // pills only take intrinsic width
 
        // ── Title ────────────────────────────────────────────────────
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 24, weight: .medium) // System Medium 24
        titleLabel.numberOfLines = 0
 
        // ── Post Image ───────────────────────────────────────────────
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 12                        // matches card
 
        // ── Description ──────────────────────────────────────────────
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .preferredFont(forTextStyle: .title3) // Title 3
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.numberOfLines = 0                           // show full content
        descriptionLabel.textColor = .label
        descriptionLabel.lineBreakMode = .byWordWrapping
 
        // ── Divider ──────────────────────────────────────────────────
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray5                       // matches card dividerView
 
        // ── Actions stack ─────────────────────────────────────────────
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 24
        actionsStackView.alignment = .center
 
        // Add all subviews to card
        [profileImageView, usernameLabel, timeLabel,
         tagsStackView, titleLabel, postImageView,
         descriptionLabel, divider, actionsStackView].forEach {
            cardView.addSubview($0)
        }
 
        // ── Constraints inside card ───────────────────────────────────
        NSLayoutConstraint.activate([
            // Profile image  (40pt — same as card)
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
 
            // Username
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
 
            // Time
            timeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
 
            // Tags — leading pin only; pills hug their own intrinsic width
            tagsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
 
            // Title
            titleLabel.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
 
            // Post image (hidden when nil)
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.6),
 
            // Description — anchored to postImageView; toggled when no image
            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 14),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
 
            // Divider
            divider.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
 
            // Actions
            actionsStackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            actionsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }
 
    // MARK: - Action buttons
    private func setupActionButtons() {
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
 
        actionsStackView.addArrangedSubview(makeActionPair(button: likeButton,    label: likeCountLabel))
        actionsStackView.addArrangedSubview(makeActionPair(button: commentButton, label: commentCountLabel))
 
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
    }
 
    private func makeActionPair(button: UIButton, label: UILabel) -> UIStackView {
        let s = UIStackView(arrangedSubviews: [button, label])
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .center
        return s
    }
 
    // MARK: - Tag pill  (identical style to feed card)
    private func makeTagPill(text: String) -> TagLabel {
        let pill = TagLabel()
        pill.text = text                                   // NO "#" prefix — matches card
        pill.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        pill.textColor = .black
        pill.backgroundColor = .systemGray6
        pill.layer.cornerRadius = 12
        pill.clipsToBounds = true
        pill.textAlignment = .center
        // Hug intrinsic width — prevents pills from stretching
        pill.setContentHuggingPriority(.required, for: .horizontal)
        pill.setContentCompressionResistancePriority(.required, for: .horizontal)
        pill.setContentHuggingPriority(.required, for: .vertical)
        pill.setContentCompressionResistancePriority(.required, for: .vertical)
        return pill
    }
 
    // MARK: - Configure with data
    private func configureWithData() {
        guard let thread else { return }
 
        usernameLabel.text = thread.user?.name ?? thread.user?.username ?? thread.userId
        
        // Basic date formatting (assuming ISO string)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: thread.createdAt) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            timeLabel.text = rel.localizedString(for: date, relativeTo: Date())
        } else {
            // fallback
            timeLabel.text = String(thread.createdAt.prefix(10))
        }
        
        titleLabel.text    = thread.title
        descriptionLabel.text = thread.description
 
        // Profile image
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        if let urlStr = thread.user?.profileImageUrl {
            let _ = ImageCache.shared.loadImage(from: urlStr) { [weak self] img in
                if let img = img { self?.profileImageView.image = img }
            }
        }

        // Post image
        if let imageUrlStr = thread.imageUrl {
            postImageView.isHidden = false
            let _ = ImageCache.shared.loadImage(from: imageUrlStr) { [weak self] img in
                if let img = img { self?.postImageView.image = img }
            }
        } else {
            postImageView.isHidden = true
            descriptionLabel.topAnchor
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
                .isActive = true
        }
 
        // Tags — same pill style as card, no "#" prefix
        tagsStackView.arrangedSubviews.forEach {
            tagsStackView.removeArrangedSubview($0); $0.removeFromSuperview()
        }
        for tag in thread.tags!.prefix(3) {
            tagsStackView.addArrangedSubview(makeTagPill(text: tag))
        }
        tagsStackView.isHidden = thread.tags!.isEmpty

        // Counts
        currentLikesCount = thread.likesCount
        likeCountLabel.text    = "\(currentLikesCount)"
        commentCountLabel.text = "\(thread.commentsCount)"
        shareCountLabel.text   = "0"

        isLiked = thread.isLiked ?? false
        updateLikeUI()
    }
 
    // MARK: - Like action
    @objc private func didTapLike() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }

        // Optimistic update using tracked state
        isLiked.toggle()
        currentLikesCount += isLiked ? 1 : -1
        updateLikeUI()

        APIService.shared.toggleLike(threadId: thread.id, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.isLiked = response.liked
                    self?.currentLikesCount = response.likesCount  // sync with server
                    self?.updateLikeUI()
                case .failure:
                    // Revert on failure
                    self?.isLiked.toggle()
                    self?.currentLikesCount += (self?.isLiked == true ? 1 : -1)
                    self?.updateLikeUI()
                }
            }
        }
    }
 
    private func updateLikeUI() {
        likeButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .systemBlue
        likeCountLabel.text = "\(currentLikesCount)"
    }

    // MARK: - Comment action
    @objc private func didTapComment() {
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

