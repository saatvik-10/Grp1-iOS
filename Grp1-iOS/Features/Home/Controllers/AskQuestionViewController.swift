//
//  AskQuestionViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class AskQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputContainer: UIView!

    var messages: [ChatMessage] = [
            ChatMessage(text: "Hi! Ask anything about the article.", isIncoming: true)
        ]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
                tableView.delegate = self
                tableView.separatorStyle = .none
                tableView.register(ChatTableViewCell.nib(), forCellReuseIdentifier: "chat_cell")

                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = 80

        // Do any additional setup after loading the view.
    }

        @IBAction func sendTapped(_ sender: Any) {
            guard let text = textField.text, !text.isEmpty else { return }

            messages.append(ChatMessage(text: text, isIncoming: false))
            textField.text = ""

            tableView.reloadData()
            scrollToBottom()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.messages.append(ChatMessage(text: "Got it! We'll respond soon.", isIncoming: true))
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }

        func scrollToBottom() {
            let index = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath) as? ChatTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: messages[indexPath.row])
            return cell
        }

    @IBAction func doneTapped(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss(animated: true)
    }

}
