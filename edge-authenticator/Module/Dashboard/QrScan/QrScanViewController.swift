import RxSwift
import UIKit

class QrScanViewController: BaseViewController, ViewController {
    
    typealias ViewModelType = QrScanViewModel
    var viewModel: ViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    override func setUpViews() {
        
    }

    override func bindActions() {
        
    }

    func bindViewModel(_ viewModel: QrScanViewModel) {
        self.viewModel = viewModel

        let input = QrScanViewModel.Input(
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
    }
}
// MARK: - Update UI
extension QrScanViewController {

    func updateUI() {
        
    }
}
