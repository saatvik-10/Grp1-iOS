import UIKit

// Kept in this file to avoid Xcode project file updates.
final class AllDomainsViewController: UIViewController {
    var allItems: [InterestModel] = []
    var selectedTitles: Set<String> = []
    var onDone: ((Set<String>) -> Void)?

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var filtered: [InterestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Other Domains"
        view.backgroundColor = .systemBackground

        filtered = allItems

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func doneTapped() {
        onDone?(selectedTitles)
        dismiss(animated: true)
    }
}

extension AllDomainsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

        let item = filtered[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.imageView?.image = item.icon.flatMap { UIImage(systemName: $0) }
        cell.accessoryType = selectedTitles.contains(item.title) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = filtered[indexPath.row].title

        if selectedTitles.contains(title) {
            selectedTitles.remove(title)
        } else {
            selectedTitles.insert(title)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AllDomainsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filtered = allItems
        } else {
            filtered = allItems.filter {
                $0.title.localizedCaseInsensitiveContains(query) || ($0.subtitle?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
        tableView.reloadData()
    }
}

class InterestCollectionViewController: UIViewController {
    var onBackTapped: (() -> Void)?
    var onFinishTapped: (() -> Void)?

    @IBOutlet weak var interestCollectionView: UICollectionView!

    // Domain selection onboarding
    private let domainsPreviewCount = 6
    private let otherCellTitle = "Other"

    private let selectedBlue = UIColor.systemBlue
    private let screenBackground = UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    private func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = screenBackground

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "What are you interested\nin?"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Pick the topics you'd like to track. We'll\ncustomize your investment feed based on these\nselections."
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 3
        subtitleLabel.lineBreakMode = .byWordWrapping

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

        interestCollectionView = collectionView

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(collectionView)

        setupBottomBar(titleLabel: titleLabel, subtitleLabel: subtitleLabel, collectionView: collectionView)
    }

    private func setupBottomBar(titleLabel: UILabel, subtitleLabel: UILabel, collectionView: UICollectionView) {
        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = screenBackground

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("  Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)
        backButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)

        let finishButton = UIButton(type: .system)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.setTitle("Finish  ", for: .normal)
        finishButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        finishButton.semanticContentAttribute = .forceRightToLeft
        finishButton.tintColor = .white
        finishButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        finishButton.backgroundColor = selectedBlue
        finishButton.layer.cornerRadius = 22
        finishButton.layer.shadowColor = selectedBlue.cgColor
        finishButton.layer.shadowOpacity = 0.24
        finishButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        finishButton.layer.shadowRadius = 16
        finishButton.addTarget(self, action: #selector(finishButtonTapped(_:)), for: .touchUpInside)

        view.addSubview(footerView)
        footerView.addSubview(backButton)
        footerView.addSubview(finishButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 120),

            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -24),

            backButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 38),
            backButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 108),
            backButton.heightAnchor.constraint(equalToConstant: 56),

            finishButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            finishButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -38),
            finishButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            finishButton.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
    }

    private func setupCollectionView() {
        interestCollectionView.delegate = self
        interestCollectionView.dataSource = self
        interestCollectionView.register(
            InterestCollectionViewCell.self,
            forCellWithReuseIdentifier: "InterestCollectionViewCell"
        )
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        onBackTapped?()
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        onFinishTapped?()
    }
}

extension InterestCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(domainsPreviewCount, InterestsDataSource.domains.count) + 1 // + "Other"
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "InterestCollectionViewCell",
            for: indexPath
        ) as? InterestCollectionViewCell else { return UICollectionViewCell() }

        let previewCount = min(domainsPreviewCount, InterestsDataSource.domains.count)
        if indexPath.item == previewCount {
            // "Other" cell
            cell.configure(title: otherCellTitle, icon: "ellipsis.circle")
            cell.isSelected = false
        } else {
            let model = InterestsDataSource.domains[indexPath.item]
            cell.configure(title: model.title, icon: model.icon)
            cell.isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true
        }
        return cell
    }
}

extension InterestCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previewCount = min(domainsPreviewCount, InterestsDataSource.domains.count)
        if indexPath.item == previewCount {
            // Don't select the "Other" cell; open full list instead.
            collectionView.deselectItem(at: indexPath, animated: false)
            presentAllDomains()
        }
    }
}

extension InterestCollectionViewController {
    private func presentAllDomains() {
        let vc = AllDomainsViewController()
        vc.allItems = InterestsDataSource.domains

        // Seed with current selections from the grid and any previously chosen.
        var selected = Set(UserInterests.domains.map { $0.title })
        if let indexPaths = interestCollectionView.indexPathsForSelectedItems {
            for idx in indexPaths where idx.item < InterestsDataSource.domains.count {
                selected.insert(InterestsDataSource.domains[idx.item].title)
            }
        }
        vc.selectedTitles = selected

        vc.onDone = { [weak self] titles in
            UserInterests.domains = InterestsDataSource.domains.filter { titles.contains($0.title) }
            NotificationCenter.default.post(name: .userInterestsDidChange, object: nil)

            // Reflect selection back into the preview grid (only for the first N items).
            let previewCount = min(self?.domainsPreviewCount ?? 0, InterestsDataSource.domains.count)
            self?.interestCollectionView.reloadData()
            for index in 0..<previewCount {
                let ip = IndexPath(item: index, section: 0)
                if titles.contains(InterestsDataSource.domains[index].title) {
                    self?.interestCollectionView.selectItem(at: ip, animated: false, scrollPosition: [])
                } else {
                    self?.interestCollectionView.deselectItem(at: ip, animated: false)
                }
            }
        }

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension InterestCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: 156)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        20
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }
}
