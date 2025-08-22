import UIKit

@IBDesignable
class AppButton: UIButton {
    
    // MARK: - Inspectable Colors
    @IBInspectable var normalBgColor: UIColor = Color.primaryBold {
        didSet {
            if isEnabled { backgroundColor = normalBgColor }
        }
    }
    
    @IBInspectable var disableBgColor: UIColor = Color.disable {
        didSet {
            if !isEnabled { backgroundColor = disableBgColor }
        }
    }
    
    // MARK: - State Handling
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? normalBgColor : disableBgColor
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    private func initView() {
        backgroundColor = normalBgColor
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
