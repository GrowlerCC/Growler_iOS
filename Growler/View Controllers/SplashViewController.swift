//
// Created by Jeff H. on 2017-03-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class SplashViewController: UIViewController {
    
    @IBAction func didTapGetStartedButton(_ sender: Any) {
        AppDelegate.shared.window?.rootViewController = AppDelegate.shared.slideMenuController
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        AppDelegate.shared.window?.rootViewController = AppDelegate.shared.slideMenuController
        LoginFormController().popupWithNavigationController()
    }
    
}
