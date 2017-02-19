//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

extension UIViewController {

    class func loadFromStoryboard<T: UIViewController>(name: String, type: T.Type) -> T {
        return UIStoryboard(name: name, bundle: nil)
            .instantiateViewController(withIdentifier: name) as! T
    }

}
