//
//  ProgressViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressView4: UIView!
    @IBOutlet weak var progressView3: UIView!
    @IBOutlet weak var progressView2: UIView!
    @IBOutlet weak var progressView1: UIView!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var dayStreakLabel: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var linearProgressView: UIProgressView!
    @IBOutlet weak var overallPercentageLabel: UILabel!

    @IBOutlet weak var quizCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMockData()
        styleCards()
        setupQuizCollectionView()

        // Do any additional setup after loading the view.
    }

    private func styleCards() {
        for cards in[progressView1, progressView2, progressView3, progressView4] {
            cards?.layer.cornerRadius = 16
            cards?.layer.masksToBounds = true
        }
    }

    private func setupUI() {
        linearProgressView.progress = 0
        linearProgressView.layer.cornerRadius = 4
        linearProgressView.clipsToBounds = true
    }

    private func configureStats(_ stats: ProgressStats) {
        dayStreakLabel.text = "\(stats.dayStreak)"
        accuracyLabel.text = "\(stats.accuracyPercentage)%"
    }

    private func loadMockData() {
        configureOverallProgress(ProgressMockData.overallProgress)
        configureStats(ProgressMockData.stats)
    }

    private func configureOverallProgress(_ data: OverallProgress) {
        overallPercentageLabel.text = "\(Int(data.progressPercentage * 100))%"
        completionLabel.text = data.quizCompletionNumber
        levelLabel.text = "Level \(data.levelNumber)"

        linearProgressView.progress = Float(data.progressPercentage)
    }

    private let quizzes = ProgressMockData.quizzes

    private func setupQuizCollectionView() {
        quizCollectionView.dataSource = self
        quizCollectionView.delegate = self

        quizCollectionView.register(
            UINib(nibName: "QuizViewCell", bundle: nil),
            forCellWithReuseIdentifier: "QuizViewCell"
        )
    }

}

extension ProgressViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        quizzes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "QuizViewCell",
            for: indexPath
        ) as? QuizViewCell else { return UICollectionViewCell() }

        cell.configure(with: quizzes[indexPath.item])
        return cell
    }
}

extension ProgressViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 80)
    }
}
