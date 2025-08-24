import UIKit

public extension UIView {

    @IBInspectable var viewCornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        } set {
            self.layer.cornerRadius = newValue
        }
    }

    @IBInspectable var viewBorderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable var viewBorderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowAlpha: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            dropShadow(opacity: newValue)
        }
    }
    
    var isHiddenInStack: Bool {
        get {
            return isHidden
        }
        set {
            if newValue == isHidden {
                return
            } else {
                isHidden = newValue
            }
        }
    }

    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func roundCorners(
        radius: CGFloat,
        corners: UIRectCorner = .allCorners
    ) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        var arr: CACornerMask = []
        let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .allCorners]

        for corn in allCorners {
            if corners.contains(corn) {
                switch corn {
                case .topLeft:
                    arr.insert(.layerMinXMinYCorner)

                case .topRight:
                    arr.insert(.layerMaxXMinYCorner)

                case .bottomLeft:
                    arr.insert(.layerMinXMaxYCorner)

                case .bottomRight:
                    arr.insert(.layerMaxXMaxYCorner)

                case .allCorners:
                    arr.insert(.layerMinXMinYCorner)
                    arr.insert(.layerMaxXMinYCorner)
                    arr.insert(.layerMinXMaxYCorner)
                    arr.insert(.layerMaxXMaxYCorner)

                default:
                    break
                }
            }
        }
        self.layer.maskedCorners = arr
    }

    func dropShadow(
        color: UIColor = UIColor(white: 0, alpha: 1),
        opacity: Float = 0.2,
        radius: CGFloat = 2,
        offset: CGSize = CGSize(width: 0, height: 2)
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
    }

    func addGradient(
        colors: [UIColor],
        locations: [NSNumber] = [0, 1],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1),
        animateDuration: CFTimeInterval? = nil
    ) {
        let gradient = CAGradientLayer()
        gradient.frame.size = self.frame.size
        gradient.colors = colors.map{ $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint

        if let duration = animateDuration {
            let animation = CABasicAnimation(keyPath: "gradientColors")
            animation.fromValue = [self.backgroundColor ?? .clear]
            animation.toValue = gradient.colors
            animation.duration = duration
            gradient.add(animation, forKey: nil)
        }

        self.layer.insertSublayer(gradient, at: 0)
    }

    func showHideInStackView(
        _ show: Bool,
        customAction: (() -> Void)? = nil,
        animated: Bool = true
    ) {
        if !animated {
            self.isHiddenInStack = !show
            return
        }
        let alpha: CGFloat = show ? 1 : 0
        self.alpha = show ? 0 : 1
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.isHiddenInStack = !show
            self?.alpha = alpha
            customAction?()
            self?.superview?.layoutIfNeeded()
        })
    }
    
    func preventScreenshot() {
        SecureView.preventScreenshot(for: self)
    }
}
