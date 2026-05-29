import UIKit

class AddInterestViewController: UIViewController {
    var interestType: InterestType = .domain
    var sourceItems: [InterestModel] = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var filteredItems: [InterestModel] = []
    private var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = interestType.title
        searchBar.placeholder = interestType.searchPlaceholder
        searchBar.delegate = self

        setupTableView()
        filteredItems = sourceItems
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @IBAction func closeModal(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension AddInterestViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredItems.count : sourceItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = isSearching ? filteredItems[indexPath.row] : sourceItems[indexPath.row]

        var config = cell.defaultContentConfiguration()

        config.text = item.title
        config.textProperties.font = UIFont.preferredFont(forTextStyle: .title3)

        config.secondaryText = item.subtitle
        config.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        config.secondaryTextProperties.color = .secondaryLabel

        if let iconName = item.icon {
            config.image = UIImage(systemName: iconName)
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = isSearching ? filteredItems[indexPath.row] : sourceItems[indexPath.row]
        print("Selected: \(item.title)")

        switch interestType {
        case .domain:
            if !UserInterests.domains.contains(where: { $0.title == item.title }) {
                UserInterests.domains.append(item)
            }
        case .preference:
            if !UserInterests.preferences.contains(where: { $0.title == item.title }) {
                UserInterests.preferences.append(item)
            }
        }

        NotificationCenter.default.post(name: .userInterestsDidChange, object: nil)
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension AddInterestViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredItems = sourceItems
        } else {
            isSearching = true
            filteredItems = sourceItems.filter { item in
                item.title.lowercased().contains(searchText.lowercased()) ||
                (item.subtitle?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredItems = sourceItems
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
