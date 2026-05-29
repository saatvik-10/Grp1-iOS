import UIKit

extension UIViewController {
    func showToast(message: String) {
        let toastView = UILabel()
        toastView.text = message
        toastView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastView.textColor = .white
        toastView.textAlignment = .center
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.layer.cornerRadius = 20
        toastView.layer.masksToBounds = true

        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastView)

        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            toastView.heightAnchor.constraint(equalToConstant: 45),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.2, options: .curveEaseOut, animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}
