//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

@objc
class Utils: NSObject {

    // todo move to UIView extension
    static func loadViewFromNib(nibName: String, owner: AnyObject?) -> UIView {
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

    static func inputBox(title: String, message: String, okTitle: String, callback: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)

        alert.addTextField { _ in }

        alert.addAction(UIAlertAction(title: okTitle, style: .default) {
            action in
            let textField = alert.textFields![0]
            callback(textField.text)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .default) {
            action in callback(nil)
        })

        mq {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    static func formatErrorInfo(_ info: [AnyHashable: Any], message: String) -> String {
        var errors = [String]()
        guard let errorList = info["errors"] as? [AnyHashable: Any] else {
            return message
        }
        for (rawAction, rawActionErrors) in errorList {
            let action = Utils.humanReadable(rawAction as? String).capitalized
            guard let actionErrors = rawActionErrors as? NSDictionary else {
                continue
            }
            for (rawForm, rawFormErrors) in actionErrors {
                let form = Utils.humanReadable(rawForm as? String).capitalized
                guard let formErrors = rawFormErrors as? NSDictionary else {
                    continue
                }
                for (rawField, rawFieldErrors) in formErrors {
                    let field = Utils.humanReadable(rawField as? String).capitalized
                    guard let fieldErrors = rawFieldErrors as? NSArray else {
                        continue
                    }
                    for rawError in fieldErrors {
                        guard let error = rawError as? NSDictionary else {
                            continue
                        }
                        if let message = error["message"] as? String {
                            errors.append(
                                //"\(action) - "+
                                "\(form) - \(field): \(message)"
                            )
                        }
                    }
                }
            }
        }
        return message + ". \n" + errors.joined(separator: ".\n")
    }
    
    static func humanReadable(_ text: String?) -> String {
        return (text ?? "").replacingOccurrences(of: "_", with: " ")
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
