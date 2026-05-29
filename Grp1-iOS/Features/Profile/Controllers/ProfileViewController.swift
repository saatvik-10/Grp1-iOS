import UIKit

// MARK: - ProfileViewController
//
// STORYBOARD LAYOUT REQUIRED (set these constraints in Interface Builder):
//
//  profileBtn    → W:88  H:88  CenterX = superview
//                  Top = safeArea.top + 120   (so avatar straddles blue/white line)
//
//  profileName   → Top = profileBtn.bottom + 10   CenterX = superview
//                  Font: System Bold 22pt
//
//  profileLevel  → Top = profileName.bottom + 4   CenterX = superview
//                  Font: System Regular 14pt   TextColor: secondaryLabel
//
//  collectionView→ Top = profileLevel.bottom + 16
//                  Leading = 0, Trailing = 0, Bottom = 0
//
//  profileImage  → pin all edges to superview (behind everything, for optional bg tint)

class ProfileViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!

    // MARK: - Data
    let sections = ProfileDataSource.sections
    private var profileData: APIProfileResponse?

    // Keep a reference so we can update the blue panel bottom when layout changes
    private var bluePanelBottomConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        styleProfileHeader()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileBtn.layer.cornerRadius = profileBtn.bounds.height / 2
        insertBlueHeaderIfNeeded()
    }

    // MARK: - Blue Header
    //
    // Inserts a solid blue view that covers from the very top of the screen
    // down to the centre of the avatar button — so the avatar straddles
    // the blue / white boundary, exactly like the reference screenshot.

    private var blueHeaderInserted = false

    private func insertBlueHeaderIfNeeded() {
        guard !blueHeaderInserted, profileBtn.bounds.height > 0 else { return }
        blueHeaderInserted = true

        // Dynamically push the avatar button down to increase the blue header's height
        if let topConstraint = view.constraints.first(where: {
            ($0.firstItem as? UIView == profileBtn && $0.firstAttribute == .top) ||
            ($0.secondItem as? UIView == profileBtn && $0.secondAttribute == .top)
        }) {
            topConstraint.constant += 30 // Increase the height of the blue part
        }

        let blueView = UIView()
        blueView.backgroundColor = UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1.0)
        blueView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blueView, at: 0)

        let bottom = blueView.bottomAnchor.constraint(
            equalTo: profileBtn.centerYAnchor, constant: 0)
        bluePanelBottomConstraint = bottom

        NSLayoutConstraint.activate([
            blueView.topAnchor.constraint(equalTo: view.topAnchor),
            blueView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blueView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom,
        ])
    }

    // MARK: - Style existing IBOutlet header views

    private func styleProfileHeader() {
        // Avatar button
        profileBtn.clipsToBounds          = true
        profileBtn.layer.borderWidth      = 4
        profileBtn.layer.borderColor      = UIColor.white.cgColor
        profileBtn.backgroundColor        = UIColor(red: 0.96, green: 0.90, blue: 0.83, alpha: 1)
        profileBtn.imageView?.contentMode = .scaleAspectFill
        profileBtn.tintColor              = UIColor(red: 0.60, green: 0.40, blue: 0.30, alpha: 1)
        profileBtn.setImage(
            UIImage(systemName: "person.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)),
            for: .normal)

        // Name label
        profileName.font          = UIFont.systemFont(ofSize: 22, weight: .bold)
        profileName.textColor     = .label
        profileName.textAlignment = .center

        // Username / level label
        profileLevel.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        profileLevel.textColor     = .secondaryLabel
        profileLevel.textAlignment = .center
    }

    // MARK: - Collection View

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.backgroundColor = .clear

        // Reduce spacing between name and username
        profileLevel.transform = CGAffineTransform(translationX: 0, y: -8)
        
        // Add a divider below the name/username header and above collection view
        addDivider()

        collectionView.register(
            UINib(nibName: "ProgressViewCell",       bundle: nil),
            forCellWithReuseIdentifier: "progress_cell")
        collectionView.register(
            UINib(nibName: "InterestsViewCell",      bundle: nil),
            forCellWithReuseIdentifier: "interests_cell")
        collectionView.register(
            UINib(nibName: "BookmarksViewCell",      bundle: nil),
            forCellWithReuseIdentifier: "bookmarks_cell")
        collectionView.register(
            UINib(nibName: "ProfileOption2ViewCell", bundle: nil),
            forCellWithReuseIdentifier: "option_cell")

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    // MARK: - Compositional Layout

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self = self else { return nil }

            var groupItems: [NSCollectionLayoutItem] = []
            var totalHeight: CGFloat = 0

            for (index, sectionType) in self.sections.enumerated() {
                let h: CGFloat
                switch sectionType {
                case .progress:       h = 200 // Increased height of the Streak cell
                case .interests:      h = 95  // Decreased height of the Interests cell
                case .bookmarks:      h = 85  // Increased height of the Bookmarks cell
                case .about, .logout: h = 60
                }
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(h))
                groupItems.append(NSCollectionLayoutItem(layoutSize: itemSize))
                totalHeight += h + (index > 0 ? 10 : 0)
            }

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(totalHeight))
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: groupItems)
            group.interItemSpacing = .fixed(10)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16, leading: 16, bottom: 30, trailing: 16)
            return section
        }
    }
    
    private func addDivider() {
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            divider.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: 0),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Populate header from API data

    func setupProfileHeader() {
        profileBtn.layer.cornerRadius = profileBtn.bounds.height / 2

        if let profile = profileData {
            profileName.text  = profile.name
            profileLevel.text = "@\(profile.username)"
            profileLevel.textColor = .secondaryLabel

            if let urlString = profile.profileImageUrl,
               let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            if let fallback = UIImage(named: "profile") {
                                self?.profileBtn.setImage(nil, for: .normal)
                                self?.profileBtn.setBackgroundImage(fallback, for: .normal)
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self?.profileBtn.setImage(nil, for: .normal)
                        self?.profileBtn.setBackgroundImage(image, for: .normal)
//                        self?.applyProfileBackgroundImage(image)
                    }
                }.resume()
            } else {
                if let fallback = UIImage(named: "profile") {
                    profileBtn.setImage(nil, for: .normal)
                    profileBtn.setBackgroundImage(fallback, for: .normal)
                }
            }
        } else {
            let user = User.current
            profileName.text       = user.name
            profileLevel.text      = "@" + (user.email.components(separatedBy: "@").first ?? "username")
            profileLevel.textColor = .secondaryLabel
            
            if let img = UIImage(named: user.image) {
                profileBtn.setImage(nil, for: .normal)
                profileBtn.setBackgroundImage(img, for: .normal)
            }
        }
    }

    // MARK: - Optional background image tinting

    private func applyProfileBackgroundImage(_ image: UIImage) {
        profileImage.image         = image
        profileImage.contentMode   = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.alpha         = 0.35
        view.sendSubviewToBack(profileImage)
        view.viewWithTag(998)?.removeFromSuperview()

        let dominant = dominantColor(from: image) ?? .systemBlue
        let gradientView = UIView()
        gradientView.tag = 998
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientView, aboveSubview: profileImage)
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: profileImage.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
        ])
        DispatchQueue.main.async {
            let gl = CAGradientLayer()
            gl.colors     = [UIColor.clear.cgColor,
                             dominant.withAlphaComponent(0.25).cgColor,
                             UIColor.systemBackground.cgColor]
            gl.locations  = [0, 0.5, 1]
            gl.startPoint = CGPoint(x: 0.5, y: 0)
            gl.endPoint   = CGPoint(x: 0.5, y: 1)
            gl.frame      = gradientView.bounds
            gradientView.layer.addSublayer(gl)
        }
    }

    private func dominantColor(from image: UIImage) -> UIColor? {
        guard let ci = CIImage(image: image) else { return nil }
        let ctx = CIContext(options: [.workingColorSpace: kCFNull!])
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey:  ci,
                                                 kCIInputExtentKey: CIVector(cgRect: ci.extent)]),
              let out = filter.outputImage else { return nil }
        var bm = [UInt8](repeating: 0, count: 4)
        ctx.render(out, toBitmap: &bm, rowBytes: 4,
                   bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                   format: .RGBA8, colorSpace: nil)
        return UIColor(red:   CGFloat(bm[0]) / 255,
                       green: CGFloat(bm[1]) / 255,
                       blue:  CGFloat(bm[2]) / 255,
                       alpha: 1)
    }

    // MARK: - Fetch Profile

    private func fetchProfile() {
        guard let token = SessionManager.shared.authToken else {
            setupProfileHeader(); return
        }
        APIService.shared.fetchProfile(token: token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profileData = profile
                self?.setupProfileHeader()
            case .failure:
                self?.setupProfileHeader()
            }
        }
    }

    // MARK: - Logout

    private func performLogout() {
        AuthenticationService.shared.signOut { [weak self] success in
            guard success else { print("Error signing out."); return }
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "Authentication", bundle: nil)
                guard let authVC = sb.instantiateInitialViewController(),
                      let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = scene.windows.first else { return }
                window.rootViewController = authVC
                UIView.transition(with: window, duration: 0.3,
                                  options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let sectionType = sections[indexPath.row]

        switch sectionType {
        case .progress:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "progress_cell", for: indexPath) as! ProgressViewCell
            let currentStreak = DailyGameManager.shared.getStreak()
            cell.configure(streakCount: currentStreak)
            cell.contentView.backgroundColor = .white
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell

        case .interests(let data):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "interests_cell", for: indexPath) as! InterestsViewCell
            // Render latest user-selected interests rather than the static snapshot.
            let latest = Array(UserInterests.domains.map { $0.title }.prefix(4))
            cell.configure(interests: latest.isEmpty ? data.interests : latest)
            cell.contentView.backgroundColor = .white
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell

        case .bookmarks(let data):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "bookmarks_cell", for: indexPath) as! BookmarksViewCell
            cell.configure(folders: data.totalFolders, bookmarks: data.totalBookmarks)
            cell.contentView.backgroundColor = .white
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell

        case .about, .logout:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "option_cell", for: indexPath) as! ProfileOption2ViewCell
            cell.delegate = self
            cell.configure(title: sectionType.title, isDestructive: sectionType.isDestructive)
            cell.contentView.backgroundColor = .white
            cell.backgroundColor = .white
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let sectionType = sections[indexPath.row]
        if case .interests = sectionType {
            performSegue(withIdentifier: "interestsSegue", sender: self)
        } else if case .bookmarks = sectionType {
            performSegue(withIdentifier: "bookmarksSegue", sender: self)
        } else if case .about = sectionType {
            print("About us tapped")
        } else if case .logout = sectionType {
            performLogout()
        }
    }
}

// MARK: - ProfileOptionCellDelegate

extension ProfileViewController: ProfileOptionCellDelegate {
    func didTapOption(for cell: ProfileOption2ViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let sectionType = sections[indexPath.row]
        switch sectionType {
        case .about:  print("About us tapped")
        case .logout: performLogout()
        default: break
        }
    }
}

// MARK: - ProfileSection helpers

extension ProfileSection {
    var title: String {
        switch self {
        case .progress:  return "Progress"
        case .interests: return "Interests"
        case .bookmarks: return "Bookmarks"
        case .about:     return "About Us"
        case .logout:    return "Logout"
        }
    }
    var isDestructive: Bool {
        if case .logout = self { return true }
        return false
    }
}
