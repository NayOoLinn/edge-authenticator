import PhotosUI
import Vision
import UIKit
import PhotosUI
import Vision
import UIKit
import AVFoundation
import RxSwift

final class PhotoLibraryManager: NSObject {
    
    private let presenter: UIViewController
    
    fileprivate let onResult = PublishSubject<String>()
    fileprivate let onError = PublishSubject<String>()
    
    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init()
    }
    
    func pickPhoto() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            presenter.present(picker, animated: true)
        } else {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            presenter.present(picker, animated: true)
        }
    }
    
    private func detectQRCode(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let results = request.results as? [VNBarcodeObservation],
               let payload = results.first?.payloadStringValue {
                
                DispatchQueue.main.async {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self?.onResult.onNext(payload)
                }
            } else {
                DispatchQueue.main.async {
                    self?.onError.onNext("No QR code found in this image.")
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self?.onError.onNext(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - PHPicker Delegate (iOS 14+)
@available(iOS 14, *)
extension PhotoLibraryManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        presenter.dismiss(animated: true, completion: nil)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let self = self, let uiImage = image as? UIImage else { return }
            self.detectQRCode(in: uiImage)
        }
    }
}

// MARK: - UIImagePicker Delegate (iOS < 14)
extension PhotoLibraryManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        presenter.dismiss(animated: true, completion: nil)
        
        if let uiImage = info[.originalImage] as? UIImage {
            detectQRCode(in: uiImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presenter.dismiss(animated: true, completion: nil)
    }
}
// MARK: - Reactive
extension Reactive where Base: PhotoLibraryManager {
    
    var result: Observable<String> { base.onResult }
    
    var error: Observable<String> { base.onError }
}
