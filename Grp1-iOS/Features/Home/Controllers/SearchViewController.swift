//
//  SearchViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class SearchViewController: UIViewController {
    private var keyboardShift: CGFloat = 0
    var filteredArticles: [NewsArticle] = []
    var isSearching = false
    private weak var currentHeaderView: recentsHeaderCollectionViewCell?
    @IBOutlet weak var collectionView: UICollectionView!
    private var isKeyboardVisible = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    let newsStore = NewsDataStore.shared
        var articles: [NewsArticle] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        articles = Array(newsStore.getAllNews().sorted { $0.relevanceScore > $1.relevanceScore }.prefix(4))
                setupCollectionView()
        setupSearchBar()
        registerForKeyboardNotifications()
        collectionView.dataSource = self
            collectionView.delegate = self

            collectionView.register(
                UINib(nibName: "RealExploreCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "realexplore_cell"
            )

            collectionView.register(
                UINib(nibName: "recentsHeaderCollectionViewCell", bundle: nil),
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "recents_header"
            )

        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.keyboardDismissMode = .none

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .systemGray6

            collectionView.register(
                UINib(nibName: "RealExploreCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "realexplore_cell"
            )

            collectionView.register(
                UINib(nibName: "RecentsHeaderView", bundle: nil),
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "recents_header"
            )

            collectionView.setCollectionViewLayout(createLayout(), animated: false)
        }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let moveUp = frame.height - view.safeAreaInsets.bottom

        UIView.animate(withDuration: duration) {
            self.searchBar.transform = CGAffineTransform(
                translationX: 0,
                y: -moveUp
            )
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.searchBar.transform = .identity
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension SearchViewController: UISearchBarDelegate {

    func setupSearchBar() {
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.isTranslucent = true
        searchBar.isUserInteractionEnabled = true

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.layer.cornerRadius = 24
            textField.layer.masksToBounds = true

            searchBar.layer.shadowColor = UIColor.black.cgColor
            searchBar.layer.shadowOpacity = 0.1
            searchBar.layer.shadowOffset = CGSize(width: 0, height: 4)
            searchBar.layer.shadowRadius = 6

            textField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
            )
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            isSearching = false
            filteredArticles = []
        } else {
            isSearching = true
            let allArticles = newsStore.getAllNews()
            filteredArticles = allArticles.filter {
                $0.title.lowercased().contains(trimmed.lowercased())
            }
        }

        updateHeaderUI()
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("Search tapped:", searchBar.text ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()

        isSearching = false
        filteredArticles = []
        articles = Array(newsStore.getAllNews().sorted { $0.relevanceScore > $1.relevanceScore }.prefix(4))
        collectionView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func clearSearch() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredArticles = []

        updateHeaderUI()
        collectionView.reloadData()
    }

    private func clearRecentArticles() {
        articles.removeAll()
        collectionView.reloadData()
    }
}

extension SearchViewController {

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 10)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(280))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let headerSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(50)
                        )
                        let header = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: headerSize,
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredArticles.count : articles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "realexplore_cell",
            for: indexPath
        ) as? RealExploreCollectionViewCell else {
            return UICollectionViewCell()
        }

        let article = isSearching
            ? filteredArticles[indexPath.item]
            : articles[indexPath.item]

        cell.configureCell(with: article)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "recents_header",
            for: indexPath
        ) as? recentsHeaderCollectionViewCell else {
            return UICollectionReusableView()
        }

        currentHeaderView = header

        updateHeaderUI()

        header.onClearTapped = { [weak self] in
                self?.clearRecentArticles()
        }

        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = isSearching
               ? filteredArticles[indexPath.item]
               : articles[indexPath.item]

        performSegue(withIdentifier: "searchResult", sender: article)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult",
           let vc = segue.destination as? news1ViewController,
           let article = sender as? NewsArticle {
            vc.article = article
        }
    }

    func updateHeaderUI() {
        guard let header = currentHeaderView else { return }

        header.titleLabel.text = isSearching ? "Results" : "Might Interest You"

        let shouldEnableClear = !isSearching && (searchBar.text?.isEmpty ?? true)

        header.clearButton.isEnabled = shouldEnableClear
        header.clearButton.alpha = shouldEnableClear ? 1.0 : 0
    }

}
