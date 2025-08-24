import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var appCoordinator: AppCoordinator?
    var window: UIWindow?
    private var blurView: UIVisualEffectView?
    private var alertView: AlertView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        prepareKeys()
        configureAppStartService()
        configureURLEnvironment()
        
        if #available(iOS 13.0, *) {
            // For iOS 13 and later, the SceneDelegate handles window setup.
        } else {
            // For iOS 12 and earlier, the AppDelegate must set up the window.
            let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window
            appCoordinator = AppCoordinator.start(window: window)
        }
        
        preventScreenRecording()
        detectScreenShot()
        subscribeAppLifeCycle()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
// MARK: - LifeCycle
extension AppDelegate {
    
    func subscribeAppLifeCycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func detectScreenShot() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userTookScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }
    
    @objc private func handleWillResignActive() {
        showBlurOverlay()
    }
    
    @objc private func handleDidBecomeActive() {
        if !UIScreen.main.isCaptured {
            removeBlurOverlay()
        }
    }
    
    @objc private func userTookScreenshot() {
        showBlurOverlay()
        showAlertView(
            title: "Screenshot Detected",
            message: "Please do not take screenshot for security reason.",
            positiveTitle: "OK"
        )
    }
}
// MARK: - Config
extension AppDelegate {
    func configureAppStartService() {
        RealmManager.configure()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func configureURLEnvironment() {
        Network.shared.configure(environment: .uat)
    }
    
    func prepareKeys() {
        guard let version = Int(KeychainData.securityKeyVersion ?? "0"),
              version < SecurityKey.version else {
            return
        }
        
        KeychainData.baseUrl = SecurityKey.baseUrl
        KeychainData.clientId = SecurityKey.clientId
        KeychainData.clientSecret = SecurityKey.clientSecret
        KeychainData.publicKey = SecurityKey.publicKey
        KeychainData.securityKeyVersion = String(SecurityKey.version)
    }
    
    func preventScreenRecording() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenCaptureChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        
        // Check immediately at launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            self?.handleScreenCaptureChange()
        })
    }
}

// MARK: - Screen Recording / Screen Blocker
extension AppDelegate {
    
    @objc private func handleScreenCaptureChange() {
        if UIScreen.main.isCaptured {
            showBlurOverlay()
            showAlertView(
                title: "Screen Recording Detected",
                message: "Screen recording is blocked for security reasons."
            )
        } else {
            removeBlurOverlay()
        }
    }
    
    private func showBlurOverlay() {
        guard let window = UIApplication.keyWindow, blurView == nil else { return }
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blur = UIVisualEffectView(effect: blurEffect)
        blur.frame = window.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        blurView = blur
        window.addSubview(blur)
    }
    
    private func showAlertView(
        title: String = "",
        message: String = "",
        positiveTitle: String? = nil
    ) {
        guard let window = UIApplication.keyWindow, alertView == nil else { return }
        
        let alert = AlertView(
            title: title,
            message: message,
            positiveTitle: positiveTitle,
            positiveAction: { [weak self] in
                self?.removeBlurOverlay()
            }
        )
        alertView = alert
        
        window.addSubview(alert)
        alert.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alert.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            alert.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 20),
            alert.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
        ])
    }
    
    private func removeAlertView() {
        alertView?.removeFromSuperview()
        alertView = nil
    }
    
    private func removeBlurOverlay() {
        blurView?.removeFromSuperview()
        blurView = nil
        removeAlertView()
    }
}
