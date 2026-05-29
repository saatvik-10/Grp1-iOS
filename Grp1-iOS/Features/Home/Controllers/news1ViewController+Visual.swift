import UIKit

// MARK: - Visual Utilities

extension news1ViewController {
    func bulletPointList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacing = 8

        let bullet = "•  "
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .paragraphStyle: paragraphStyle
        ]

        let string = strings.map { "\(bullet)\($0)" }.joined(separator: "\n")
        return NSAttributedString(string: string, attributes: attributes)
    }

    func createGradientImage(color: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            color.withAlphaComponent(0.60).cgColor,
            color.withAlphaComponent(1.0).cgColor,
            color.withAlphaComponent(1.0).cgColor,
            color.withAlphaComponent(0.9).cgColor,
            UIColor.systemGray6.cgColor
        ]

        gradientLayer.locations = [
            0.0,
            0.25,
            0.50,
            0.65,
            0.70,
            1.0
        ]

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        gradientLayer.render(in: context)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage
    }

    func dominantColor(from image: UIImage) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }

        let extent = inputImage.extent
        let context = CIContext(options: nil)

        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: CIVector(cgRect: extent)
            ]
        ) else { return nil }

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)

        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }

    func showShareSheet() {
        guard let article = article else { return }

        let customActivity = ShareToFriendsActivity()
        customActivity.article = article

        let activityVC = UIActivityViewController(
            activityItems: [article.title, UIImage(named: article.imageName) ?? UIImage()],
            applicationActivities: [customActivity]
        )

        activityVC.popoverPresentationController?.sourceView = self.view

        present(activityVC, animated: true)
    }
}
