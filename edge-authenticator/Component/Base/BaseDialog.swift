import UIKit

open class BaseDialog: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var handle: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    
    @IBOutlet public weak var tableView: UITableView?
    @IBOutlet weak var tblHeight: NSLayoutConstraint?
    
    var viewDidSet = false
    var tapGestureDismissal = true
    var panGestureDismissal = true
    var contentViewOriginalCenterY: CGFloat = 0
    
    var setCornersForAll = false
    var setCorners = true
    let appearAnimationDuration: TimeInterval = 0.3
    let disappearAnimationDuration: TimeInterval = 0.3
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.quit))
        backgroundView?.addGestureRecognizer(tap)
        addBlurEffect()
        setUpView()
        setUpAnimation()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewDidSet { return }
        viewDidSet = true
        appearAnimation()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if setCorners {
            if setCornersForAll {
                contentView?.viewCornerRadius = 12
            } else {
                contentView?.roundCorners(radius: 12, corners: [.topLeft, .topRight])
            }
        }
        if tapGestureDismissal { addTapGesture() }
        if panGestureDismissal { addPanGesture() }
    }
    
    func setUpView() {
        cancelButton?.addTarget(self, action: #selector(quit), for: .touchUpInside)
    }
    
    public func calculateTableHeight(tableHeight: CGFloat? = nil) {
        
        guard tableView != nil else { return }
        
        tableView?.reloadData()
        tableView?.layoutIfNeeded()
        
        let maxHeight = UIScreen.main.bounds.height * 0.85 // 85 percent of screen
        let totalHeight = tableHeight ?? tableView?.contentSize.height ?? 0

        if totalHeight > maxHeight {
            tblHeight?.constant = maxHeight
            tableView?.alwaysBounceVertical = true
            tableView?.isScrollEnabled = true
        } else {
            tblHeight?.constant = totalHeight
            tableView?.alwaysBounceVertical = false
            tableView?.isScrollEnabled = false
        }
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.quit))
        backgroundView?.addGestureRecognizer(tap)
    }
    
    func addPanGesture() {
        contentViewOriginalCenterY = contentView?.center.y ?? 0
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hanldePanGesture(_:)))
        contentView?.addGestureRecognizer(panGesture)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView?.bounds ?? .zero
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView?.alpha = 0.3
        backgroundView?.addSubview(blurEffectView)
    }
    
    func setUpAnimation() {
        self.contentView?.alpha = 0
    }
    
    func appearAnimation() {
        guard let content = contentView else { return }
        CustomAnimation.moveFrom(direction: .BOTTOM, view: content, fromX: 0, fromY: UIScreen.main.bounds.height, duration: appearAnimationDuration, delay: 0, completed: nil)
    }
    
    func disappearAnimation() {
        guard let content = contentView else { return }
        CustomAnimation.moveTo(direction: .BOTTOM, view: content, toX: 0, toY: UIScreen.main.bounds.height, duration: disappearAnimationDuration, delay: 0, completed: nil)
    }
    
    @objc open func quit() {
        disappearAnimation()
        dismiss(animated: true)
    }
    
    @objc func hanldePanGesture(_ panGesture:UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        guard let content = contentView else { return }
        
        
        if content.center.y + translation.y > contentViewOriginalCenterY {
            handle?.alpha = 0.5
            handle?.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.5)
            contentView?.center = CGPoint(x: content.center.x, y: content.center.y + translation.y)
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if panGesture.state == UIGestureRecognizer.State.ended {
            handle?.alpha = 0.2
            handle?.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            if content.center.y - contentViewOriginalCenterY > content.frame.height/2 {
                quit()
            } else {
                bounceBackToOrignalPosition()
            }
        }
    }
    
    func bounceBackToOrignalPosition() {
        //usingSpringWithDamping - higher values make the bouncing finish faster.
        //initialSpringVelocity - higher values give the spring more initial momentum.
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.contentView?.center = CGPoint(x: self.contentView?.center.x ?? 0, y: self.contentViewOriginalCenterY)
        }, completion: nil)
    }
}
