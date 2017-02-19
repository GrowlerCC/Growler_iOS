//
// Created by Alexander Gorbovets on 2017-01-11.
// Copyright (c) 2017 com.ibisworld. All rights reserved.
//

import Foundation
import UIKit

typealias MenuCallback = ((UINavigationController?) -> Void)

class MenuItem: UITableViewCell {

    private var title: String!

    public var didSelect: MenuCallback?

    convenience init(title: String, didSelect: MenuCallback? = nil) {
        self.init(style: .default, reuseIdentifier: "")
        self.textLabel?.text = title
        self.didSelect = didSelect
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // ignoring and not calling parent because we don't highlight menu items. only select
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

//        stripe.backgroundColor = selected ? UIColor.red : nil
//        titleLabel?.textColor = selected ? Constants.selectedMenuItemTextColor : Constants.menuTextColor
//        backgroundColor = selected ? Constants.selectedMenuItemBackgroundColor : Constants.menuBackgroundColor
    }

}
