import UIKit

// swiftlint:disable file_length

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    // MARK: - Data (now backed by API)
    fileprivate var forYouThreads: [APIThread] = []
    fileprivate var followingThreads: [APIThread] = []
    fileprivate var myThreads: [APIThread] = []
    fileprivate var currentUserProfile: APIUserProfileResponse?
    fileprivate var followingUserIds: Set<String> = []
    fileprivate var bookmarkedThreadIds: Set<String> = []
    fileprivate var selectedSegment: ThreadsSegment = .forYou

    fileprivate var currentUserId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    fileprivate var authToken: String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentControl.selectedSegmentIndex = 0
        setupCollectionView()

        let bg = UIColor(white: 250/255, alpha: 1)
        view.backgroundColor = bg
        collectionView.backgroundColor = bg

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFeed),
            name: .threadCreated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFeed),
            name: .commentAdded,
            object: nil
        )

        loadThreads()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }

    // MARK: - Actions

    @objc private func refreshFeed() {
        loadThreads()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedSegment = .forYou
        case 1: selectedSegment = .following
        case 2: selectedSegment = .myThreads
        default: break
        }
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.reloadData()
    }

    @IBAction func didTapSearchButton(_ sender: UIBarButtonItem) {
        let searchVC = ThreadsSearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }

    @IBAction func didTapPlusButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCreatePost", sender: nil)
    }

    // MARK: - CollectionView Setup

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            UINib(nibName: "collectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "collectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "MyThreadsProfileHeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView"
        )

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        // Pull to Refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        loadThreads()
    }
}

// MARK: - DataSource
extension threadsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentThreads().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell", for: indexPath
        ) as? collectionViewCell else {
            return UICollectionViewCell()
        }

        let thread = currentThreads()[indexPath.item]
        let isOwnPost = thread.userId == currentUserId
        let isFollowing = followingUserIds.contains(thread.userId)

        cell.isBookmarked = bookmarkedThreadIds.contains(thread.id)
        cell.configure(with: thread, isFollowing: isFollowing, isOwnPost: isOwnPost)
        cell.applyStyle(isCard: selectedSegment != .myThreads)

        configureLikeAction(for: cell, thread: thread, indexPath: indexPath)

        configureFollowAction(for: cell, thread: thread)

        configureUsernameAction(for: cell, thread: thread)

        configureCommentAction(for: cell, thread: thread)

        configureDeleteAction(for: cell, thread: thread)

        configureBookmarkAction(for: cell, thread: thread)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
            for: indexPath
        ) as? MyThreadsProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        let userName = currentUserProfile?.name ?? currentUserProfile?.username ?? "Loading..."
        let profileImage = currentUserProfile?.profileImageUrl
        let followers = currentUserProfile?.followersCount ?? 0
        let following = currentUserProfile?.followingCount ?? 0

        header.configure(
            userName: userName,
            profileImage: profileImage,
            posts: myThreads.count,
            followers: followers,
            following: following
        )

        header.onFollowersTapped = { [weak self] in
            guard let self, let userId = self.currentUserId else { return }
            let vc = FollowersFollowingViewController()
            vc.initialSegment = 0
            vc.targetUserId = userId
            self.navigationController?.pushViewController(vc, animated: true)
        }

        header.onFollowingTapped = { [weak self] in
            guard let self, let userId = self.currentUserId else { return }
            let vc = FollowersFollowingViewController()
            vc.initialSegment = 1
            vc.targetUserId = userId
            self.navigationController?.pushViewController(vc, animated: true)
        }

        return header
    }
}

// MARK: - FlowLayout
extension threadsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard selectedSegment == .myThreads else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 120)
    }
}

// MARK: - Delegate
extension threadsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let thread = currentThreads()[indexPath.item]
        let detailVC = ThreadDetailViewController()
        detailVC.thread = thread   // already takes APIThread
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Data Fetching
extension threadsViewController {

    fileprivate func loadThreads() {
        loadFollowingUserIds()
        loadForYouThreads()
        loadFollowingThreads()
        loadMyThreads()
        loadUserProfile()
        loadBookmarkStates()
    }

    private func loadBookmarkStates() {
        guard let token = authToken else { return }
        APIService.shared.fetchBookmarkedThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let bookmarked) = result {
                    self?.bookmarkedThreadIds = Set(bookmarked.compactMap { $0.threadId })
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    private func loadFollowingUserIds() {
        guard let token = authToken, let userId = currentUserId else { return }
        APIService.shared.fetchUserFollowing(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let users) = result {
                    self?.followingUserIds = Set(users.map { $0.id })
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    private func loadForYouThreads() {
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.forYouThreads = threads
                    if self?.selectedSegment == .forYou { self?.collectionView.reloadData() }
                }
            }
        }
    }

    fileprivate func loadFollowingThreads() {
        guard let token = authToken else { return }
        APIService.shared.fetchFollowingThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.followingThreads = threads
                    if self?.selectedSegment == .following { self?.collectionView.reloadData() }
                }
            }
        }
    }

    private func loadMyThreads() {
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.myThreads = threads.filter { $0.userId == self?.currentUserId }
                    if self?.selectedSegment == .myThreads { self?.collectionView.reloadData() }
                }
            }
        }
    }

    fileprivate func loadUserProfile() {
        guard let token = authToken, let userId = currentUserId else { return }
        APIService.shared.fetchUserProfile(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let profile) = result {
                    self?.currentUserProfile = profile
                    if self?.selectedSegment == .myThreads { self?.collectionView.reloadData() }
                }
            }
        }
    }

    fileprivate func currentThreads() -> [APIThread] {
        switch selectedSegment {
        case .forYou:    return forYouThreads
        case .following: return followingThreads
        case .myThreads: return myThreads
        }
    }

    fileprivate func updateThreadLikeState(threadId: String, isLiked: Bool, count: Int) {
        if let idx = forYouThreads.firstIndex(where: { $0.id == threadId }) {
            forYouThreads[idx].isLiked = isLiked
            forYouThreads[idx].likesCount = count
        }
        if let idx = followingThreads.firstIndex(where: { $0.id == threadId }) {
            followingThreads[idx].isLiked = isLiked
            followingThreads[idx].likesCount = count
        }
        if let idx = myThreads.firstIndex(where: { $0.id == threadId }) {
            myThreads[idx].isLiked = isLiked
            myThreads[idx].likesCount = count
        }
    }

    private func handleBookmarkFoldersSuccess(apiFolders: [APIFolder], thread: APIThread, token: String) {
        let folderItems = apiFolders.map { folder in
            BookmarkItem(
                icon: UIImage(systemName: "folder") ?? UIImage(),
                id: folder.id,
                title: folder.name
            )
        }

        let sheetVC = SaveArticleSheetViewController(
            folders: folderItems,
            articleTitle: thread.title,
            sheetTitle: "Save Thread"
        ) { [weak self] folderTitle in
            guard let self else { return }
            guard let selectedFolder = apiFolders.first(where: { $0.name == folderTitle }) else { return }

            let payload = APICreateBookmarkedThreadRequest(
                folderId: selectedFolder.id,
                threadId: thread.id,
                title: thread.title,
                description: thread.description,
                imageName: thread.imageName ?? thread.imageUrl ?? "",
                tags: thread.tags ?? []
            )

            APIService.shared.createBookmarkedThread(payload: payload, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.bookmarkedThreadIds.insert(thread.id)
                        self?.collectionView.reloadData()
                        self?.showToast(message: "Saved to \(folderTitle)")
                    case .failure(let error):
                        print("[Bookmark] createBookmarkedThread failed: \(error)")
                        if case .server(let code, _) = error, code == 409 {
                            self?.showToast(message: "Already saved in \(folderTitle)")
                        } else {
                            self?.showToast(message: "Failed to save")
                        }
                    }
                }
            }
        }

        sheetVC.modalPresentationStyle = .pageSheet
        if #available(iOS 16.0, *) {
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
            }
        }

        present(sheetVC, animated: true)
    }

    fileprivate func presentBookmarkSheet(for thread: APIThread) {
        guard let token = authToken else { return }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        APIService.shared.fetchBookmarkFolders(token: token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let apiFolders):
                handleBookmarkFoldersSuccess(apiFolders: apiFolders, thread: thread, token: token)

            case .failure:
                self.showToast(message: "Could not load folders")
            }
        }
    }
}

// MARK: - Cell Configuration
extension threadsViewController {

    fileprivate func configureLikeAction(for cell: collectionViewCell, thread: APIThread, indexPath: IndexPath) {
        cell.onLikeTapped = { [weak self, weak cell] in
            guard let self, let token = self.authToken else { return }

            let currentThreadList = self.currentThreads()
            guard indexPath.item < currentThreadList.count else { return }
            let latestThread = currentThreadList[indexPath.item]
            guard latestThread.id == thread.id else { return }

            let wasLiked = latestThread.isLiked ?? false
            let newLiked = !wasLiked
            let newCount = latestThread.likesCount + (newLiked ? 1 : -1)

            let image = newLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            cell?.likesButton.setImage(image, for: .normal)
            cell?.likesButton.tintColor = newLiked ? .systemRed : .systemBlue
            cell?.likesButton.setTitle("\(max(0, newCount))", for: .normal)

            self.updateThreadLikeState(threadId: latestThread.id, isLiked: newLiked, count: newCount)

            APIService.shared.toggleLike(threadId: latestThread.id, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self.updateThreadLikeState(
                            threadId: latestThread.id,
                            isLiked: response.liked,
                            count: response.likesCount
                        )
                    case .failure:
                        self.updateThreadLikeState(threadId: latestThread.id, isLiked: wasLiked, count: latestThread.likesCount)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }

    fileprivate func configureFollowAction(for cell: collectionViewCell, thread: APIThread) {
        cell.onFollowTapped = { [weak self] in
            guard let self, let token = self.authToken else { return }
            let authorId = thread.userId

            let wasFollowing = self.followingUserIds.contains(authorId)

            if wasFollowing {
                self.followingUserIds.remove(authorId)
                self.followingThreads.removeAll { $0.userId == authorId }
            } else {
                self.followingUserIds.insert(authorId)
            }

            self.collectionView.reloadData()

            APIService.shared.updateFollow(followingId: authorId, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.loadFollowingThreads()
                        self.loadUserProfile()
                    case .failure:
                        if wasFollowing {
                            self.followingUserIds.insert(authorId)
                        } else {
                            self.followingUserIds.remove(authorId)
                        }
                        self.loadFollowingThreads()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    fileprivate func configureUsernameAction(for cell: collectionViewCell, thread: APIThread) {
        cell.onUsernameTapped = { [weak self] in
            guard let self else { return }
            guard thread.userId != self.currentUserId else { return }
            let profileVC = BloggerProfileViewController()
            profileVC.bloggerUserId = thread.userId
            profileVC.bloggerUserName = thread.user?.name ?? thread.user?.username ?? thread.userId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }

    fileprivate func configureCommentAction(for cell: collectionViewCell, thread: APIThread) {
        cell.onCommentTapped = { [weak self] in
            guard let self else { return }
            let vc = CommentsViewController()
            vc.threadId = thread.id
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 40
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.selectedDetentIdentifier = .medium
            }
            self.present(vc, animated: true)
        }
    }

    fileprivate func configureDeleteAction(for cell: collectionViewCell, thread: APIThread) {
        cell.onDeleteTapped = { [weak self] in
            guard let self, let token = self.authToken else { return }
            let alert = UIAlertController(title: "Delete Post", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                APIService.shared.deleteThread(threadId: thread.id, token: token) { result in
                    DispatchQueue.main.async {
                        if case .success = result { self.loadThreads() }
                    }
                }
            })
            self.present(alert, animated: true)
        }
    }

    fileprivate func configureBookmarkAction(for cell: collectionViewCell, thread: APIThread) {
        cell.onBookmarkTapped = { [weak self] in
            guard let self else { return }

            if self.bookmarkedThreadIds.contains(thread.id) {
                guard let token = self.authToken else { return }

                self.bookmarkedThreadIds.remove(thread.id)
                self.collectionView.reloadData()

                APIService.shared.deleteBookmarkedThreadByThreadId(
                    threadId: thread.id, token: token
                ) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.showToast(message: "Removed from bookmarks")
                        case .failure:
                            self?.bookmarkedThreadIds.insert(thread.id)
                            self?.collectionView.reloadData()
                            self?.showToast(message: "Failed to remove")
                        }
                    }
                }
            } else {
                self.presentBookmarkSheet(for: thread)
            }
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let threadCreated = Notification.Name("threadCreated")
}
