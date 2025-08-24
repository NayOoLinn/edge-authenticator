//

import UIKit
import RxSwift

class AlertView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var seperator: UIView!
    
    var titleText: String = ""
    var message: String = ""
    
    var positiveTitle: String? = "OK"
    var positiveAction: (() -> Void)?
    
    var negativeTitle: String? = nil
    var negativeAction: (() -> Void)?
    
    let disposeBag = DisposeBag()
    
    // MARK: Init
    init(
        title: String = "", message: String = "",
        positiveTitle: String? = "OK",
        positiveAction: (() -> Void)? = nil,
        negativeTitle: String? = nil,
        negativeAction: (() -> Void)? = nil
    ) {
        super.init(frame: .zero)
        
        self.titleText = title
        self.message = message
        self.positiveTitle = positiveTitle
        self.positiveAction = positiveAction
        self.negativeTitle = negativeTitle
        self.negativeAction = negativeAction
        
        setupView()
    }
    
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
        contentView.viewCornerRadius = 12
    
        titleLabel?.text = titleText
        titleLabel?.isHidden = titleText.isEmpty
        
        messageLabel.text = message
        messageLabel.isHidden = message.isEmpty
        
        confirmButton.setTitle(positiveTitle, for: .normal)
        confirmButton.isHidden = positiveTitle == nil
        
        cancelButton?.setTitle(negativeTitle, for: .normal)
        cancelButton?.isHidden = negativeTitle == nil
        
        seperator.isHidden = positiveTitle == nil || negativeTitle == nil
        buttonView.isHidden = positiveTitle == nil && negativeTitle == nil
        
        bindActions()
    }
    
    func setup(
        title: String = "", message: String = "",
        positiveTitle: String? = "OK",
        positiveAction: (() -> Void)? = nil,
        negativeTitle: String? = nil,
        negativeAction: (() -> Void)? = nil
    ) {
        self.titleText = title
        self.message = message
        self.positiveTitle = positiveTitle
        self.positiveAction = positiveAction
        self.negativeTitle = negativeTitle
        self.negativeAction = negativeAction
    }
    
    func setActions(
        positiveAction: (() -> Void)? = nil,
        negativeAction: (() -> Void)? = nil
    ) {
        self.positiveAction = positiveAction
        self.negativeAction = negativeAction
    }

    private func bindActions() {
        confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.positiveAction?()
        }).disposed(by: disposeBag)
        
        cancelButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.negativeAction?()
        }).disposed(by: disposeBag)
    }
}
