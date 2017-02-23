//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

@objc
class Utils: NSObject {

    // todo move to UIView extension
    static func loadViewFromNib(nibName: String, owner: AnyObject) -> UIView {
        let views = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)
        return views![0] as! UIView
    }

    static func formatUSD(value: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter();
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter.string(from: value) ?? ""
    }

    static func alert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        mq {
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    class func calculateContentHeight(navigationController: UINavigationController) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = navigationController.navigationBar.frame.height
        let toolbarHeight = navigationController.toolbar.frame.height
        return screenHeight - statusBarHeight - navigationBarHeight - toolbarHeight
    }

}


/**
 * Stands for main queue. Asynchronously executes passed callback on main queue if calling code is not from main queue. Otherwise just calls block
 */
func mq(callback: @escaping () -> Void) {
    if Thread.isMainThread {
        callback()
    } else {
        DispatchQueue.main.async(execute: callback)
    }
}
