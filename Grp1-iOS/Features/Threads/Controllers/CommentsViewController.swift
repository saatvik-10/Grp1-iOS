import UIKit

// MARK: - Native Input Accessory View
final class CommentInputAccessoryView: UIView {

    var onSend: ((String) -> Void)?
    var onEmojiTapped: ((String) -> Void)?

    private let emojiBar = UIView()
    private let inputRow = UIView()
    let avatarImageView = UIImageView()
    let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        autoresizingMask = .flexibleHeight
        setupEmojiBar()
        setupInputRow()
    }

    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 116)
    }

    private func setupEmojiBar() {
        emojiBar.translatesAutoresizingMaskIntoConstraints = false
        emojiBar.backgroundColor = .systemBackground
        addSubview(emojiBar)

        let emojis = ["😂", "😭", "😏", "💕"]
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually

        for emoji in emojis {
            let btn = UIButton(type: .system)
            btn.setTitle(emoji, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 26)
            btn.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }

        emojiBar.addSubview(stack)
        NSLayoutConstraint.activate([
            emojiBar.topAnchor.constraint(equalTo: topAnchor),
            emojiBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiBar.heightAnchor.constraint(equalToConstant: 52),

            stack.centerXAnchor.constraint(equalTo: emojiBar.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: emojiBar.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: emojiBar.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: emojiBar.trailingAnchor, constant: -32)
        ])
    }

    private func setupInputRow() {
        inputRow.translatesAutoresizingMaskIntoConstraints = false
        inputRow.backgroundColor = .systemBackground
        addSubview(inputRow)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray5
        inputRow.addSubview(divider)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .systemGray4
        avatarImageView.image = UIImage(named: "beach_1") ?? UIImage(systemName: "person.circle.fill")
        inputRow.addSubview(avatarImageView)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Add a comment......"
        textField.font = .systemFont(ofSize: 15)
        textField.returnKeyType = .send
        inputRow.addSubview(textField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        inputRow.addSubview(sendButton)

        NSLayoutConstraint.activate([
            inputRow.topAnchor.constraint(equalTo: emojiBar.bottomAnchor),
            inputRow.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputRow.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputRow.bottomAnchor.constraint(equalTo: bottomAnchor),
            inputRow.heightAnchor.constraint(equalToConstant: 64),

            divider.topAnchor.constraint(equalTo: inputRow.topAnchor),
            divider.leadingAnchor.constraint(equalTo: inputRow.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: inputRow.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            avatarImageView.leadingAnchor.constraint(equalTo: inputRow.leadingAnchor, constant: 24),
            avatarImageView.centerYAnchor.constraint(equalTo: inputRow.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            textField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: inputRow.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: inputRow.trailingAnchor, constant: -30),
            sendButton.centerYAnchor.constraint(equalTo: inputRow.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func emojiTapped(_ sender: UIButton) {
        guard let emoji = sender.title(for: .normal) else { return }
        onEmojiTapped?(emoji)
    }

    @objc private func sendTapped() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onSend?(text)
        textField.text = ""
    }
}

// MARK: - CommentsViewController
final class CommentsViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView()
    private let commentInputView = CommentInputAccessoryView(
        frame: CGRect(x: 0, y: 0, width: 0, height: 116)
    )

    // MARK: - Native inputAccessoryView — keyboard moves it automatically
    override var inputAccessoryView: UIView? { commentInputView }
    override var canBecomeFirstResponder: Bool { true }

    // MARK: - Data
    var threadId: String = ""
    private var comments: [APIThreadComment] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupTableView()
        loadComments()
        setupInputCallbacks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserAvatar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    private func loadUserAvatar() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else { return }

        APIService.shared.fetchUserProfile(userId: userId, token: token) { [weak self] result in
            if case .success(let profile) = result,
               let urlStr = profile.profileImageUrl,
               let url = URL(string: urlStr) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.commentInputView.avatarImageView.image = img
                        }
                    }
                }.resume()
            }
        }
    }

    // MARK: - Header
    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text = "Comments"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

//        let closeButton = UIButton(type: .system)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .label
//        closeButton.backgroundColor = .systemGray5
//        closeButton.layer.cornerRadius = 18
//        closeButton.clipsToBounds = true
//        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBackground
        headerView.tag = 99
        headerView.addSubview(titleLabel)
    //    headerView.addSubview(closeButton)
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),

//            closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            closeButton.widthAnchor.constraint(equalToConstant: 36),
//            closeButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    // MARK: - TableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "CommentCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(tableView)

        guard let headerView = view.viewWithTag(99) else { return }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Input Callbacks
    private func setupInputCallbacks() {
        commentInputView.onSend = { [weak self] text in
            guard let self, let token = UserDefaults.standard.string(forKey: "authToken") else { return }
            let payload = APICreateCommentRequest(threadId: self.threadId, description: text)
            APIService.shared.createComment(payload: payload, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.loadComments()
                        NotificationCenter.default.post(name: .commentAdded, object: nil)
                        self?.commentInputView.textField.text = ""
                    case .failure(let error):
                        print("❌ Failed to add comment: \(error)")
                    }
                }
            }
        }

        commentInputView.onEmojiTapped = { [weak self] emoji in
            guard let self else { return }
            let current = self.commentInputView.textField.text ?? ""
            self.commentInputView.textField.text = current + emoji
            self.commentInputView.textField.becomeFirstResponder()
        }

        commentInputView.textField.delegate = self
    }

    // MARK: - Data
    private func loadComments() {
        guard !threadId.isEmpty else { return }
        let token = UserDefaults.standard.string(forKey: "authToken")
        APIService.shared.fetchComments(threadId: threadId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let apiComments):
                    self?.comments = apiComments
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("❌ Failed to load comments: \(error)")
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return true }

        textField.resignFirstResponder()
        commentInputView.onSend?(text)
        return true
    }
}

// MARK: - UITableViewDataSource
extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CommentCell", for: indexPath
        ) as? CommentTableViewCell else { return UITableViewCell() }
        let comment = comments[indexPath.row]
        cell.configure(with: comment)

        return cell
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let commentAdded = Notification.Name("commentAdded")
}
