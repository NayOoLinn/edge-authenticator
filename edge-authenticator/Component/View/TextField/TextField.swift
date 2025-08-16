import UIKit
import RxSwift

public class TextField: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet public weak var leftIconView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var line: UIView!

    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var leftIconWidth: NSLayoutConstraint!
    @IBOutlet weak var rightIconWidth: NSLayoutConstraint!

    @IBInspectable public var bgColor: UIColor {
        get {
            return backgroundView.backgroundColor ?? .clear
        } set {
            updateBackgroundColor(newValue)
        }
    }

    @IBInspectable public var leftIcon: UIImage? {
        get {
            return leftIconView.image
        } set {
            updateLeftIcon(newValue)
        }
    }

    @IBInspectable public var leftIconColor: UIColor? {
        didSet {
            updateLeftIcon(leftIcon?.withRenderingMode(.alwaysTemplate))
            leftIconView.tintColor = leftIconColor
        }
    }

    @IBInspectable public var leftIconSize: CGFloat {
        get {
            return leftIconWidth.constant
        } set {
            leftIconWidth.constant = newValue
        }
    }
    
    @IBInspectable public var leftMargin: CGFloat {
        get {
            return leftPadding.constant
        } set {
            leftPadding.constant = newValue
        }
    }

    @IBInspectable public var font: UIFont = Font.regular.of(size: 16) {
        didSet {
            textField.font = font
        }
    }

    @IBInspectable public var textColor: UIColor = Color.txtTitle {
        didSet {
            textField.textColor = textColor
        }
    }

    @IBInspectable public var textAlignment: NSTextAlignment = .left {
        didSet {
            textField.textAlignment = textAlignment
        }
    }

    @IBInspectable public var placeholderColor: UIColor = Color.txtDim {
        didSet {
            updatePlaceholder(placeholder)
        }
    }

    @IBInspectable public var placeholder: String {
        get {
            return textField.placeholder ?? ""
        } set {
            updatePlaceholder(newValue)
        }
    }

    @IBInspectable public var rightNormalIcon: UIImage? {
        get {
            return rightButton.image(for: .normal)
        } set {
            updateRightIcon(newValue, state: .normal)
        }
    }

    @IBInspectable public var rightSelectedIcon: UIImage? {
        get {
            return rightButton.image(for: .selected)
        } set {
            updateRightIcon(newValue, state: .selected)
        }
    }

    @IBInspectable public var rightIconSize: CGFloat {
        get {
            return rightIconWidth.constant
        } set {
            rightIconWidth.constant = newValue
        }
    }
    
    @IBInspectable public var rightMargin: CGFloat {
        get {
            return rightPadding.constant
        } set {
            rightPadding.constant = newValue
        }
    }

    @IBInspectable public var showLine: Bool = true {
        didSet {
            line.isHidden = !showLine
        }
    }

    @IBInspectable public var keyboardType: String = UIKeyboardType.default.rawString {
        didSet {
            setUpTextField(.text(.init(rawString: keyboardType)), isSecureEntry: isSecureEntry)
        }
    }

    @IBInspectable public var isSecureEntry: Bool = false {
        didSet {
            setUpTextField(.text(.init(rawString: keyboardType)), isSecureEntry: isSecureEntry)
        }
    }

    fileprivate let onTextChanged = BehaviorSubject(value: "")
    fileprivate let onTapRightButton = PublishSubject<Void>()
    fileprivate lazy var tapGesture = UITapGestureRecognizer()
    private let disposeBag = DisposeBag()

    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
    }

    // MAKR: Setup
    private func setupView() {
        guard let contentView = loadViewFromNib() else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        initView()

        addSubview(contentView)
    }

    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view
    }

    private func initView() {

        textField.autocorrectionType = .no
        textField.tintColor = Color.primaryBold
        textField.font = font
        textField.textColor = textColor
        textField.textAlignment = textAlignment

        bindAction()
    }

    public func setUpTextField(_ editType: EditType, isSecureEntry: Bool) {
        switch editType {
        case .text(let keyboardType):
            textField.keyboardType = keyboardType
            textField.isUserInteractionEnabled = true
        case .tapAction:
            textField.isUserInteractionEnabled = false
            addTapAction()
        }

        textField.isSecureTextEntry = isSecureEntry
        rightNormalIcon = isSecureEntry ? UIImage(named: "icon_eye_slash") : nil
        rightSelectedIcon = isSecureEntry ? UIImage(named: "icon_eye") : nil
    }

    private func bindAction() {
        textField.rx.text.orEmpty.subscribe(onNext: { [weak self] in
            self?.onTextChanged.onNext($0)
        }).disposed(by: disposeBag)

        rightButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.isSecureEntry {
                self.rightButton.isSelected.toggle()
                self.textField.isSecureTextEntry = !self.rightButton.isSelected
            } else {
                self.onTapRightButton.onNext(())
            }
        }).disposed(by: disposeBag)
    }

    public func updateBackgroundColor(_ color: UIColor) {
        backgroundView.backgroundColor = color
    }

    public func updateLeftIcon(_ image: UIImage?) {
        leftIconView.image = image
        leftIconView.isHidden = image == nil
    }

    public func updateRightIcon(_ image: UIImage?, state: UIControl.State) {
        rightButton.setImage(image, for: state)
        rightButton.isHidden = image == nil
    }

    public func updatePlaceholder(_ placeholder: String) {
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Font.regular.of(size: 16),
            NSAttributedString.Key.foregroundColor: placeholderColor
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: placeholderAttributes
        )
    }

    private func addTapAction() {
        self.gestureRecognizers?.forEach { self.removeGestureRecognizer($0) }
        self.addGestureRecognizer(tapGesture)
    }
}
// MARK: - Display Model
extension TextField {

    public struct DisplayModel {
        let backgroundColor: UIColor
        let leftIcon: UIImage?
        let placeholder: String
        let editType: EditType
        let isSecure: Bool

        public init(
            backgroundColor: UIColor = .clear,
            leftIcon: UIImage? = nil,
            placeholder: String,
            editType: EditType,
            isSecure: Bool
        ) {
            self.backgroundColor = backgroundColor
            self.leftIcon = leftIcon
            self.placeholder = placeholder
            self.editType = editType
            self.isSecure = isSecure
        }
    }

    public enum EditType {
        case text(UIKeyboardType)
        case tapAction
    }

}
// MARK: - Reactive
public extension Reactive where Base: TextField {

    var textChanged: Observable<String> {
        return base.onTextChanged.map { $0 }
    }

    var tapRightButton: Observable<Void> {
        return base.onTapRightButton
    }

    var tap: Observable<Void> {
        return base.tapGesture.rx.event.mapToVoid()
    }
}
// MARK: - UIKeyboardType
public extension UIKeyboardType {

    init(rawString: String) {
        switch rawString {
        case UIKeyboardType.default.rawString: self = .default
        case UIKeyboardType.asciiCapable.rawString: self = .asciiCapable
        case UIKeyboardType.numbersAndPunctuation.rawString: self = .numbersAndPunctuation
        case UIKeyboardType.URL.rawString: self = .URL
        case UIKeyboardType.numberPad.rawString: self = .numberPad
        case UIKeyboardType.phonePad.rawString: self = .phonePad
        case UIKeyboardType.namePhonePad.rawString: self = .namePhonePad
        case UIKeyboardType.emailAddress.rawString: self = .emailAddress
        case UIKeyboardType.decimalPad.rawString: self = .decimalPad
        case UIKeyboardType.twitter.rawString: self = .twitter
        case UIKeyboardType.webSearch.rawString: self = .webSearch
        case UIKeyboardType.asciiCapableNumberPad.rawString: self = .asciiCapableNumberPad
        case UIKeyboardType.alphabet.rawString: self = .alphabet
        default: self = .default
        }
    }

    var rawString: String {
        switch self {
        case .default: "default"
        case .asciiCapable: "asciiCapable"
        case .numbersAndPunctuation: "numbersAndPunctuation"
        case .URL: "URL"
        case .numberPad: "numberPad"
        case .phonePad: "phonePad"
        case .namePhonePad: "namePhonePad"
        case .emailAddress: "emailAddress"
        case .decimalPad: "decimalPad"
        case .twitter: "twitter"
        case .webSearch: "webSearch"
        case .asciiCapableNumberPad: "asciiCapableNumberPad"
        case .alphabet: "alphabet"
        @unknown default: ""
        }
    }
}
