import UIKit
import ObjectiveC

extension UILabel {

    private struct Keys {
        static var typingTimer = "typingTimer"
    }

    private var typingTimer: Timer? {
        get {
            objc_getAssociatedObject(self, &Keys.typingTimer) as? Timer
        }
        set {
            objc_setAssociatedObject(
                self,
                &Keys.typingTimer,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func cancelTyping() {
        typingTimer?.invalidate()
        typingTimer = nil
    }

    func typeThenReveal(
        _ fullText: String,
        delay: TimeInterval = 0.008
    ) {
        cancelTyping()
        text = ""

        let characters = Array(fullText)
        var index = 0

        typingTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] timer in
            guard let self else { return }

            if index < characters.count {
                self.text?.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
                self.typingTimer = nil
                self.text = fullText
            }
        }
    }
}
