import RxSwift
import UIKit

class OtpVerifyViewController: BaseViewController, ViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var otpTextField: AEOTPTextField!
    @IBOutlet weak var resendButton: AppButton!
    @IBOutlet weak var submitButton: AppButton!
    
    typealias ViewModelType = OtpVerifyViewModel
    var viewModel: ViewModelType!
    
    private let resendOtp = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    override func setUpViews() {
        setUpOTPField()
        stackView.preventScreenshot()
        resendButton.isEnabled = false
        submitButton.isEnabled = false
    }

    override func bindActions() {
        rx.viewDidAppear.take(1).mapToVoid()
            .subscribe(onNext: { [weak self] in
                self?.otpTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        otpTextField.rx.textChanged
            .subscribe(onNext: { [weak self] _ in
                self?.submitButton.isEnabled = false
            })
            .disposed(by: disposeBag)
        
        otpTextField.rx.userFinishEnter
            .subscribe(onNext: { [weak self] _ in
                self?.otpTextField.resignFirstResponder()
                self?.submitButton.isEnabled = true
            })
            .disposed(by: disposeBag)
        
        resendButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resendButton.isEnabled = false
                self?.resendOtp.onNext(())
            })
            .disposed(by: disposeBag)
        
        
        submitButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.popToRoot()
                AlertDialog.show(
                    presentFrom: self?.navigationController,
                    title: "Success",
                    message: "Your account have been activated successfully.",
                    positiveTitle: "OK"
                )
            })
            .disposed(by: disposeBag)
    }

    func bindViewModel(_ viewModel: OtpVerifyViewModel) {
        self.viewModel = viewModel

        let input = OtpVerifyViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid(),
            resentOtp: resendOtp,
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
        
        output.updateResendCountDown.drive(onNext: { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .available:
                self.resendButton.isEnabled = true
                self.resendButton.setTitle("Resend OTP", for: .normal)
            case .notAvailable(let remainingSeconds):
                self.resendButton.isEnabled = false
                self.resendButton.setTitle("Resend OTP in \(remainingSeconds)s", for: .normal)
            }
        }).disposed(by: disposeBag)
    }
}
// MARK: - Update UI
private extension OtpVerifyViewController {

    func setUpOTPField() {
        otpTextField.otpFont = Font.semiBold.of(size: 16)
        otpTextField.otpTextColor = Color.primaryBold

        otpTextField.otpCornerRaduis = 6
        otpTextField.otpBackgroundColor = .clear
        otpTextField.otpFilledBackgroundColor = .clear
        
        otpTextField.otpDefaultBorderColor = Color.txtParagraph
        otpTextField.otpFilledBorderColor = Color.primaryBold
        otpTextField.otpDefaultBorderWidth = 1
        otpTextField.otpFilledBorderWidth = 1.5
        
        otpTextField.configure(with: 6)
        otpTextField.clearOTP()
    }
    
    func updateUI() {
        
    }
}
