import RxSwift
import UIKit

class HomeViewController: BaseViewController, ViewController {

    @IBOutlet weak var headerView: HomeHeaderView!
    @IBOutlet weak var authTableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    typealias ViewModelType = HomeViewModel
    var viewModel: ViewModelType!
    
    private let generateNewCodes = PublishSubject<Void>()
    
    private lazy var addAccountPopTip = {
        let popTip = PopTip()
        popTip.maskColor = UIColor.black.withAlphaComponent(0.1)
        popTip.shouldShowMask = true
        popTip.arrowSize = CGSize(width: 0, height: 0)
        popTip.bubbleColor = .clear
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnTap = false
        popTip.tapToRemoveGestureRecognizer?.cancelsTouchesInView = false
        return popTip
    }()
    
    private lazy var addAccountOptionView = {
        let optionView = AddAccountOptionView(
            frame: CGRect(x: 0, y: 0, width: 280, height: 140)
        )
        return optionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }

    override func setUpViews() {
        authTableView.showsVerticalScrollIndicator = false
        authTableView.register(
            nib: AuthCodeTableCell.className,
            bundle: Bundle(for: AuthCodeTableCell.self)
        )
        authTableView.delegate = self
        authTableView.dataSource = self
        authTableView.contentInset = .init(
            top: 16, left: 0,
            bottom: 56 + UIScreen.safeAreaInset.bottom, right: 0
        )
        authTableView.rowHeight = UITableView.automaticDimension
        authTableView.estimatedRowHeight = 60
        authTableView.separatorStyle = .none
    }

    override func bindActions() {
        
        headerView.rx.onTapMenu.subscribe(onNext: { [weak self] in
            self?.viewModel.routeToDrawer.onNext(())
        }).disposed(by: disposeBag)
        
        plusButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.showAddAccountPopTip()
        }).disposed(by: disposeBag)
        
        addAccountOptionView.rx.onTapQrCode.subscribe(onNext: { [weak self] in
            self?.addAccountPopTip.hide()
            self?.viewModel.routeToQrScan.onNext(())
        }).disposed(by: disposeBag)
        
        addAccountOptionView.rx.onTapBindingKey.subscribe(onNext: { [weak self] in
            self?.addAccountPopTip.hide()
            self?.viewModel.routeToBindingKey.onNext(())
        }).disposed(by: disposeBag)
    }

    func bindViewModel(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel

        let input = HomeViewModel.Input(
            onViewAppear: rx.viewWillAppear.take(1).mapToVoid(),
            generateNewCodes: Observable.merge(
                generateNewCodes,
                rx.willEnterForeground,
                rx.viewWillAppear.skip(1).mapToVoid()
            ),
            pauseTimer: Observable.merge(
                rx.viewWillDisappear.mapToVoid(),
                rx.didEnterBackground
            )
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
            self?.updateUI()
        }).disposed(by: disposeBag)
        
        output.codeExpired.drive(onNext: { [weak self] in
            self?.generateNewCodes.onNext(())
        }).disposed(by: disposeBag)
    }
}
// MARK: - Update UI
extension HomeViewController {

    func updateUI() {
        authTableView.reloadData()
    }
    
    func showAddAccountPopTip() {
        addAccountPopTip.show(
            customView: addAccountOptionView,
            direction: .up,
            in: self.view,
            from: plusButton.frame
        )
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.deque(AuthCodeTableCell.self)
        cell.config(viewModel.data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
