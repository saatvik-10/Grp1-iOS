//
//  QuizViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var endQuizButton: UIButton!
    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var optionButton3: UIButton!
    @IBOutlet weak var optionButton4: UIButton!
    private var score = 0
    private var hasSelectedOption = false
    var quizQuestions: [QuizQuestion] = []
    private var currentQuestionIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        showLoadingState()
        generateAndStart()
    }

    private func showLoadingState() {
        questionLabel.text = ""

        optionButton1.isHidden = true
        optionButton2.isHidden = true
        optionButton3.isHidden = true
        optionButton4.isHidden = true
        continueButton.isHidden = true
        endQuizButton.isHidden = true
        quitButton.isHidden = true
        progressView.isHidden = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tag = 99
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        let label = UILabel()
        label.tag = 98
        label.text = "Generating your quiz..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    private func hideLoadingState() {
        view.viewWithTag(99)?.removeFromSuperview()
        view.viewWithTag(98)?.removeFromSuperview()

        optionButton1.isHidden = false
        optionButton2.isHidden = false
        optionButton3.isHidden = false
        optionButton4.isHidden = false
        quitButton.isHidden = false
        progressView.isHidden = false
    }

    private func generateAndStart() {
        guard let article = QuizContext.shared.currentArticle else {
            dismiss(animated: true)
            return
        }

        let articleText = ([article.title, article.description] + article.overview + article.keyTakeaways)
            .joined(separator: "\n")

        Task { @MainActor in
            let generator = QuizGenerator()
            await generator.generateQuiz(from: articleText)

            if let generated = generator.result, !generated.questions.isEmpty {
                self.quizQuestions = generated.questions.map {
                    QuizQuestion(
                        articleId: article.id,
                        question: $0.question,
                        options: $0.options,
                        correctIndex: $0.correctIndex
                    )
                }
            }

            guard !self.quizQuestions.isEmpty else {
                self.dismiss(animated: true)
                return
            }

            self.hideLoadingState()
            self.setupContinueButton()
            self.setupEndQuizButton()
            self.renderCurrentQuestion()
        }
    }

    func setupEndQuizButton() {
        endQuizButton.isEnabled = false
        endQuizButton.alpha = 0.0
        endQuizButton.isHidden = true
    }
    func setupContinueButton() {
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
    }

    func renderCurrentQuestion() {

        let question = quizQuestions[currentQuestionIndex]
        questionLabel.text = question.question

        let buttons = [
            optionButton1,
            optionButton2,
            optionButton3,
            optionButton4
        ]

        for (index, button) in buttons.enumerated() {
            button?.setTitle(question.options[index], for: .normal)
            button?.tag = index
            button?.isEnabled = true
            button?.backgroundColor = .systemGray6
        }

        hasSelectedOption = false

        let isLastQuestion = currentQuestionIndex == quizQuestions.count - 1

        if isLastQuestion {
            continueButton.isEnabled = false
            continueButton.alpha = 0.0
            continueButton.isHidden = true

            endQuizButton.isHidden = false
            endQuizButton.alpha = 0.5
            endQuizButton.isEnabled = false
        } else {
            continueButton.isHidden = false
            continueButton.isEnabled = false
            continueButton.alpha = 0.5

            endQuizButton.isHidden = true
            endQuizButton.isEnabled = false
            endQuizButton.alpha = 0.0
        }

        updateProgress()
    }

    func goToNextQuestion() {

        if currentQuestionIndex + 1 < quizQuestions.count {
            currentQuestionIndex += 1
            renderCurrentQuestion()
        } else {
            showQuizCompleted()
        }
    }

        func showQuizCompleted() {
            progressView.setProgress(1.0, animated: true)
            questionLabel.text = "Quiz Completed 🎉"

            optionButton1.isHidden = true
            optionButton2.isHidden = true
            optionButton3.isHidden = true
            optionButton4.isHidden = true
        }

    func updateProgress() {
        let progress = Float(currentQuestionIndex + 1) / Float(quizQuestions.count)
        progressView.setProgress(progress, animated: true)
    }

    @IBAction func optionTapped(_ sender: UIButton) {

        guard !hasSelectedOption else { return }
            hasSelectedOption = true

            let question = quizQuestions[currentQuestionIndex]

            if sender.tag == question.correctIndex {
                sender.backgroundColor = .systemGreen
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                score += 1
            } else {
                sender.backgroundColor = .systemRed
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }

            optionButton1.isEnabled = false
            optionButton2.isEnabled = false
            optionButton3.isEnabled = false
            optionButton4.isEnabled = false

            let isLastQuestion = currentQuestionIndex == quizQuestions.count - 1

            if isLastQuestion {
                endQuizButton.isEnabled = true
                endQuizButton.alpha = 1.0
            } else {
                continueButton.isEnabled = true
                continueButton.alpha = 1.0
            }
        }

    @IBAction func endQuizTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toEndQuiz", sender: nil)
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        goToNextQuestion()
    }
    @IBAction func quitTapped(_ sender: UIButton) {

        let alert = UIAlertController(
            title: "Quit Quiz?",
            message: "Do you really want to quit the quiz?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.dismiss(animated: true)
        })

        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toEndQuiz",
           let vc = segue.destination as? QuizResultViewController {

            vc.score = score
            vc.totalQuestions = quizQuestions.count
        }
    }
}
