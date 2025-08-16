//

import UIKit
import RxSwift

class AlertDialog: BaseDialog {

    static func show(
        presentFrom vc: UIViewController?,
        title: String = "", message: String = "",
        positiveTitle: String? = "OK",
        positiveAction: (() -> Void)? = nil,
        negativeTitle: String? = nil,
        negativeAction: (() -> Void)? = nil
    ) {
        
        guard let vc = vc else { return }
        
        let dialog = AlertDialog()
        dialog.titleText = title
        dialog.message = message
        dialog.positiveTitle = positiveTitle
        dialog.negativeTitle = negativeTitle
        vc.present(dialog, animated: true)
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var seperator: UIView!
    
    var titleText: String = ""
    var message: String = ""
    
    var positiveTitle: String? = "OK"
    var positiveAction: (() -> Void)?
    
    var negativeTitle: String? = nil
    var negativeAction: (() -> Void)?
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        bindActions()
    }

    private func setUpViews() {
        setCornersForAll = true
        
        titleLabel?.text = titleText
        titleLabel?.isHidden = titleText.isEmpty
        
        messageLabel.text = message
        messageLabel.isHidden = message.isEmpty
        
        confirmButton.setTitle(positiveTitle, for: .normal)
        confirmButton.isHidden = positiveTitle == nil
        
        cancelButton?.setTitle(negativeTitle, for: .normal)
        cancelButton?.isHidden = negativeTitle == nil
        
        seperator.isHidden = positiveTitle == nil || negativeTitle == nil
    }
    
    private func bindActions() {
        confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.quit()
            self?.positiveAction?()
        }).disposed(by: disposeBag)
        
        cancelButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.negativeAction?()
        }).disposed(by: disposeBag)
    }
}
