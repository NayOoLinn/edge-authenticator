import UIKit

extension UIViewController {

    static func instantiate(from storyboard: UIStoryboard) -> Self {
        return storyboard.instantiateViewController(withIdentifier: Self.className) as! Self
    }

}
