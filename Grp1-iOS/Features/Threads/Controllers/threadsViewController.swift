// import UIKit

// enum ThreadsSegment {
//     case forYou
//     case following
//     case myThreads
// }

// class threadsViewController: UIViewController {
    
//     @IBOutlet weak var collectionView: UICollectionView!
    
//     @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
//     private let threadsStore = [APIThread]
        
//     private var forYouThreads: [APIThread] = []
//     private var followingThreads: [APIThread] = []
//     private var selectedSegment: ThreadsSegment = .forYou
        
//     private var currentUserId: String? {
//         UserDefaults.standard.string(forKey: "userId")
//     }
//     private var authToken: String? {
//         UserDefaults.standard.string(forKey: "authToken")
//     }
        
        
//         override func viewDidLoad() {
            
//             super.viewDidLoad()
            
//             segmentControl.selectedSegmentIndex = 0
//             setupCollectionView()
//             loadThreads()
//             testRecommendationEngine()  
            
//             let bg = UIColor(white: 250/255, alpha: 1)
//             view.backgroundColor = bg
//             collectionView.backgroundColor = bg
//             //crosscheck below 2 line
//            // collectionView.delegate = self
//            // collectionView.dataSource = self
//             threadsStore.addComment(to: 1, text: "This helped a lot, thanks!")
//             threadsStore.addComment(to: 1, text: "Can you cover risks next?")
//             NotificationCenter.default.addObserver(self, selector: #selector(refreshFeed), name: .commentAdded, object: nil)
            
            
//         }
//     private func testRecommendationEngine() {
//         var profile = MockEnvironment.shared.ananditaProfile
//         let articles = MockEnvironment.shared.blogArticles(
//             from: ThreadsDataStore.shared.getForYouThreads()
//         )
        
//         let results = BlogRecommendationEngine.shared.recommend(
//             articles: articles,
//             profile: &profile,
//             limit: 20
//         )
        
//         print("\n" + String(repeating: "=", count: 60))
//         print("🎯 RECOMMENDATION ENGINE RESULTS FOR ANANDITA")
//         print(String(repeating: "=", count: 60))
        
//         for (rank, item) in results.enumerated() {
//             print("""
            
//             #\(rank + 1) [\(String(format: "%.1f", item.finalScore))] \(item.article.title)
//                  base: \(String(format: "%.1f", item.baseScore)) | level: ×\(String(format: "%.2f", item.levelMultiplier)) | fresh: ×\(String(format: "%.2f", item.freshnessScore))
//                  tags: \(item.matchedTags.isEmpty ? "none matched" : item.matchedTags.joined(separator: ", "))
//             """)
//         }
//         print(String(repeating: "=", count: 60) + "\n")
//     }
//         override func viewDidLayoutSubviews() {
//             super.viewDidLayoutSubviews()
     
//             if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                 layout.invalidateLayout()
//             }
//         }
      
       
//         @objc private func refreshFeed() {
//             reloadData()
//             collectionView.reloadData()
//         }
        
//         @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//             switch sender.selectedSegmentIndex {
//             case 0: selectedSegment = .forYou
//             case 1: selectedSegment = .following
//             case 2: selectedSegment = .myThreads
//             default: break
//             }
            
//             reloadData()
//             collectionView.setContentOffset(.zero, animated: false)
//             collectionView.reloadData()
//         }
        
//         @IBAction func didTapSearchButton(_ sender: UIBarButtonItem) {
//             let searchVC = ThreadsSearchViewController()
//                navigationController?.pushViewController(searchVC, animated: true)
//         }
        
//         @IBAction func didTapPlusButton(_ sender: UIBarButtonItem) {
//             performSegue(withIdentifier: "showCreatePost", sender: nil)
//         }
        
        
//         private func setupCollectionView() {
//             collectionView.delegate = self
//             collectionView.dataSource = self
            
          
//             collectionView.register(
//                 UINib(nibName: "collectionViewCell", bundle: nil),
//                 forCellWithReuseIdentifier: "collectionViewCell"
//             )
            
            
          
//             collectionView.register(
//                 UINib(nibName: "MyThreadsProfileHeaderCollectionReusableView", bundle: nil),
//                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                 withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView"
//             )
            
//     //        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//     //            layout.scrollDirection = .vertical
//     //            layout.minimumLineSpacing = 20
//     //            layout.minimumInteritemSpacing = 4
//     //            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
//     //            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//     //        }
//             guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                 return
//             }
           
//             layout.scrollDirection = .vertical
//             layout.minimumLineSpacing = 16    //20
//             layout.minimumInteritemSpacing = 12
//             layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
//             layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
     
//         }

//         // MARK: - Load Threads from API

//      private func loadForYouThreads() {
//         APIService.shared.fetchForYouThreads { [weak self] result in
//             DispatchQueue.main.async {
//                 if case .success(let threads) = result {
//                     self?.forYouThreads = threads
//                     if self?.selectedSegment == .forYou { self?.collectionView.reloadData() }
//                 }
//             }
//         }
//     }
    
//     private func loadFollowingThreads() {
//         guard let token = authToken else { return }
//         APIService.shared.fetchFollowingThreads(token: token) { [weak self] result in
//             DispatchQueue.main.async {
//                 if case .success(let threads) = result {
//                     self?.followingThreads = threads
//                     if self?.selectedSegment == .following { self?.collectionView.reloadData() }
//                 }
//             }
//         }
//     }

//     private func loadThreads() {
//         APIService.shared.fetchForYouThreads { [weak self] result in
//             guard let self = self else { return }
            
//             DispatchQueue.main.async {
//                 switch result {
//                 case .success(let apiThreads):
//                     self.threads = apiThreads
//                     self.collectionView.reloadData()  // or tableView.reloadData()
                    
//                 case .failure(let error):
//                     print("❌ Failed to load threads: \(error)")
//                 }
//             }
//         }
//     }

        
        
//         private func reloadData() {
//     //        forYouThreads = threadsStore.getAllThreads()
//     //        followingThreads = threadsStore.getFollowingThreads()
//              forYouThreads = threadsStore.getForYouThreads()
//                 followingThreads = threadsStore.getFollowingThreads()
//         }
       
//     //    private func calculateItemWidth() -> CGFloat {
//     //        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//     //        else {
//     //            return 180
//     //        }
//     //        let totalHorizontalPadding = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
//     //        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
//     //        let itemWidth = floor(availableWidth / 2)
//     //
//     //        return itemWidth
//     //    }
//     }
        
     
     
//         extension threadsViewController: UICollectionViewDataSource {
     
//             func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//                 switch selectedSegment {
//                     case .forYou: return threadsStore.getForYouThreads().count
//                     case .following: return threadsStore.getFollowingThreads().count
//                     case .myThreads: return threadsStore.getMyThreads().count
//                     }
//                }
     
//                func collectionView(
//                    _ collectionView: UICollectionView,
//                    cellForItemAt indexPath: IndexPath
//                ) -> UICollectionViewCell {
                  
//                    let cell = collectionView.dequeueReusableCell(
//                     withReuseIdentifier: "collectionViewCell",
//                     for: indexPath        )
//                    as! collectionViewCell
                   
//                   // let itemWidth = calculateItemWidth()
//                  //  cell.updateWidth(itemWidth)
                   
     
//                    let post: ThreadPost
//                    switch selectedSegment {
//                    case .forYou: post = threadsStore.getForYouThreads()[indexPath.item]
//                    case .following: post = threadsStore.getFollowingThreads()[indexPath.item]
//                    case .myThreads: post = threadsStore.getMyThreads()[indexPath.item]
//                    }
     
//                    let isFollowing = threadsStore.isFollowing(post.userName)
//                    let isOwnPost = post.userName == threadsStore.currentUserName
//                    cell.configure(with: post, isFollowing: isFollowing, isOwnPost: isOwnPost)
//                    cell.applyStyle(isCard: selectedSegment != .myThreads)
                   
//                    cell.onLikeTapped = { [weak self] in
//                        guard let self else { return }
//                        self.threadsStore.toggleLike(for: post.id)
//                        self.reloadData()
//                        self.collectionView.reloadItems(at: [indexPath])
//                    }
                   
//                    cell.onFollowTapped = { [weak self] in
//                        guard let self else { return }
     
//                        self.threadsStore.toggleFollow(post.userName)
     
//                        self.reloadData()
//                        self.collectionView.reloadData()
                       
                       
//                    }
                   
//                    cell.onUsernameTapped = { [weak self] in
//                                           guard let self else { return }
//                                           guard post.userName != self.threadsStore.currentUserName else { return }
//                                           let profileVC = BloggerProfileViewController()
//                                           profileVC.bloggerUserName = post.userName
//                                           self.navigationController?.pushViewController(profileVC, animated: true)
//                                       }
                   
//                    cell.onCommentTapped = { [weak self] in
//                        guard let self else { return }
                       
//                        let vc = CommentsViewController()
//                        vc.postID = post.id
//                        vc.modalPresentationStyle = .pageSheet
//                        // vc.modalPresentationStyle = .overFullScreen
//                        // vc.modalTransitionStyle = .crossDissolve
//                        if let screen = self.view.window?.windowScene?.screen {
//                            vc.preferredContentSize = CGSize(width: screen.bounds.width, height: 0)
//                        }
//                        if let sheet = vc.sheetPresentationController {
//                            //     sheet.detents = [.medium(), .large()]      // 👈 native bottom sheet
//                            sheet.prefersGrabberVisible = true         // small drag indicator
//                            sheet.preferredCornerRadius = 40           // rounded top corners
//                            sheet.largestUndimmedDetentIdentifier = .medium
//                            sheet.selectedDetentIdentifier = .medium
                           
//                            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//                            sheet.prefersEdgeAttachedInCompactHeight = true
                           
//                        }
//                        self.present(vc, animated: true)
//                    }
//                        cell.onDeleteTapped = { [weak self] in
//                            guard let self else { return }
                           
//                            let alert = UIAlertController(
//                                title: "Delete Post",
//                                message: "Are you sure you want to delete this post?",
//                                preferredStyle: .alert
//                            )
                           
//                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                           
//                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
//                                self.threadsStore.deletePost(id: post.id)
//                                self.reloadData()
//                                self.collectionView.reloadData()
//                            })
                           
//                            self.present(alert, animated: true)
//                        }
                           
//                    return cell
//                }
     
               
//                func collectionView(
//                    _ collectionView: UICollectionView,
//                    viewForSupplementaryElementOfKind kind: String,
//                    at indexPath: IndexPath
//                ) -> UICollectionReusableView {
     
//                    let header = collectionView.dequeueReusableSupplementaryView(
//                        ofKind: kind,
//                        withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
//                        for: indexPath
//                    ) as! MyThreadsProfileHeaderCollectionReusableView
     
//                    let user = MockEnvironment.shared.anandita
//                    header.configure(
//                        userName: user.userName,
//                        profileImage: user.profileImage,
//                        posts: threadsStore.getMyThreads().count,
//                        followers: user.followerCount,    // → 20
//                        following: user.followingCount    // → 22
//                    )
     
//                    header.onFollowersTapped = { [weak self] in
//                        guard let self else { return }
//                        let vc = FollowersFollowingViewController()
//                        vc.initialSegment = 0
//                        vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
//                        vc.followingNames = Array(Set(self.threadsStore.getFollowingThreads().map { $0.userName }))
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
     
//                    header.onFollowingTapped = { [weak self] in
//                        guard let self else { return }
//                        let vc = FollowersFollowingViewController()
//                        vc.initialSegment = 1
//                        vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
//                        vc.followingNames = Array(Set(self.threadsStore.getFollowingThreads().map { $0.userName }))
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
     
//                    return header
//                }
//             }
     
        
     
        
//         extension threadsViewController: UICollectionViewDelegateFlowLayout {
            
//     //        func collectionView(
//     //            _ collectionView: UICollectionView,
//     //            layout collectionViewLayout: UICollectionViewLayout,
//     //            sizeForItemAt indexPath: IndexPath
//     //        ) -> CGSize {
//     //           let itemWidth = calculateItemWidth()
//     //
//     //            return CGSize(width: itemWidth, height: 10)
//     //        }
     
//             func collectionView(
//                 _ collectionView: UICollectionView,
//                 layout collectionViewLayout: UICollectionViewLayout,
//                 referenceSizeForHeaderInSection section: Int
//             ) -> CGSize {
     
//                 guard selectedSegment == .myThreads else { return .zero }
     
//                 return CGSize(
//                     width: collectionView.bounds.width,
//                     height: 120
//                 )
//             }
//        }
     
         
//     extension threadsViewController: UICollectionViewDelegate {
//         func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
//                 let post: ThreadPost
//                 switch selectedSegment {
//                 case .forYou:
//                     post = forYouThreads[indexPath.item]
//                 case .following:
//                     post = followingThreads[indexPath.item]
//                 case .myThreads:
//                     post =  threadsStore.getMyThreads()[indexPath.item]
//                 }
     
//                 let detailVC = ThreadDetailViewController()
//                 detailVC.thread = post
//                 navigationController?.pushViewController(detailVC, animated: true)
//             }
//     }
import UIKit

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Data (now backed by API)
    private var forYouThreads: [APIThread] = []
    private var followingThreads: [APIThread] = []
    private var myThreads: [APIThread] = []
    private var currentUserProfile: APIUserProfileResponse?
    private var followingUserIds: Set<String> = []
    private var bookmarkedThreadIds: Set<String> = []
    private var selectedSegment: ThreadsSegment = .forYou
    
    private var currentUserId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    private var authToken: String? {
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
    
    // MARK: - API Fetching
    
    private func loadThreads() {
        let group = DispatchGroup()
        
        group.enter()
        loadFollowingUserIds { group.leave() }
        
        group.enter()
        loadForYouThreads { group.leave() }
        
        group.enter()
        loadFollowingThreads { group.leave() }
        
        group.enter()
        loadMyThreads { group.leave() }
        
        group.enter()
        loadUserProfile { group.leave() }
        
        group.enter()
        loadBookmarkStates { group.leave() }
        
        group.notify(queue: .main) { [weak self] in
            self?.collectionView.reloadData()
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }

    /// Fetches ALL bookmarked threads for the current user and populates the fast-lookup set
    private func loadBookmarkStates(completion: (() -> Void)? = nil) {
        guard let token = authToken else { 
            completion?()
            return 
        }
        APIService.shared.fetchBookmarkedThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let bookmarked) = result {
                    self?.bookmarkedThreadIds = Set(bookmarked.compactMap { $0.threadId })
                }
                completion?()
            }
        }
    }
    
    private func loadFollowingUserIds(completion: (() -> Void)? = nil) {
        guard let token = authToken, let userId = currentUserId else { 
            completion?()
            return 
        }
        APIService.shared.fetchUserFollowing(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let users) = result {
                    self?.followingUserIds = Set(users.map { $0.id })
                }
                completion?()
            }
        }
    }
    
    private func loadForYouThreads(completion: (() -> Void)? = nil) {
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.forYouThreads = threads
                }
                completion?()
            }
        }
    }
    
    private func loadFollowingThreads(completion: (() -> Void)? = nil) {
        guard let token = authToken else { 
            completion?()
            return 
        }
        APIService.shared.fetchFollowingThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.followingThreads = threads
                }
                completion?()
            }
        }
    }
    
    private func loadMyThreads(completion: (() -> Void)? = nil) {
        // Filter forYou by currentUserId. If your backend has a
        // dedicated "my threads" endpoint, replace this.
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.myThreads = threads.filter { $0.userId == self?.currentUserId }
                }
                completion?()
            }
        }
    }
    
    private func loadUserProfile(completion: (() -> Void)? = nil) {
        guard let token = authToken, let userId = currentUserId else { 
            completion?()
            return 
        }
        APIService.shared.fetchUserProfile(userId: userId, token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let profile) = result {
                    self?.currentUserProfile = profile
                }
                completion?()
            }
        }
    }
    
    private func currentThreads() -> [APIThread] {
        switch selectedSegment {
        case .forYou:    return forYouThreads
        case .following: return followingThreads
        case .myThreads: return myThreads
        }
    }

    private func updateThreadLikeState(threadId: String, isLiked: Bool, count: Int) {
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

    private func presentBookmarkSheet(for thread: APIThread) {
        guard let token = authToken else { return }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Fetch folders from backend API
        APIService.shared.fetchBookmarkFolders(token: token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let apiFolders):
                // Convert API folders to BookmarkItem for the sheet UI
                let folderItems = apiFolders.map { folder in
                    BookmarkItem(
                        icon: UIImage(systemName: "folder")!,
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
                    // Find the folder ID matching the selected title
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

                self.present(sheetVC, animated: true)

            case .failure:
                self.showToast(message: "Could not load folders")
            }
        }
    }
}

// MARK: - DataSource
extension threadsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentThreads().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell", for: indexPath
        ) as! collectionViewCell
        
        let thread = currentThreads()[indexPath.item]
        let isOwnPost = thread.userId == currentUserId
        let isFollowing = followingUserIds.contains(thread.userId)
        
        cell.isBookmarked = bookmarkedThreadIds.contains(thread.id)
        cell.configure(with: thread, isFollowing: isFollowing, isOwnPost: isOwnPost)
        cell.applyStyle(isCard: selectedSegment != .myThreads)
        
        // ── Like ──
        cell.onLikeTapped = { [weak self, weak cell] in
            guard let self, let token = self.authToken else { return }
            
            // ⬇️ Fetch the LATEST thread state directly from the array!
            let currentThreadList = self.currentThreads()
            guard indexPath.item < currentThreadList.count else { return }
            let latestThread = currentThreadList[indexPath.item]
            guard latestThread.id == thread.id else { return } // Safety check in case elements shifted
            
            // 1. Calculate optimistic state using `latestThread`
            let wasLiked = latestThread.isLiked ?? false
            let newLiked = !wasLiked
            let newCount = latestThread.likesCount + (newLiked ? 1 : -1) // +1 if newly liked, else -1
            
            // 2. Instantly update UI on the cell without reloading it
            let image = newLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            cell?.likesButton.setImage(image, for: .normal)
            cell?.likesButton.tintColor = newLiked ? .systemRed : .systemBlue
            cell?.likesButton.setTitle("\(max(0, newCount))", for: .normal)
            
            // 3. Save state to local arrays so it won't revert when scrolling
            self.updateThreadLikeState(threadId: latestThread.id, isLiked: newLiked, count: newCount)
            
            // 4. Fire API call invisibly in the background
            APIService.shared.toggleLike(threadId: latestThread.id, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        // Completely Sync server's latest count (just in case)
                        self.updateThreadLikeState(
                            threadId: latestThread.id,
                            isLiked: response.liked,
                            count: response.likesCount
                        )
                    case .failure:
                        // Revert everything logically and visually if cell failed
                        self.updateThreadLikeState(threadId: latestThread.id, isLiked: wasLiked, count: latestThread.likesCount)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        // ── Follow ──
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
        
        // ── Username tap ──
        cell.onUsernameTapped = { [weak self] in
            guard let self else { return }
            guard thread.userId != self.currentUserId else { return }
            let profileVC = BloggerProfileViewController()
            profileVC.bloggerUserId = thread.userId
            profileVC.bloggerUserName = thread.user?.name ?? thread.user?.username ?? thread.userId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        // ── Comment ──
        cell.onCommentTapped = { [weak self] in
            guard let self else { return }
            let vc = CommentsViewController()
            vc.threadId = thread.id   // pass the String ID for API
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 40
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.selectedDetentIdentifier = .medium
            }
            self.present(vc, animated: true)
        }
        
        // ── Delete ──
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
        
        // ── Bookmark (toggle) ──
        cell.onBookmarkTapped = { [weak self] in
            guard let self else { return }
            
            if self.bookmarkedThreadIds.contains(thread.id) {
                // Already saved → unsave via API
                guard let token = self.authToken else { return }
                
                // Optimistic UI update
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
                            // Revert on failure
                            self?.bookmarkedThreadIds.insert(thread.id)
                            self?.collectionView.reloadData()
                            self?.showToast(message: "Failed to remove")
                        }
                    }
                }
            } else {
                // Not saved → show folder picker
                self.presentBookmarkSheet(for: thread)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
            for: indexPath
        ) as! MyThreadsProfileHeaderCollectionReusableView
        
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

// MARK: - Notification
extension Notification.Name {
    static let threadCreated = Notification.Name("threadCreated")
}
