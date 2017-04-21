import Foundation
import UIKit
import EMString
import SlideMenuControllerSwift

@UIApplicationMain
@objc
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public var homeViewController: HomeViewController! // recreating it every time is expensive, so we store it here

    // todo rename to menuViewController
    private var drawerMenuController: MenuViewController!

    private(set) var navigationController: UINavigationController!

    private var navigationControllerDelegate: NavigationControllerDelegate!

    private(set) var slideMenuController: SlideMenuController!
    
    static var shared: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // increase shopify page sizes to not need to load multiple pages
        ShopifyController.instance.client.productPageSize = 250
        ShopifyController.instance.client.collectionPageSize = 250
        ShopifyController.instance.client.productTagPageSize = 250
        ShopifyController.instance.loadSerializedCart()
        ShopifyController.instance.autoLogin()

        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().isTranslucent = false
        
        navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController

        navigationController.toolbar.barTintColor = Colors.menuAndToolbarDarkBackground
        navigationController.toolbar.tintColor = UIColor.white

        drawerMenuController = MenuViewController.loadFromStoryboard()
        homeViewController = navigationController.viewControllers.first as? HomeViewController
        
        navigationControllerDelegate = NavigationControllerDelegate()
        navigationController.delegate = navigationControllerDelegate

        SlideMenuOptions.contentViewDrag = true
        SlideMenuOptions.opacityViewBackgroundColor = UIColor.white
        SlideMenuOptions.pointOfNoReturnWidth = 100

        slideMenuController = SlideMenuController(
            mainViewController: navigationController,
            leftMenuViewController: drawerMenuController
        )
        slideMenuController.delegate = drawerMenuController
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()

        if !ShopifyController.instance.isLoggedIn() {
            let splash = SplashViewController.loadFromStoryboard()
            self.window?.rootViewController = splash
        }

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

    func replaceController(_ viewController: UIViewController) {
        navigationController.delegate?.navigationController?(navigationController, willShow: viewController, animated: false)
        navigationController.viewControllers = [viewController]
        navigationController.delegate?.navigationController?(navigationController, didShow: viewController, animated: false)
    }

    lazy var faqViewController: TextViewController = {
        let controller = TextViewController.loadFromStoryboard()

        let questionStyle = EMStylingClass(markup: "<growler_question>")!
        questionStyle.color = Colors.launchScreenOrangeColor
        questionStyle.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
        EMStringStylingConfiguration.sharedInstance().addNewStylingClass(questionStyle)

        let answerStyle = EMStylingClass(markup: "<growler_answer>")!
        // important: due to bug in EMString pod app will crash if some EMStylingClass object will have all attributes equal to nil
        answerStyle.color = UIColor.black
        EMStringStylingConfiguration.sharedInstance().addNewStylingClass(answerStyle)

        let content = FAQ
            .map {
                (question: String, answer: String) -> String in
                let line: String = "<growler_question>\(question)</growler_question>\n<growler_answer>\(answer)</growler_answer>\n\n\n"
                return line
            }
            .joined()
            .attributedString

        controller.navigationItem.title = "FAQs"
        controller.onViewDidLoad = {
            controller.contentLabel.attributedText = content
        }

        return controller
    }()

    lazy var termsViewController: TextViewController = {
        let controller = TextViewController.loadFromStoryboard()

        let titleStyle = EMStylingClass(markup: "<growler_terms_title>")!
        titleStyle.color = UIColor.black
        titleStyle.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold)
        EMStringStylingConfiguration.sharedInstance().addNewStylingClass(titleStyle)

        let textStyle = EMStylingClass(markup: "<growler_terms_text>")!
        textStyle.color = UIColor.black
        textStyle.font = UIFont.systemFont(ofSize: 14)
        EMStringStylingConfiguration.sharedInstance().addNewStylingClass(textStyle)

        let content = TERMS_AND_CONDITIONS.attributedString

        controller.navigationItem.title = "TERMS OF SERVICE"
        controller.onViewDidLoad = {
            controller.contentLabel.attributedText = content
            controller.contentLabel.textColor = UIColor.black
        }

        return controller
    }()

}
