import RxSwift
import UIKit

class SplashViewController: BaseViewController, ViewController {

    var viewModel: SplashViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    func bindViewModel(_ viewModel: SplashViewModel) {
        self.viewModel = viewModel

        let input = SplashViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid()
        )

        let output = viewModel.transform(input: input)

        output.fullLoading.drive(onNext: { [weak self] in
            self?.showHideFullLoading($0)
        }).disposed(by: disposeBag)

        output.error.drive(onNext: { [weak self] in
            self?.showAlert(message: $0.localizedDescription)
        }).disposed(by: disposeBag)

        output.routeToHome.drive(onNext: { [weak self] in
            self?.viewModel.routeToHome.onNext(())
        }).disposed(by: disposeBag)
    }
}
