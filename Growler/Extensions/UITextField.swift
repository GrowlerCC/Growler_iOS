//
// Created by Jeff H. on 2017-03-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {

    func setTextIfEmpty(_ value: String?) {
        if text == nil || text!.isEmpty {
            text = value
        }
    }

}
