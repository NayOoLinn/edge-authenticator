//
import UIKit
import RxSwift

public class NavBar: UIView {
    
    // MARK: IBInspectable
    @IBInspectable public var navTitle: String? = nil {
        didSet {
            lblNavTitle.text = navTitle
        }
    }
    @IBInspectable public var navTitleFontSize: CGFloat = 14 {
        didSet {
            lblNavTitle.font = Font.semiBold.of(size: navTitleFontSize)
        }
    }
    @IBInspectable public var navTitleColor: UIColor = Color.txtTitle {
        didSet {
            lblNavTitle.textColor = navTitleColor
        }
    }
    @IBInspectable public var navTitleAligment: String = "left" {
        didSet {
            switch navTitleAligment.lowercased() {
            case "left": lblNavTitle.textAlignment = .left
            case "center": lblNavTitle.textAlignment = .center
            case "right": lblNavTitle.textAlignment = .right
            default: lblNavTitle.textAlignment = .left
            }
            
        }
    }
    
    @IBInspectable public var viewBackgroundColor: UIColor = .white {
        didSet {
            self.backgroundColor = viewBackgroundColor
        }
    }
    
    @IBInspectable public var showBackButton: Bool = true {
        didSet {
            backButton.isHidden = !showBackButton
        }
    }
    
    @IBInspectable public var defaultBackAction: Bool = true
    
    @IBInspectable var backButtonImage: UIImage? = UIImage(named: "icon-chevron-left") {
        didSet {
            backButton.setImage(backButtonImage, for: .normal)
            backButton.setTitle(nil, for: .normal)
        }
    }
    
    @IBInspectable public var backButtonColor: UIColor? = Color.txtTitle {
        didSet {
            if let color = backButtonColor {
                backButton.setImage(backButtonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
                backButton.tintColor = color
            }
        }
    }
    
    @IBInspectable public var rightButtonImage: UIImage? = nil {
        didSet {
            rightButton.setImage(rightButtonImage, for: .normal)
            rightButton.alpha = rightButtonImage == nil ? 0 : 1
        }
    }
   
    @IBInspectable public var rightButtonColor: UIColor? = nil {
        didSet {
            rightButton.setImage(rightButtonImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton.tintColor = rightButtonColor
        }
    }
    
    // MARK: IBOutlet
    @IBOutlet public weak var rightButton: UIButton!
    @IBOutlet public weak var backButton: UIButton!
    @IBOutlet public weak var lblNavTitle: UILabel!
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MAKR: Setup
    fileprivate func setupView() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setUpViews()
        
        addSubview(view)
        
        self.backgroundColor = .clear
    }
    
    fileprivate func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view
    }
    
    func setUpViews() {
        backButton.addTarget(self, action: #selector(self.tapToDismiss), for: .touchUpInside)
    }
    
    public func setTitle(_ title: String) {
        self.navTitle = title
        lblNavTitle.text = title
    }
    
    private func makeTransparent() {
        self.backgroundColor = UIColor.clear
    }
    
    public func setNavColor(
        bgColor: UIColor = UIColor.white,
        backBtnColor: UIColor = Color.txtTitle,
        titleColor: UIColor = Color.txtTitle
    ) {
        self.backgroundColor = bgColor
        
        backButton.setImage(UIImage(named: "icon-chevron-left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = backBtnColor
        lblNavTitle.textColor = titleColor
    }
    
    public func removeTitleGestures() {
        lblNavTitle.gestureRecognizers?.forEach {
            lblNavTitle.removeGestureRecognizer($0)
        }
    }
    
    public func removeDefaultBackAction() {
        backButton.removeTarget(self, action: #selector(tapToDismiss), for: .touchUpInside)
    }
    
    @objc private func tapToDismiss() {
        if (parentViewController?.navigationController) != nil && (parentViewController?.navigationController?.viewControllers.count ?? 0 > 1) {
            parentViewController?.navigationController?.popViewController(animated: true)
        } else {
            parentViewController?.dismiss(animated: true)
        }
    }
}

extension Reactive where Base: NavBar {
    
    var onTapRightButton: Observable<Void> {
        base.rightButton.rx.tap.asObservable()
    }
}
