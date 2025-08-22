import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var appCoordinator: AppCoordinator?
    var window: UIWindow?
    
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
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
}
