import UIKit

class CircularProgressView: UIView {
    
    private let maxValue: CGFloat = 1.0
    private var animationDuration: TimeInterval = 0.3
    
    public var trackColor: UIColor = Color.txtColor {
        didSet {
            trackLayer.fillColor = trackColor.cgColor
        }
    }
    
    public var progressColor: UIColor = UIColor.white {
        didSet {
            progressLayer.fillColor = progressColor.cgColor
        }
    }
    
    private var progress: CGFloat = 0.0
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureTrackPath()
        updateProgressBar(animated: false)
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Track background
        trackLayer.fillColor = trackColor.cgColor
        layer.addSublayer(trackLayer)
        
        // Progress sector
        progressLayer.fillColor = progressColor.cgColor
        layer.addSublayer(progressLayer)
    }
    
    /// Full background circle
    private func configureTrackPath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) / 2) - 1
        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        trackLayer.path = trackPath.cgPath
    }
    
    /// Updates the filled sector based on `progress`
    private func updateProgressBar(animated: Bool) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let endAngle = (-CGFloat.pi / 2) + (progress * CGFloat.pi * 2)
        
        // Pie chart sector path
        let progressPath = UIBezierPath()
        progressPath.move(to: center)
        progressPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2, // start at top
            endAngle: endAngle,
            clockwise: true
        )
        progressPath.close()
        
        let newPath = progressPath.cgPath
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = progressLayer.presentation()?.path ?? progressLayer.path
            animation.toValue = newPath
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.path = newPath
    }
    
    public func setProgress(_ progress: CGFloat, animated: Bool = true) {
        self.progress = min(max(progress, 0), maxValue)
        updateProgressBar(animated: animated)
    }
}
