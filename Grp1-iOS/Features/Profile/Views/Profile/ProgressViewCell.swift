import UIKit

class ProgressViewCell: UICollectionViewCell {

    @IBOutlet weak var progressLevel: UILabel!
    private var streakView: StreakCircleView?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        setupStreakView()
    }

    private func setupStreakView() {
        // We hide the IB outlet label because StreakCircleView has its own countLabel
        progressLevel?.isHidden = true

        let circle = StreakCircleView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circle)

        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: contentView.topAnchor),
            circle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            circle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            circle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        self.streakView = circle
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        streakView?.stopAnimation()
    }

    func configure(streakCount: Int) {
        streakView?.streakCount = streakCount
        streakView?.startAnimation()
    }
}

class StreakCircleView: UIView {

    var streakCount: Int = 0 {
        didSet { countLabel.text = "\(streakCount)" }
    }

    private let countLabel = UILabel()
    private var displayLink: CADisplayLink?
    private var particles: [Particle] = []
    private var didInitParticles = false

    struct Particle {
        var angle: CGFloat
        var radius: CGFloat
        var opacity: CGFloat
        var speed: CGFloat
        var baseSize: CGFloat
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        countLabel.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        countLabel.textAlignment = .center
        countLabel.textColor = .black // Matches your screenshot
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Days Streak"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            subtitleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: -10),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func startAnimation() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink?.add(to: .main, forMode: .common)
        }
    }

    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        if !didInitParticles {
            didInitParticles = true
            // Initialize with random positions so they don't all start at once
            for _ in 0..<45 {
                particles.append(makeParticle(fromEdge: false))
            }
        }
    }

    private func makeParticle(fromEdge: Bool) -> Particle {
        let maxR = max(bounds.width, bounds.height) * 0.7
        // If fromEdge is true, they start at the boundary.
        // Otherwise, they start scattered (initial load).
        let startR = fromEdge ? maxR : CGFloat.random(in: 2...maxR)

        return Particle(
            angle: CGFloat.random(in: 0...(2 * .pi)),
            radius: startR,
            opacity: CGFloat.random(in: 0.6...1.0),
            speed: CGFloat.random(in: 0.7...1.8),
            baseSize: CGFloat.random(in: 4...8)
        )
    }

    @objc private func tick() {
        // Particles will now travel until they almost hit the center point (radius 2)
        let centerThreshold: CGFloat = 2.0

        for index in 0..<particles.count {
            particles[index].radius -= particles[index].speed

            if particles[index].radius < 20 {
                particles[index].opacity -= 0.03
            }

            if particles[index].radius <= centerThreshold || particles[index].opacity <= 0 {
                particles[index] = makeParticle(fromEdge: true)
            }
        }

        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxPossibleRadius = max(rect.width, rect.height) * 0.5

        // 1. Draw Background Gradient
        let gradientRadius = maxPossibleRadius * 1.2
        let colors = [
            UIColor.white.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.35).cgColor
        ]
        let locations: [CGFloat] = [0.0, 0.5, 1.0]

        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations) {
            ctx.drawRadialGradient(
                gradient, startCenter: center, startRadius: 0,
                endCenter: center, endRadius: gradientRadius,
                options: [.drawsAfterEndLocation]
            )
        }

        // 2. Draw Particles
        for particle in particles {
            let xPos = center.x + particle.radius * cos(particle.angle)
            let yPos = center.y + particle.radius * sin(particle.angle)

            // Visual Polish: Particles get smaller as they approach the center
            let sizeScale = max(particle.radius / maxPossibleRadius, 0.2)
            let currentSize = particle.baseSize * sizeScale

            ctx.setFillColor(UIColor.systemBlue.withAlphaComponent(particle.opacity).cgColor)
            ctx.fillEllipse(in: CGRect(
                x: xPos - currentSize / 2,
                y: yPos - currentSize / 2,
                width: currentSize,
                height: currentSize
            ))
        }
    }

    deinit {
        stopAnimation()
    }
}
