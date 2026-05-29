import UIKit

class OnboardingPageViewController: UIPageViewController {

    private var controllers: [UIViewController] = []
    private var currentIndex: Int = 0
    private let pageControl = UIPageControl()
    var selectedLevel: String?
    var selectedDomains: [String] = []
    var selectedInterests: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }

    private func setupControllers() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

        // STEP 1 — Investment Level
        guard let step1 = storyboard.instantiateViewController(
            withIdentifier: "OnboardingContentViewController"
        ) as? OnboardingContentViewController else { return }

        step1.loadViewIfNeeded()
        step1.configure(
            with: OnboardingPage(
                title: "Experience Level",
                options: [
                    (title: "Beginner", subtitle: "New to investing. Guidance and simple concepts for your journey."),
                    (title: "Intermediate", subtitle: "Some experience. You understand basic assets and have traded before."),
                    (title: "Expert", subtitle: "Seasoned investor. Familiar with complex strategies and analysis.")
                ]
            )
        )
        selectedLevel = "Intermediate"

        step1.onOptionSelected = { [weak self] selected in
            self?.selectedLevel = selected
        }

        step1.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }

        step1.onSkipTapped = { [weak self] in
            print("⏭️ User chose to skip onboarding. Navigating to Home safely...")
            self?.navigateToHome()
        }

        // STEP 2 — Interest Selection
        guard let step2 = storyboard.instantiateViewController(
            withIdentifier: "InterestCollectionViewController"
        ) as? InterestCollectionViewController else { return }

        step2.onFinishTapped = { [weak self] in
            guard let self else { return }
            let previewCount = min(6, InterestsDataSource.domains.count)
            var pickedTitles = Set(UserInterests.domains.map { $0.title })

            if let indexPaths = step2.interestCollectionView.indexPathsForSelectedItems {
                let previewPicked = indexPaths
                    .map { $0.item }
                    .filter { $0 < previewCount }
                    .map { InterestsDataSource.domains[$0].title }
                previewPicked.forEach { pickedTitles.insert($0) }
            }

            self.selectedDomains = Array(pickedTitles)
            // Persist into user interests so Profile -> Interests renders them.
            UserInterests.domains = InterestsDataSource.domains.filter { pickedTitles.contains($0.title) }
            NotificationCenter.default.post(name: .userInterestsDidChange, object: nil)
            self.submitOnboardingToBackend()
        }

        step2.onBackTapped = { [weak self] in
            self?.goToPreviousPage()
        }

        controllers = [step1, step2]

        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.systemGray4
        pageControl.currentPageIndicatorTintColor = UIColor.systemBlue // or any brand color
        pageControl.isUserInteractionEnabled = false
        pageControl.isHidden = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        // Add to main view and pin to the bottom
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        setViewControllers(
            [controllers[0]],
            direction: .forward,
            animated: false
        )
    }

    // MARK: - Navigation

    func goToNextPage() {
        guard currentIndex + 1 < controllers.count else {
            print("Onboarding finished")
            return
        }
        currentIndex += 1

        // 3a. Update the dot forwards!
        pageControl.currentPage = currentIndex

        setViewControllers(
            [controllers[currentIndex]],
            direction: .forward,
            animated: true
        )
    }
    func goToPreviousPage() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1

        // 3b. Update the dot backwards!
        pageControl.currentPage = currentIndex

        setViewControllers(
            [controllers[currentIndex]],
            direction: .reverse,
            animated: true
        )
    }

    // MARK: - Submission (saves to DATABASE via API)

    private func saveLevelToBackend(token: String, group: DispatchGroup) {
        guard let selectedLevel = self.selectedLevel?.components(separatedBy: "\n").first?.uppercased() else { return }
        let levelString = selectedLevel == "EXPERT" ? APILevel.advance.rawValue : selectedLevel
        guard let levelEnum = APILevel(rawValue: levelString) else { return }

        group.enter()
        APIService.shared.saveLevel(levelEnum, token: token) { result in
            switch result {
            case .success:
                print("✅ Saved level '\(levelEnum.rawValue)' to DB")
            case .failure(let error):
                print("❌ Failed saving level: \(error)")
            }
            group.leave()
        }
    }

    func submitOnboardingToBackend() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No auth token found")
            return
        }

        // Use the main, strongly-typed APIService
        let api = APIService.shared
        let dispatchGroup = DispatchGroup()

        saveLevelToBackend(token: token, group: dispatchGroup)
        // 2) Fetch strongly-typed interests, match by name, then POST each
        dispatchGroup.enter()
        api.fetchAvailableInterests(type: nil) { [weak self] result in
            defer { dispatchGroup.leave() }
            guard let self = self else { return }

            switch result {
            case .success(let availableInterests):
                let allSelected = self.selectedDomains + self.selectedInterests
                let allSelectedLowercased = allSelected.map { $0.lowercased() }

                print("🚨 DEBUG 1 (iOS Selected Topics): \(allSelectedLowercased)")
                print("🚨 DEBUG 2 (Available DB Topics): \(availableInterests.map { $0.name.lowercased() })")

                // Find matching APIInterest objects
                let matches = availableInterests.filter { interest in
                    allSelectedLowercased.contains(interest.name.lowercased())
                }

                print("🚨 DEBUG 3 (Matches Found): \(matches.count)")

                for match in matches {
                    dispatchGroup.enter()
                    // Uses the safe, native APIService.addInterest
                    api.addInterest(interestId: match.id, token: token) { saveResult in
                        switch saveResult {
                        case .success:
                            print("✅ Saved interest '\(match.name)' to DB")
                        case .failure(let error):
                            print("❌ Failed saving interest '\(match.name)': \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }

            case .failure(let error):
                print("❌ Failed to fetch available interests: \(error)")
            }
        }

        // 3) Mark onboarding locally and navigate to Home once everything is synced
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Send the network ping to Database to secure Onboarding true!
            api.finishOnboarding(token: token) { _ in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "hasOnboarding")
                    print("🏁 All onboarding parameters synced! Navigating to Home.")
                    self?.navigateToHome()
                }
            }
        }
    }

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
        if let homeVC = storyboard.instantiateInitialViewController() {
            // Set as root so user can't swipe back
            if let window = self.view.window {
                window.rootViewController = homeVC
                UIView.transition(with: window, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil)
            }
        }
    }
}
