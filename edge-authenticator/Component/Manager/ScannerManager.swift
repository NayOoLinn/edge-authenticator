import RxSwift
import UIKit
import AVFoundation

public class ScannerManager: NSObject {
    
    private let cameraView: UIView
    private let cutoutSize: CGSize
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let maskView = ScanMaskView()
    private let scanLine = UIView()
    private var videoOutput: AVCaptureMetadataOutput?
    private var didScanCode = false
    
    fileprivate let onResult = PublishSubject<String>()
    fileprivate let onPermissionDenied = PublishSubject<Void>()
    fileprivate let onDeviceNotSupported = PublishSubject<Void>()
    
    private lazy var cutoutFrame: CGRect = {
        let w = cutoutSize.width
        let h = cutoutSize.height
        return CGRect(x: (cameraView.bounds.width - w)/2, y: (cameraView.bounds.height - h)/2, width: w, height: h)
    }()
    
    private let captureQueue = DispatchQueue(label: (Bundle.main.bundleIdentifier ?? "com.edge-authenticator") + ".captureSession")
    
    public init(cameraView: UIView, cutoutSize: CGSize) {
        self.cameraView = cameraView
        self.cutoutSize = cutoutSize
        super.init()
    }
    
    public func setupAndRun() {
        configureCamera()
        configurePreview()
        configureMask()
        configureScanLine()
        setUpFrames()
        startCaptureSession()
        startScanLineAnimation()
        DispatchQueue.main.async(execute: {
            self.setInterestRect()
        })
    }
    
    public func resumeScanning() {
        didScanCode = false
        startCaptureSession()
        scanLine.layer.removeAllAnimations()
        startScanLineAnimation()
    }
    
    public func pauseScanning() {
        stopCaptureSession()
        scanLine.layer.removeAllAnimations()
    }
    
    public func setInterestRect() {
        if let output = videoOutput {
            let convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: cutoutFrame)
            output.rectOfInterest = convertedRect
        }
    }
    
    private func startCaptureSession() {
        captureQueue.async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }
    private func stopCaptureSession() {
        captureQueue.async { [weak self] in
            guard let self = self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }
    
    private func showPermissionsAlert() {
        guard let viewController = cameraView.parentViewController else { return }
        
        AlertDialog.show(
            presentFrom: viewController,
            title: "Camera Access Needed",
            message: "Enable camera in Settings to scan QR codes.",
            positiveTitle: "Open Settings",
            positiveAction: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            },
            negativeTitle: "Cancel",
            negativeAction: { [weak self] in
                self?.onPermissionDenied.onNext(())
            }
        )
    }
    
    private func showUnsupportedAlert() {
        guard let viewController = cameraView.parentViewController else { return }

        AlertDialog.show(
            presentFrom: viewController,
            title: "Unsupported",
            message: "This device does not support QR scanning.",
            positiveTitle: "Quit",
            positiveAction: { [weak self] in
                self?.onDeviceNotSupported.onNext(())
            }
        )
    }
    
}
// MARK: - config
private extension ScannerManager {
    func configureCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.setupSession() : self?.showPermissionsAlert()
                }
            }
        default:
            showPermissionsAlert()
        }
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Input
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else {
            showUnsupportedAlert()
            return
        }
        captureSession.addInput(input)
        
        // Output
        let output = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(output) else {
            showUnsupportedAlert()
            return
        }
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
        videoOutput = output
    }
    
    func configurePreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraView.layer.addSublayer(previewLayer)
    }
    
    func configureMask() {
        maskView.backgroundColor = .clear
        maskView.isUserInteractionEnabled = false
        maskView.cutoutCornerRadius = 16
        maskView.borderColor = Color.primaryBold.withAlphaComponent(0.9)
        maskView.borderWidth = 2
        cameraView.addSubview(maskView)
    }
    
    func configureScanLine() {
        scanLine.backgroundColor = Color.primaryBold
        scanLine.layer.cornerRadius = 1
        scanLine.isUserInteractionEnabled = false
        cameraView.addSubview(scanLine)
    }
    
    // MARK: - Helpers
    func layoutScanLine() {
        let frame = cutoutFrame
        scanLine.frame = CGRect(x: frame.minX + 8, y: frame.minY + 8, width: frame.width - 16, height: 2)
    }
    
    func startScanLineAnimation() {
        let frame = cutoutFrame
        let startY = frame.minY + 8
        let endY = frame.maxY - 10
        
        scanLine.layer.removeAllAnimations()
        scanLine.layer.position.y = startY
        
        let anim = CABasicAnimation(keyPath: "position.y")
        anim.fromValue = startY
        anim.toValue = endY
        anim.duration = 1.6
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scanLine.layer.add(anim, forKey: "scanLine")
    }
    
    func normalizedRectOfInterest(for rect: CGRect) -> CGRect {
        // rectOfInterest is in a normalized coordinate space (portrait), relative to the video.
        // AVCaptureVideoPreviewLayer helps map view rect -> metadata rect.
        // Ensure orientation is portrait; adjust if your UI supports rotation.
        guard let layer = previewLayer else { return .zero }
        let metadataRect = layer.metadataOutputRectConverted(fromLayerRect: rect)
        return metadataRect
    }
    
    func setUpFrames() {
        previewLayer.frame = cameraView.bounds
        maskView.frame = cameraView.bounds
        maskView.cutoutRect = cutoutFrame
        layoutScanLine()
    }
}
// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerManager: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        
        guard
            !didScanCode,
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            object.type == .qr,
            let value = object.stringValue
        else { return }
        
        didScanCode = true
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        stopCaptureSession()
        scanLine.layer.removeAllAnimations()
        onResult.onNext(value)
    }
}
// MARK: - Reactive
extension Reactive where Base: ScannerManager {
    
    var result: Observable<String> { base.onResult }
    
    var permissionDenied: Observable<Void> { base.onPermissionDenied }
    
    var deviceNotSupported: Observable<Void> { base.onDeviceNotSupported }
}
