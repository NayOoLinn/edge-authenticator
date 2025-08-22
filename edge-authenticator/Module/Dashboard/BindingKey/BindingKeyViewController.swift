import RxSwift
import UIKit

class BindingKeyViewController: BaseViewController, ViewController {
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var keyTextField: TextField!
    @IBOutlet weak var registerButton: AppButton!
    
    typealias ViewModelType = BindingKeyViewModel
    var viewModel: ViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    override func setUpViews() {
        registerButton.isEnabled = false
    }

    override func bindActions() {
        registerButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.saveAuthCode(
                name: nameTextField.text ?? "",
                key: keyTextField.text ?? ""
            )
            self.popToRoot()
        }).disposed(by: disposeBag)
    }

    func bindViewModel(_ viewModel: BindingKeyViewModel) {
        self.viewModel = viewModel

        let input = BindingKeyViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid(),
            onNameChanged: nameTextField.rx.text.emptyOnNil,
            onKeyChanged: keyTextField.rx.text.emptyOnNil
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
            self?.updateUI($0)
        }).disposed(by: disposeBag)
        
        output.enableButton.drive(onNext: { [weak self] in
            self?.registerButton.isEnabled = $0
        }).disposed(by: disposeBag)
    }
}
// MARK: - Update UI
extension BindingKeyViewController {

    func updateUI(_ data: AuthCodeData?) {
        
        nameTextField.text = data?.name ?? ""
        
        let keyIsEmpty = (data?.key ?? "").isEmpty
        keyTextField.text = data?.key
        
        keyTextField.updateBackgroundColor(keyIsEmpty ? Color.silver : Color.txtDim)
        keyTextField.isUserInteractionEnabled = keyIsEmpty
       
    }
}
