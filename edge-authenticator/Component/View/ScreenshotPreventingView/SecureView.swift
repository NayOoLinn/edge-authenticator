import UIKit

class SecureView {
    
    static func preventScreenshot(for view: UIView) {
        guard let superview = view.superview else { return }
        
        let container = ScreenshotPreventingView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        if let stackView = superview as? UIStackView {
            let index = stackView.arrangedSubviews.firstIndex(of: view)!
            stackView.insertArrangedSubview(container, at: index)
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            
            let constraintsToCopy = view.constraints.filter {
                $0.firstAttribute == .height || $0.firstAttribute == .width
            }
            for constraint in constraintsToCopy {
                let newConstraint = NSLayoutConstraint(
                    item: container,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: constraint.secondItem,
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                newConstraint.priority = constraint.priority
                newConstraint.shouldBeArchived = constraint.shouldBeArchived
                newConstraint.identifier = constraint.identifier
                container.addConstraint(newConstraint)
            }
            
        } else {
            // 🔹 Normal case: replace in superview
            superview.insertSubview(container, aboveSubview: view)
            
            let constraintsToCopy = superview.constraints.filter {
                $0.firstItem as? UIView == view || $0.secondItem as? UIView == view
            }
            
            for constraint in constraintsToCopy {
                var firstItem = constraint.firstItem
                var secondItem = constraint.secondItem
                
                if firstItem as? UIView == view { firstItem = container }
                if secondItem as? UIView == view { secondItem = container }
                
                let newConstraint = NSLayoutConstraint(
                    item: firstItem as Any,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: secondItem,
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                newConstraint.priority = constraint.priority
                newConstraint.shouldBeArchived = constraint.shouldBeArchived
                newConstraint.identifier = constraint.identifier
                
                superview.addConstraint(newConstraint)
            }
            
            superview.removeConstraints(constraintsToCopy)
        }
        
        container.setup(contentView: view)
    }
}
