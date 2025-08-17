import UIKit
import ESPullToRefresh
import NVActivityIndicatorView

final class ESRefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
    var state: ESPullToRefresh.ESRefreshViewState = .pullToRefresh
    var view: UIView { return animatorView }
    var insets: UIEdgeInsets = .zero
    var trigger: CGFloat = 40
    var executeIncremental: CGFloat = 40
    
    private let animatorView: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 20, height: 20),
            type: .ballClipRotateMultiple,
            color: Color.yellowBold
        )
        return view
    }()
    
    func refreshAnimationBegin(view: ESRefreshComponent) {
        if animatorView.isAnimating { return }
        animatorView.startAnimating()
    }
    
    func refreshAnimationEnd(view: ESRefreshComponent) {
        animatorView.stopAnimating()
    }
    
    func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        if animatorView.isAnimating { return }
        animatorView.startAnimating()
    }
    
    func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        // Optional: react to state changes (.idle, .pulling, .refreshing, .finished)
    }
}
