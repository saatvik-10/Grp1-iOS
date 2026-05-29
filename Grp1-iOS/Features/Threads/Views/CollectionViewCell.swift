import UIKit

class collectionViewCell: UICollectionViewCell {
    var onFollowTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onUsernameTapped: (() -> Void)?
    var onBookmarkTapped: (() -> Void)?
    var isFollowingUser: Bool = false
    var isBookmarked: Bool = false
    var shouldShowFollowAction: Bool = true
    var isOwnPost: Bool = false
    var onMoreTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onCommentTapped: (() -> Void)?

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tagsStackView: UIStackView!
    @IBOutlet weak var nameMetaStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var threadImg: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var sharesButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    private var widthConstraint: NSLayoutConstraint?
    private var profileImageTask: URLSessionDataTask?
    private var threadImageTask: URLSessionDataTask?

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        onLikeTapped?()
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        onCommentTapped?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 180)
        widthConstraint?.priority = UILayoutPriority(999)
        widthConstraint?.isActive = true
        tagsStackView.distribution = .fill
        tagsStackView.alignment = .center
        tagsStackView.setContentHuggingPriority(.required, for: .horizontal)
        tagsStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        tagsStackView.isLayoutMarginsRelativeArrangement = true
        nameMetaStack.distribution = .fill
        nameMetaStack.setContentHuggingPriority(.required, for: .horizontal)
        setupUI()
        setupMoreMenu()
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTap))
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(imageTap)
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTap))
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(labelTap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImg.image = UIImage(systemName: "person.circle.fill")
        threadImg.image = nil
        profileImageTask?.cancel()
        threadImageTask?.cancel()
        profileImageTask = nil
        threadImageTask = nil
        onFollowTapped = nil
        onDeleteTapped = nil
        onUsernameTapped = nil
        onBookmarkTapped = nil
        onMoreTapped = nil
        onLikeTapped = nil
        onCommentTapped = nil
        isFollowingUser = false
        isBookmarked = false
        shouldShowFollowAction = true
        isOwnPost = false
        threadImg.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {

        var screenWidth: CGFloat = 0
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            screenWidth = windowScene.screen.bounds.width
        } else {

            screenWidth = layoutAttributes.frame.width
        }

        let padding: CGFloat = 32
        let availableWidth = screenWidth - padding

        let autoLayoutSize = contentView.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required, // Width is FIXED
            verticalFittingPriority: .fittingSizeLevel // Height can GROW
        )

        let newFrame = CGRect(x: layoutAttributes.frame.origin.x,
                              y: layoutAttributes.frame.origin.y,
                              width: availableWidth,
                              height: ceil(autoLayoutSize.height))

        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}

// MARK: - Setup & Configuration

extension collectionViewCell {

    func updateWidth(_ width: CGFloat) {
        widthConstraint?.constant = width
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false

        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true

        userNameLabel.numberOfLines = 1
        userNameLabel.lineBreakMode = .byTruncatingTail

        timeAgoLabel.font = UIFont.systemFont(ofSize: 16)
        timeAgoLabel.textColor = .secondaryLabel
        timeAgoLabel.numberOfLines = 1
        timeAgoLabel.lineBreakMode = .byTruncatingTail

        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail

        threadImg.contentMode = .scaleAspectFill
        threadImg.layer.cornerRadius = 12
        threadImg.clipsToBounds = true

        var config = UIButton.Configuration.plain()
        config.imagePadding = 1
        likesButton.configuration = config
        commentsButton.tintColor = .systemBlue
        sharesButton.tintColor = .systemBlue
        sharesButton.isHidden = true

        moreButton.tintColor = .secondaryLabel
        dividerView.backgroundColor = .systemGray5
    }

    private func makeTagLabel(text: String) -> UILabel {
        let label = TagLabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center

        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func applyStyle(isCard: Bool) {
        if isCard {
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 16
            layer.cornerRadius = 16
            layer.shadowOpacity = 0.08
            dividerView.isHidden = true
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
            layer.cornerRadius = 0
            layer.shadowOpacity = 0
            dividerView.isHidden = false
        }
    }

    func configure(with thread: APIThread, isFollowing: Bool, isOwnPost: Bool) {
        self.isFollowingUser = isFollowing
        self.shouldShowFollowAction = !isOwnPost
        self.isOwnPost = isOwnPost

        userNameLabel.text = thread.user?.name ?? thread.user?.username ?? thread.userId
        titleLabel.text = thread.title
        descriptionLabel.text = thread.description

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: thread.createdAt) {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .abbreviated
            timeAgoLabel.text = rel.localizedString(for: date, relativeTo: Date())
        } else {
            timeAgoLabel.text = ""
        }

        profileImg.image = UIImage(systemName: "person.circle.fill")
        profileImg.tintColor = .lightGray

        if let profileUrlStr = thread.user?.profileImageUrl,
           let url = URL(string: profileUrlStr) {
            profileImageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.profileImg.image = img }
            }
            profileImageTask?.resume()
        }

        if let imageUrlStr = thread.imageUrl, let url = URL(string: imageUrlStr) {
            threadImg.isHidden = false
            threadImg.image = nil
            threadImageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.threadImg.image = img }
            }
            threadImageTask?.resume()
        } else {
            threadImg.image = nil
            threadImg.isHidden = true
        }

        likesButton.setTitle("\(thread.likesCount)", for: .normal)
        let liked = thread.isLiked ?? false
        let image = liked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        likesButton.setImage(image, for: .normal)
        likesButton.tintColor = liked ? .systemRed : .systemBlue

        commentsButton.setTitle("\(thread.commentsCount)", for: .normal)
        sharesButton.setTitle("\(thread.sharesCount)", for: .normal)

        tagsStackView.arrangedSubviews.forEach {
            tagsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let tags = Array((thread.tags ?? []).prefix(3))
        tagsStackView.isHidden = tags.isEmpty
        for tag in tags {
            let label = makeTagLabel(text: tag)
            tagsStackView.addArrangedSubview(label)
        }
        let spacer = UIView()
        spacer.backgroundColor = .clear
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tagsStackView.addArrangedSubview(spacer)

        setupMoreMenu()
    }

    @objc private func handleUsernameTap() {
        onUsernameTapped?()
    }

    private func setupMoreMenu() {
        var actions: [UIAction] = []

        if isOwnPost {
            let deleteAction = UIAction(
                title: "Delete post",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.onDeleteTapped?()
            }
            actions.append(deleteAction)
        } else {
            let followTitle = isFollowingUser ? "Unfollow" : "Follow"
            let followImageName = isFollowingUser ? "person.badge.minus" : "person.badge.plus"
            let followAction = UIAction(
                title: followTitle,
                image: UIImage(systemName: followImageName)
            ) { [weak self] _ in
                self?.onFollowTapped?()
            }
            actions.append(followAction)
        }

        let bookmarkTitle = isBookmarked ? "Saved" : "Bookmark"
        let bookmarkIcon = isBookmarked ? "bookmark.fill" : "bookmark"
        let bookmarkAction = UIAction(
            title: bookmarkTitle,
            image: UIImage(systemName: bookmarkIcon)
        ) { [weak self] _ in
            self?.onBookmarkTapped?()
        }
        actions.append(bookmarkAction)

        moreButton.menu = UIMenu(title: "", children: actions)
        moreButton.showsMenuAsPrimaryAction = true
    }
}
