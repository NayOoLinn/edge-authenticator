import RxSwift
import UIKit
import AVFoundation

class QrScanViewController: BaseViewController, ViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    typealias ViewModelType = QrScanViewModel
    var viewModel: ViewModelType!
    
    private lazy var scanner: ScannerManager = {
        return ScannerManager.init(
            cameraView: cameraView,
            cutoutSize: CGSize(
                width: UIScreen.main.bounds.width * 0.75,
                height:  UIScreen.main.bounds.width * 0.75
            )
        )
    }()
    
    private lazy var photoLibrary: PhotoLibraryManager = {
        return PhotoLibraryManager(presenter: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel(viewModel)
    }
    
    override func setUpViews() {
        torchButton.setImage(UIImage(named: "icon-bolt-off"), for: .normal)
        torchButton.setImage(UIImage(named: "icon-bolt-filled"), for: .selected)
    }
    
    override func bindActions() {
        
        rx.viewDidAppear.take(1).subscribe(onNext: { [weak self] _ in
            self?.scanner.setupAndRun()
        }).disposed(by: disposeBag)
        
        rx.viewWillAppear.skip(1).subscribe(onNext: { [weak self] _ in
            self?.scanner.resumeScanning()
        }).disposed(by: disposeBag)
        
        rx.viewWillDisappear.subscribe(onNext: { [weak self] _ in
            self?.scanner.pauseScanning()
        }).disposed(by: disposeBag)
        
        torchButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.toggleTorch()
        }).disposed(by: disposeBag)
        
        // Scanner
        scanner.rx.result.subscribe(onNext: { [weak self] in
            self?.viewModel.routeToBindingKey.onNext(AuthCodeData(name: "", key: $0))
        }).disposed(by: disposeBag)
        
        Observable.merge(scanner.rx.permissionDenied, scanner.rx.deviceNotSupported)
            .subscribe(onNext: { [weak self] in
                self?.popThis()
            }).disposed(by: disposeBag)
        
        // Photo Library
        photoButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.photoLibrary.pickPhoto()
        }).disposed(by: disposeBag)
        
        photoLibrary.rx.result.subscribe(onNext: { [weak self] in
            self?.viewModel.routeToBindingKey.onNext(AuthCodeData(name: "", key: $0))
        }).disposed(by: disposeBag)
        
        photoLibrary.rx.error.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            AlertDialog.show(presentFrom: self, title: "Sorry", message: $0, positiveTitle: "OK")
        }).disposed(by: disposeBag)
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
    
    private func toggleTorch() {
        guard
            let device = AVCaptureDevice.default(for: .video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                torchButton.isSelected = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                torchButton.isSelected = true
            }
            device.unlockForConfiguration()
        } catch {
            // ignore
        }
    }

}
