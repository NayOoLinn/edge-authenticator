import UIKit

final class ScanMaskView: UIView {
    var cutoutRect: CGRect = .zero { didSet { setNeedsDisplay() } }
    var cutoutCornerRadius: CGFloat = 12 { didSet { setNeedsDisplay() } }
    var overlayColor: UIColor = UIColor.black.withAlphaComponent(0.55) { didSet { setNeedsDisplay() } }
    var borderColor: UIColor = .white { didSet { setNeedsDisplay() } }
    var borderWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Fill whole screen
        ctx.setFillColor(overlayColor.cgColor)
        ctx.fill(bounds)

        // Cut out the scanning area using even-odd rule
        let path = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cutoutCornerRadius).cgPath
        ctx.setBlendMode(.clear)
        ctx.addPath(path)
        ctx.fillPath()

        // Restore normal blend and draw border
        ctx.setBlendMode(.normal)
        let borderPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cutoutCornerRadius)
        borderPath.lineWidth = borderWidth
        borderColor.setStroke()
        borderPath.stroke()
    }
}
