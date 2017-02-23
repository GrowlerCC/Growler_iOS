import Foundation
import UIKit
import RESideMenu

@UIApplicationMain
@objc
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public var sideMenuViewController: RESideMenu!

    private var drawerMenuController: MenuViewController!

    private(set) var navigationController: UINavigationController!

    private var navigationControllerDelegate: NavigationControllerDelegate!

    static var shared: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController

        navigationController.toolbar.barTintColor = UIColor(0xfc8127)
        navigationController.toolbar.tintColor = UIColor.white

        drawerMenuController = MenuViewController.loadFromStoryboard()
        let homeViewController = navigationController.viewControllers.first as? HomeViewController
        drawerMenuController.homeController = homeViewController

        navigationControllerDelegate = NavigationControllerDelegate()
        navigationController.delegate = navigationControllerDelegate

        sideMenuViewController = RESideMenu(
            contentViewController: navigationController,
            leftMenuViewController: drawerMenuController,
            rightMenuViewController: nil
        )

        window?.rootViewController = sideMenuViewController
        return false
    }

    func application(_ application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject!) -> Bool {
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: "CheckoutCallbackNotification"), object: nil, userInfo: ["url": url]
        )
        return true
    }

    func application(_ application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> ()) -> Bool {
        window?.rootViewController?.childViewControllers.first?.restoreUserActivityState(userActivity)
        return true
    }

}
