import UIKit

// MARK: - Save Article Sheet

class SaveArticleSheetViewController: UIViewController {

    private let folders: [BookmarkItem]
    private let articleTitle: String
    private let sheetTitle: String
    private let onFolderSelected: (String) -> Void

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    init(folders: [BookmarkItem], articleTitle: String, sheetTitle: String = "Save Article", onFolderSelected: @escaping (String) -> Void) {
        self.folders = folders
        self.articleTitle = articleTitle
        self.sheetTitle = sheetTitle
        self.onFolderSelected = onFolderSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        let titleLabel = UILabel()
        titleLabel.text = sheetTitle
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        headerStack.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose a folder to save this \(sheetTitle.lowercased().contains("thread") ? "thread" : "article")"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        headerStack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let layout = UICollectionViewFlowLayout()

        let horizontalPadding: CGFloat = 20
        let interItemSpacing: CGFloat = 12

        let totalPadding = (horizontalPadding * 2) + interItemSpacing
        let itemWidth = (UIScreen.main.bounds.width - totalPadding) / 2

        layout.itemSize = CGSize(width: itemWidth, height: 140)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: horizontalPadding, bottom: 20, right: horizontalPadding)

        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FolderCell.self, forCellWithReuseIdentifier: "FolderCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SaveArticleSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as? FolderCell else {
            return UICollectionViewCell()
        }
        let bookmark = folders[indexPath.item]
        cell.configure(with: bookmark.title, icon: bookmark.icon)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFolder = folders[indexPath.item]

        UIView.animate(withDuration: 0.2, animations: {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    cell.transform = .identity
                }
            }
        })

        onFolderSelected(selectedFolder.title)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
}
