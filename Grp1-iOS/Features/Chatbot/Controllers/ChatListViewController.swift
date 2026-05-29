//
//  ChatListViewController.swift
//  ChatScreen
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class ChatListViewController: UIViewController, ChatDetailViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func newChatButton(_ sender: Any) {
        openChatDetail(withTitle: "New Chat", isNewChat: true)

    }
    var chats: [ChatPreview] = [
        ChatPreview(id: UUID(), title: "What is inflation?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Why does RBI increase the repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Explain the Indian Economy?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Why do stock markets fall when interest rates rise?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is market capitalization?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "How does RBI control money supply", timestamp: Date()),
        ChatPreview(id: UUID(), title: "How does fiscal policy differ from monetary policy?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "How does crude oil price affect inflation?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is NAV in mutual funds?", timestamp: Date())

    ]

    var filteredChats: [ChatPreview] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        filteredChats = chats

        setupTableView()
        setupSearchBar()
        // setupNewChatButton()
    }

    // MARK: - Setup Methods

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag // Dismiss keyboard when scrolling
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search chats..."
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
    }

    // MARK: - Search Logic

    private func filterChats(with searchText: String) {
        if searchText.isEmpty {
            filteredChats = chats
        } else {
            filteredChats = chats.filter { chat in
                chat.title.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    func chatDetail(_ vc: ChatDetailViewController, didCreateNewChatWithFirstQuestion question: String) {
        let newPreview = ChatPreview(
            id: UUID(),
            title: question,
            timestamp: Date()
        )
        chats.insert(newPreview, at: 0)
        filteredChats = chats
        tableView.reloadData()
    }

    // MARK: - Navigation

    private func openChatDetail(withTitle title: String, isNewChat: Bool = false) {
        let chatDetailVC = ChatDetailViewController()
        chatDetailVC.chatTitle = title
        chatDetailVC.isNewChat = isNewChat
        chatDetailVC.delegate = self
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let chat = filteredChats[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = chat.title
        config.secondaryText = chat.timestamp.formatted(date: .numeric, time: .shortened)
        config.textProperties.font = .systemFont(ofSize: 18, weight: .medium)
        config.secondaryTextProperties.color = .gray

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                   -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in

            let alert = UIAlertController(
                title: "Delete Chat?",
                message: "This chat will be permanently removed.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false) // cancel deletion
            })

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in

                // DELETE from your lists
                self.chats.remove(at: indexPath.row)
                self.filteredChats = self.chats

                // DELETE from UI
                tableView.deleteRows(at: [indexPath], with: .automatic)

                completion(true)
            })

            self.present(alert, animated: true)
        }

        deleteAction.image = UIImage(systemName: "trash")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false  // force tap → alert
        return config
    }
}

// MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chat = filteredChats[indexPath.row]
        openChatDetail(withTitle: chat.title, isNewChat: false)
    }
}

// MARK: - UISearchBarDelegate

extension ChatListViewController: UISearchBarDelegate {

    // Called when text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterChats(with: searchText)
    }

    // Called when search button is tapped on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss keyboard
    }

    // Called when cancel button is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterChats(with: "")
    }

    // Optional: Show cancel button when editing begins
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    // Optional: Hide cancel button when editing ends
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
