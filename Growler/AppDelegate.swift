import Foundation
import UIKit
import RESideMenu

@UIApplicationMain
@objc
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public var sideMenuViewController: RESideMenu!

    public var homeViewController: HomeViewController! // recreating it every time is expensive, so we store it here

    private var drawerMenuController: MenuViewController!

    private(set) var navigationController: UINavigationController!

    private var navigationControllerDelegate: NavigationControllerDelegate!

    static var shared: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // increase shopify page sizes to not need to load multiple pages
        ShopifyController.instance.client.productPageSize = 250
        ShopifyController.instance.client.collectionPageSize = 250
        ShopifyController.instance.client.productTagPageSize = 250

        UINavigationBar.appearance().tintColor = UIColor.black

        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController

        navigationController.toolbar.barTintColor = UIColor(0xfc8127)
        navigationController.toolbar.tintColor = UIColor.white

        drawerMenuController = MenuViewController.loadFromStoryboard()
        homeViewController = navigationController.viewControllers.first as? HomeViewController
        
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
