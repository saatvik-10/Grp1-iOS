import UIKit

class GenerativeIntroViewController: UIViewController {

    // MARK: - Properties
    var scenarioParams: DecodeAndRankScenario?

    // State Tracking
    var revealedItemIDs: Set<String> = []
    var currentRanking: [RankingOption] = []

    // UI Elements (Headers)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    // UI Elements (Step 1 - Tappable Items)
    // Using a UICollectionView or UITableView for Step 1
    let decodeTableView = UITableView()

    // UI Elements (Step 2 - Draggable Ranking)
    let rankTableView = UITableView()

    let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 12
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    // MARK: - UI Setup
        // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        decodeTableView.translatesAutoresizingMaskIntoConstraints = false
        decodeTableView.dataSource = self
        decodeTableView.delegate = self
        decodeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DecodeCell")

        rankTableView.translatesAutoresizingMaskIntoConstraints = false
        rankTableView.dataSource = self
        rankTableView.delegate = self
        rankTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RankCell")
        rankTableView.isEditing = true
        rankTableView.isHidden = true
        rankTableView.alpha = 0

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.isHidden = true
        continueButton.alpha = 0
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        view.addSubview(headerStack)
        view.addSubview(decodeTableView)
        view.addSubview(rankTableView)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // decodeTableView takes up the whole bottom space
            decodeTableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 24),
            decodeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            decodeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            decodeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // rankTableView anchors to the top of the continueButton
            rankTableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 24),
            rankTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rankTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rankTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),

            // continueButton anchors to the bottom safe area
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func loadData() {
    // 1. Find the JSON file in the app bundle
    guard let url = Bundle.main.url(forResource: "GenerativeGame1", withExtension: "json") else {
        print("Could not find GenerativeGame.json")
        return
    }

    do {
        // 2. Load and decode the file
        let data = try Data(contentsOf: url)
        self.scenarioParams = try JSONDecoder().decode(DecodeAndRankScenario.self, from: data)
    } catch {
        print("Error decoding JSON: \(error)")
        return
    }

    // 3. Populate the UI elements
    guard let scenario = scenarioParams else { return }

    titleLabel.text = scenario.meta.title
    subtitleLabel.text = scenario.meta.description

    // Initialize Step 2 ordering with the default state
    currentRanking = scenario.step2.rankingOptions

    decodeTableView.reloadData()
    rankTableView.reloadData()
    }

    // MARK: - State Logic

    /// Called when the user taps on an offer line in Step 1
    func handleTapOnDecodeItem(at indexPath: IndexPath) {
        guard let item = scenarioParams?.step1.decodableItems[indexPath.row] else { return }

        // Mark as revealed
        revealedItemIDs.insert(item.id)

        // Reload that specific cell to show the `revealedText` instead of `initialText`
        decodeTableView.reloadRows(at: [indexPath], with: .fade)

        checkIfStep1Complete()
    }

    /// Checks if all items are revealed. If so, animate Step 2 onto the screen.
    func checkIfStep1Complete() {
        guard let scenario = scenarioParams else { return }
        if revealedItemIDs.count == scenario.step1.decodableItems.count {
            showStep2()
        }
    }

    /// Transition logic to bring in the Drag-and-Drop view
        func showStep2() {
        // Animate the decoding table out, and animate the ranking table in
        UIView.animate(withDuration: 0.5) {
            self.decodeTableView.alpha = 0.5
            self.rankTableView.isHidden = false
            self.rankTableView.alpha = 1.0

            // Fade in the continue button
            self.continueButton.isHidden = false
            self.continueButton.alpha = 1.0
        }
    }

    /// Handle Drag to Reorder completion from Step 2
    func handleReorder(sourceIndex: Int, destinationIndex: Int) {
        let movedItem = currentRanking.remove(at: sourceIndex)
        currentRanking.insert(movedItem, at: destinationIndex)

        // currentRanking now holds the exact state of the user's "Gut Reaction" list
        // Ready to be sent to your analytics/backend when they tap "Continue"
    }

    /// Returns the data payload when the user finishes the screen
    func collectResults() -> [String: Any] {
        return [
            "scenario_id": scenarioParams?.id ?? "",
            "time_to_complete": 15.4, // Example tracking
            "final_ranking_order": currentRanking.map { $0.id }
        ]
    }

    @objc func continueTapped() {
        // Here is where you capture the ranking results and save them
        let results = collectResults()
        print("Moving to Screen 2. Saved data: \(results)")

        let screen2 = GenerativeViewController2()
        screen2.modalPresentationStyle = .fullScreen
        // Make sure you have a way to dismiss or push if you prefer navigation controllers!
        self.present(screen2, animated: true)
    }
}

extension GenerativeIntroViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == decodeTableView {
            return scenarioParams?.step1.decodableItems.count ?? 0
        } else {
            return currentRanking.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == decodeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DecodeCell", for: indexPath)
            guard let item = scenarioParams?.step1.decodableItems[indexPath.row] else { return cell }

            var content = cell.defaultContentConfiguration()
            if revealedItemIDs.contains(item.id) {
                content.text = item.initialText
                content.secondaryText = item.revealedText
                content.secondaryTextProperties.color = .systemBlue
            } else {
                content.text = item.initialText
                content.secondaryText = "Tap to reveal..."
                content.secondaryTextProperties.color = .systemGray
            }
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath)
            let item = currentRanking[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = "\(indexPath.row + 1). \(item.text)"
            cell.contentConfiguration = content
            cell.showsReorderControl = true
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == decodeTableView {
            handleTapOnDecodeItem(at: indexPath)
        }
    }

    // For drag and drop reordering
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView == rankTableView
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableView == rankTableView {
            handleReorder(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
            tableView.reloadData() // Ensure numbers update immediately
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
