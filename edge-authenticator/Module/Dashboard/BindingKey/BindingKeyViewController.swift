import RxSwift
import UIKit

class BindingKeyViewController: BaseViewController, ViewController {
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var keyTextField: TextField!
    @IBOutlet weak var registerButton: UIButton!
    
    typealias ViewModelType = BindingKeyViewModel
    var viewModel: ViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    override func setUpViews() {
        
    }

    override func bindActions() {
        registerButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.saveAuthCode()
            self?.viewModel.routeToOTPVerify.onNext(())
        }).disposed(by: disposeBag)
    }

    func bindViewModel(_ viewModel: BindingKeyViewModel) {
        self.viewModel = viewModel

        let input = BindingKeyViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid(),
        )

        let output = viewModel.transform(input: input)

        output.fullLoading.drive(onNext: { [weak self] in
            self?.showHideFullLoading($0)
        }).disposed(by: disposeBag)

        output.error.drive(onNext: { [weak self] in
            self?.showAlert(
                message: $0.localizedDescription
            )
        }).disposed(by: disposeBag)
        
        output.updateUI.drive(onNext: { [weak self] in
            self?.updateUI(key: $0)
        }).disposed(by: disposeBag)
    }
    
    private func saveAuthCode() {
        let authCode = AuthCodeData()
        authCode.name = nameTextField.text ?? ""
        authCode.key = nameTextField.text ?? ""
        RealmManager.shared.add(authCode)
    }
}
// MARK: - Update UI
extension BindingKeyViewController {

    func updateUI(key: String?) {
        let keyIsEmpty = (key ?? "").isEmpty
        keyTextField.text = key
        
        keyTextField.updateBackgroundColor(keyIsEmpty ? Color.silver : Color.txtDim)
        keyTextField.isUserInteractionEnabled = keyIsEmpty
       
    }
}
