//
//  jargonQuizViewController.swift
//  Grp1-iOS
//

import UIKit

class jargonQuizViewController: UIViewController {

    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var optionButton4: UIButton!
    @IBOutlet weak var optionButton3: UIButton!
    @IBOutlet weak var optionButton2: UIButton!
    @IBOutlet weak var optionButton1: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var quizView: UIView!

    var jargonWord: String!
    var generatedQuiz: JargonQuiz?   // ✅ passed from jargonDefinationViewController
    var quiz: JargonQuiz!

    private var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        greetingLabel.isHidden = true
        congratsLabel.isHidden = true
        isModalInPresentation = true
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        setupGlassEffect()

        // ✅ Use AI-generated quiz if available, fall back to hardcoded store
        if let generated = generatedQuiz {
            self.quiz = generated
        } else if let word = jargonWord, let stored = JargonQuizStore.quiz(for: word) {
            self.quiz = stored
        } else {
            // Show loading state — quiz may still be generating
            showGeneratingState()
            return
        }

        setupUI()
    }

    // MARK: - Loading State

    private func showGeneratingState() {
        questionLabel.text = "Generating quiz question..."
        questionLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        [optionButton1, optionButton2, optionButton3, optionButton4].forEach {
            $0?.setTitle("...", for: .normal)
            $0?.isUserInteractionEnabled = false
            $0?.backgroundColor = .systemGray6
            $0?.layer.cornerRadius = 14
        }
    }

    // MARK: - Setup

    private func setupUI() {
        guard let quiz = quiz else { return }

        questionLabel.text = quiz.question

        let buttons = [optionButton1, optionButton2, optionButton3, optionButton4]
        for (index, button) in buttons.enumerated() {
            guard index < quiz.options.count else { continue }
            button?.setTitle(quiz.options[index], for: .normal)
            button?.tag = index
            button?.layer.cornerRadius = 14
            button?.backgroundColor = .systemGray6
            button?.isUserInteractionEnabled = true
        }
    }

    // MARK: - Answer

    @IBAction func optionTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        })

        selectedIndex = sender.tag
        checkAnswer(selected: sender.tag)
    }

    private func checkAnswer(selected: Int) {
        guard let quiz = quiz else { return }

        let buttons = [optionButton1, optionButton2, optionButton3, optionButton4]
        buttons.forEach { $0?.isUserInteractionEnabled = false }

        for (index, button) in buttons.enumerated() {
            if index == quiz.correctIndex {
                button?.backgroundColor = .systemGreen
                button?.alpha = 0.6
            } else if index == selected {
                button?.backgroundColor = .systemRed
            } else {
                button?.alpha = 0.55
            }
        }

        if selected == quiz.correctIndex {
            guard let correctButton = buttons[selected] else { return }
            animateCorrect(button: correctButton)
            animateQuizSuccess()
            showResult(isCorrect: true)
            showConfetti()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            guard let wrongButton = buttons[selected] else { return }
            animateWrong(button: wrongButton)
            animateQuizError()
            showResult(isCorrect: false)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    private func showResult(isCorrect: Bool) {
        let jargon = quiz.jargonWord

        let alert = UIAlertController(
            title: isCorrect ? "WOW! That's correct 🎉" : "Oops! That was wrong 😅",
            message: isCorrect
                ? "That's great — you've now conquered \(jargon)."
                : "Don't worry — with a little practice, you'll master \(jargon).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Confetti

    private func showConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: quizView.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: quizView.bounds.width, height: 1)

        let colors: [UIColor] = [.systemGreen, .systemBlue, .systemYellow, .systemPink, .systemOrange]
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5.0
            cell.velocity = 150
            cell.velocityRange = 60
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.04
            cell.scaleRange = 0.02
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?.cgImage
            return cell
        }

        quizView.layer.addSublayer(emitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitter.birthRate = 0
            emitter.removeFromSuperlayer()
        }
    }

    // MARK: - Animations

    private func animateCorrect(button: UIButton) {
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.3, delay: 0,
                usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: {
                    button.transform = .identity
                    button.layer.shadowColor = UIColor.systemGreen.cgColor
                    button.alpha = 0.8
                    button.layer.shadowOpacity = 0.4
                    button.layer.shadowRadius = 12
                }
            )
        }
    }

    private func animateWrong(button: UIButton) {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [-10, 10, -8, 8, -4, 4, 0]
        shake.duration = 0.4
        shake.timingFunction = CAMediaTimingFunction(name: .easeOut)
        button.layer.add(shake, forKey: "shake")
    }

    private func animateQuizSuccess() {
        UIView.animate(withDuration: 0.18, animations: {
            self.quizView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.35, delay: 0,
                usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8,
                options: [.curveEaseOut],
                animations: { self.quizView.transform = .identity }
            )
        }
    }

    private func animateQuizError() {
        UIView.animate(withDuration: 0.12, animations: {
            self.quizView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.quizView.alpha = 0.85
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.25, delay: 0,
                usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6,
                options: [.curveEaseOut],
                animations: {
                    self.quizView.transform = .identity
                    self.quizView.alpha = 1
                }
            )
        }
    }

    // MARK: - Glass Effect

    private func setupGlassEffect() {
        quizView.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = quizView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false

        quizView.insertSubview(blurView, at: 0)
        quizView.layer.cornerRadius = 22
        quizView.layer.masksToBounds = true
        quizView.layer.borderWidth = 1
        quizView.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
    }

    // MARK: - Close

    @IBAction func closetapped(_ sender: Any) {
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
}
