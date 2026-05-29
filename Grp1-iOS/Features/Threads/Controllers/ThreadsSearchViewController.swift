//
//  SearchViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 25/02/26.
//

import UIKit

class ThreadsSearchViewController: UIViewController {

    // MARK: - Properties
    private var allPosts: [APIThread] = []
    private var filteredPosts: [APIThread] = []
    private var isSearchActive = false

    // MARK: - UI
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search posts, tags, users..."
        sc.searchBar.returnKeyType = .search
        sc.searchBar.delegate = self
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(white: 250/255, alpha: 1)
        tv.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseID)
        tv.delegate = self
        tv.dataSource = self
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No results found"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Try searching by title, tag, or username"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        return view
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Search across all posts, tags and users"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = UIColor(white: 250/255, alpha: 1)

        setupNavigationSearch()
        setupLayout()
        fetchLatestPosts()
    }

    private func fetchLatestPosts() {
        APIService.shared.fetchForYouThreads(token: UserDefaults.standard.string(forKey: "authToken")) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let threads):
                    self?.allPosts = threads
                case .failure(let error):
                    print("❌ Search failed to fetch posts: \(error)")
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Auto-activate search bar when screen appears
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Setup
    private func setupNavigationSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    // MARK: - Search Logic
    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else {
            filteredPosts = []
            isSearchActive = false
            updateUI()
            return
        }

        isSearchActive = true
        filteredPosts = allPosts.filter { post in
            post.title.lowercased().contains(trimmed) ||
            (post.user?.name ?? "").lowercased().contains(trimmed) ||
            (post.user?.username ?? "").lowercased().contains(trimmed) ||
            (post.tags ?? []).contains { $0.lowercased().contains(trimmed) }
        }
        updateUI()
    }

    private func updateUI() {
        hintLabel.isHidden = isSearchActive
        tableView.isHidden = false

        if isSearchActive && filteredPosts.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
        }

        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension ThreadsSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredPosts = []
        isSearchActive = false
        updateUI()
    }
}

// MARK: - UITableViewDataSource
extension ThreadsSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearchActive ? filteredPosts.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultCell.reuseID, for: indexPath
        ) as? SearchResultCell else { return UITableViewCell() }
        cell.configure(with: filteredPosts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ThreadsSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = filteredPosts[indexPath.row]
        let detailVC = ThreadDetailViewController()
        detailVC.thread = post
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - SearchResultCell
class SearchResultCell: UITableViewCell {
    static let reuseID = "SearchResultCell"

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()

    private let profileImg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(profileImg)
        cardView.addSubview(userNameLabel)
        cardView.addSubview(timeAgoLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(tagsLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            profileImg.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            profileImg.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            profileImg.widthAnchor.constraint(equalToConstant: 40),
            profileImg.heightAnchor.constraint(equalToConstant: 40),

            userNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 10),

            timeAgoLabel.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            timeAgoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            titleLabel.topAnchor.constraint(equalTo: profileImg.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            tagsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tagsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            tagsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            tagsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    func configure(with post: APIThread) {
        userNameLabel.text = post.user?.name ?? post.user?.username ?? "Unknown"
        titleLabel.text = post.title
        tagsLabel.text = (post.tags ?? []).prefix(3).map { "#\($0)" }.joined(separator: "  ")

        if let imageUrl = post.user?.profileImageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImg.image = image
                    }
                }
            }.resume()
        } else {
            profileImg.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
