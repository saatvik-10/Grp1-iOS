//
//  ChatDetailViewController.swift
//  Grp1-iOS
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FoundationModels

// MARK: - Delegate

protocol HomeChatDetailViewControllerDelegate: AnyObject {
    func chatDetail(_ vc: HomeChatDetailViewController, didCreateNewChatWithFirstQuestion question: String)
}

// MARK: - View Controller

class HomeChatDetailViewController: MessagesViewController {

    var articleID: Int?
    var dominantColor: UIColor?
    private var lastQuestion: String?
    private var lastAnswer: String?
    weak var delegate: HomeChatDetailViewControllerDelegate?

    var chatTitle: String?
    var isNewChat: Bool = false

    let currentUser = Sender(senderId: "self", displayName: "")
    let botSender   = Sender(senderId: "bot", displayName: "")

    var messages: [Message] = []

    // MARK: - Foundation Model
    private let messageGenerator = ChatMessageGenerator()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        messagesCollectionView.backgroundColor = .systemBackground
        messageInputBar.backgroundView.backgroundColor = .systemBackground

        title = chatTitle ?? "Chat"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let smallFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        navigationController?.navigationBar.titleTextAttributes = [.font: smallFont]

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.backgroundColor = dominantColor

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        messagesCollectionView.addGestureRecognizer(tapGesture)

        configureMessageInputBar()

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }

        loadInitialMessages()

        messageGenerator.prewarmModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !messages.isEmpty {
            messagesCollectionView.scrollToLastItem(animated: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    // MARK: - Setup

    private func configureMessageInputBar() {
        messageInputBar.delegate = self

        messageInputBar.inputTextView.placeholder = "Type a message..."
        messageInputBar.inputTextView.placeholderTextColor = UIColor.systemGray3
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.inputTextView.isUserInteractionEnabled = true
        messageInputBar.inputTextView.isEditable = true
        messageInputBar.inputTextView.isScrollEnabled = true

        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.tintColor = .systemBlue

        messageInputBar.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }

    @objc private func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }

    // MARK: - Messages

    private func loadInitialMessages() {
        if isNewChat {
            messages = []
        } else {
            let welcome = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text("Hi! Ask me anything about this article.")
            )
            messages = [welcome]
        }
        messagesCollectionView.reloadData()
    }

    /// Inserts a "typing..." placeholder, queries the model, then replaces it with the real answer.
    private func sendBotReply(for userQuestion: String) {
        // 1. Insert typing placeholder
        let placeholderIndex = messages.count
        let placeholder = Message(
            sender: botSender,
            messageId: "typing",
            kind: .text("...")
        )
        messages.append(placeholder)
        messagesCollectionView.insertSections([placeholderIndex])
        messagesCollectionView.scrollToLastItem(animated: true)

        // 2. Ask the model
        Task { @MainActor in
            let reply = await messageGenerator.sendMessage(userQuestion)

            // 3. Replace placeholder with real answer
            let botMessage = Message(
                sender: self.botSender,
                messageId: UUID().uuidString,
                kind: .text(reply)
            )
            self.lastAnswer = reply
            self.messages[placeholderIndex] = botMessage
            self.messagesCollectionView.reloadSections([placeholderIndex])
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    // MARK: - Actions

    @IBAction func doneTapped(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss(animated: true)
    }

    @IBAction func postTapped(_ sender: UIButton) {
        guard
            let articleID = articleID,
            let question = lastQuestion,
            let answer = lastAnswer
        else { return }

        sender.isEnabled = false

        APIService.shared.postArticleChatQuestion(question: question, answer: answer) { [weak self] result in
            DispatchQueue.main.async {
                sender.isEnabled = true

                switch result {
                case .success:
                    NewsDataStore.shared.addQA(for: articleID, question: question, answer: answer)

                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                    UIView.animate(withDuration: 0.2, animations: {
                        self?.view.alpha = 0.95
                    }, completion: { _ in
                        self?.dismiss(animated: true)
                    })

                case .failure:
                    NewsDataStore.shared.addQA(for: articleID, question: question, answer: answer)

                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)

                    let alert = UIAlertController(
                        title: "Notice",
                        message: "Q&A saved locally but failed to sync with server. Try again later.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        UIView.animate(withDuration: 0.2, animations: {
                            self?.view.alpha = 0.95
                        }, completion: { _ in
                            self?.dismiss(animated: true)
                        })
                    }))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - MessagesDataSource

extension HomeChatDetailViewController: MessagesDataSource {

    var currentSender: SenderType { currentUser }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? { nil }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? { nil }
}

// MARK: - MessagesLayoutDelegate & MessagesDisplayDelegate

extension HomeChatDetailViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        message.sender.senderId == currentUser.senderId ? AppTheme.shared.dominantColor : .systemGray5
    }

    func textColor(for message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        message.sender.senderId == currentUser.senderId ? .white : .label
    }

    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> CGFloat { 16 }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath,
                                  in messagesCollectionView: MessagesCollectionView) -> CGFloat { 0 }
}

// MARK: - InputBarAccessoryViewDelegate

extension HomeChatDetailViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        lastQuestion = trimmed

        // Handle new chat first message
        if isNewChat {
            delegate?.chatDetail(self, didCreateNewChatWithFirstQuestion: trimmed)
            isNewChat = false

            let welcome = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text("Hi! Ask me anything about this article.")
            )
            messages.append(welcome)
            messagesCollectionView.insertSections([messages.count - 1])
        }

        // Append user message
        let userMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            kind: .text(trimmed)
        )
        messages.append(userMessage)

        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()

        messagesCollectionView.insertSections([messages.count - 1])
        messagesCollectionView.scrollToLastItem(animated: true)

        // Get bot reply from Foundation Model
        sendBotReply(for: trimmed)
    }
}
