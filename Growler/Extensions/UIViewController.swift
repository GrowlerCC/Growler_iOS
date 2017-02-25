//
// Created by Alexander Gorbovets on 2017-02-19.
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

}
