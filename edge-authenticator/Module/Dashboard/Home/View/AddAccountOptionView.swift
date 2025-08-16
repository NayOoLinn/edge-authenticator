
import UIKit
import RxSwift

public class AddAccountOptionView: UIView {
    
    // MARK: IBOutlet
    @IBOutlet fileprivate weak var qrCodeButton: UIButton!
    @IBOutlet fileprivate weak var bindingKeyButton: UIButton!
    
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
        
        view.dropShadow()
        view.isUserInteractionEnabled = true
        
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
    }
}
extension Reactive where Base: AddAccountOptionView {
    
    var onTapQrCode: Observable<Void> {
        base.qrCodeButton.rx.tap.asObservable()
    }
    
    var onTapBindingKey: Observable<Void> {
        base.bindingKeyButton.rx.tap.asObservable()
    }
}
