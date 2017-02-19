//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class Utils {

    static func loadViewFromNib(nibName: String, owner: AnyObject) -> UIView {
        let views = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)
        return views![0] as! UIView
    }

}
