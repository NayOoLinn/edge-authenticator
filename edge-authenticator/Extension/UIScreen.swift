import UIKit

extension UIScreen {

    static var current: UIScreen? {
        UIApplication.keyWindow?.screen
    }

    static var width: CGFloat {
        current?.bounds.width ?? 0
    }

    static var height: CGFloat {
        current?.bounds.height ?? 0
    }
    
    static var safeAreaInset: UIEdgeInsets  {
        UIApplication.keyWindow?.safeAreaInsets ?? .zero
    }
}
