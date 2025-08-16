import UIKit

extension UIApplication {

    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return scene.windows.first(where: { $0.isKeyWindow })
            }
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        return nil
    }
}
