//
//  ChatDetailViewController.swift
//  ChatScreen
//
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - View Controller

protocol ChatDetailViewControllerDelegate: AnyObject {
    func chatDetail(_ vc: ChatDetailViewController, didCreateNewChatWithFirstQuestion question: String)
}

class ChatDetailViewController: MessagesViewController {

    weak var delegate: ChatDetailViewControllerDelegate?
    var chatTitle: String?
    var isNewChat: Bool = false

    // current user & bot
    let currentUser = Sender(senderId: "self", displayName: "")
    let botSender   = Sender(senderId: "bot", displayName: "")

    // all messages shown in chat
    var messages: [Message] = []

    var selectedMessageIndex: Int = 0

    let mockBotReplies = MockBotReplies.replies
    var botReplyIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = chatTitle ?? "Chat"

        let smallFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            navigationController?.navigationBar.titleTextAttributes = [
                .font: smallFont
            ]

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.backgroundColor = .systemGray6

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        messagesCollectionView.addGestureRecognizer(tapGesture)

        configureMessageInputBar()

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }

        loadDummyMessages()
    }

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
        messageInputBar.sendButton.setTitle("", for: .normal)  // Remove text
        messageInputBar.sendButton.tintColor = .systemBlue

        messageInputBar.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }

    @objc private func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !messages.isEmpty {
            messagesCollectionView.scrollToLastItem(animated: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    private func loadDummyMessages() {

        if isNewChat {
            messages = []
            botReplyIndex = 0
        } else {
            let m1 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[0])
            )

            let m2 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                kind: .text("I want to understand the repo rate limit. Can you help me?")
            )

            let m3 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[1])
            )

            let m4 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                kind: .text("How does repo rate affect the banks ?")
            )

            let m5 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[2])
            )
            let m6 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                kind: .text("How does it affect my Home loans, interests rate ? ")
            )
            let m7 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[3])
            )

            messages = [m1, m2, m3, m4, m5, m6, m7]
            botReplyIndex = 4
        }
        messagesCollectionView.reloadData()
    }

    private func sendNextBotReply() {
        guard botReplyIndex < mockBotReplies.count else { return }

        let text = mockBotReplies[botReplyIndex]
        botReplyIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let message = Message(
                sender: self.botSender,
                messageId: UUID().uuidString,
                kind: .text(text))

            self.messages.append(message)
            self.messagesCollectionView.insertSections([self.messages.count - 1])
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    // MARK: - Menu Actions

    @objc private func copyMessageAction() {
        guard selectedMessageIndex < messages.count else { return }
        let message = messages[selectedMessageIndex]

        if case .text(let text) = message.kind {
            UIPasteboard.general.string = text
            chatBotShowToast(message: "Copied to clipboard")
        }
    }

    private func chatBotShowToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            alert.dismiss(animated: true)
        }
    }
}

// MARK: - MessagesDataSource

extension ChatDetailViewController: MessagesDataSource {

    var currentSender: SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
}

// MARK: - MessagesLayoutDelegate & MessagesDisplayDelegate

extension ChatDetailViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return UIColor.systemBlue
        } else {
            return UIColor.systemGray5
        }
    }

    func textColor(for message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return .white
        } else {
            return .label
        }
    }

    // Configure message style
//    func messageStyle(for message: MessageType,
//                      at indexPath: IndexPath,
//                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        let corner: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId ? .bottomRight : .bottomLeft
//        return .bubbleTail(corner, .curved)
//    }

    // MARK: - Layout Delegate Methods

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath,
                                  in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    private func avatarSize(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGSize {
        return .zero
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // user message
        if isNewChat {
            delegate?.chatDetail(self, didCreateNewChatWithFirstQuestion: trimmed)
            isNewChat = false

            let welcomeMsg = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[0])
            )
            messages.append(welcomeMsg)
            messagesCollectionView.insertSections([messages.count - 1])
            botReplyIndex = 1
        }

        let newMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            kind: .text(trimmed)
        )
        messages.append(newMessage)

        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()

        messagesCollectionView.insertSections([messages.count - 1])
        messagesCollectionView.scrollToLastItem(animated: true)

        sendNextBotReply()
    }
}
