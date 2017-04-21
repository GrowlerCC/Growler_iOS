//
// Created by Jeff H. on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

extension UIViewController {

    class func loadFromStoryboard() -> Self {
        return self.loadFromStoryboardInternal()
    }

    private static func loadFromStoryboardInternal<T: UIViewController>() -> T {
        let mirror = Mirror(reflecting: T.self)
        let name = String(describing: mirror.subjectType).replacingOccurrences(of: "\\.Type$", with: "", options: .regularExpression)
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }

    func popupWithNavigationController(parentController: UIViewController? = nil) {
        if navigationController == nil {
            _ = UINavigationController(rootViewController: self) // this will set self.naviationController
        }
        let parent = parentController ?? AppDelegate.shared.window!.rootViewController
        parent?.present(navigationController!, animated: true)
    }

    func setupDarkToolbars() {
        if let navController = navigationController {
            navController.navigationBar.backgroundColor = Colors.menuAndToolbarDarkBackground
            navController.navigationBar.barTintColor = Colors.menuAndToolbarDarkBackground
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navController.isToolbarHidden = false
            navController.toolbar.barTintColor = Colors.menuAndToolbarDarkBackground
            navController.toolbar.tintColor = UIColor.white
        }
    }

}
