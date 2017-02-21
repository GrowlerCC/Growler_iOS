//
// Created by Alexander Gorbovets on 2017-01-11.
// Copyright (c) 2017 com.ibisworld. All rights reserved.
//

import Foundation
import UIKit

typealias MenuCallback = ((UINavigationController?) -> Void)

class MenuItem: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    public var didSelect: MenuCallback?

    static func create(title: String, image: UIImage?, didSelect: MenuCallback? = nil) -> MenuItem {
        let items = Bundle.main.loadNibNamed("MenuItem", owner: nil, options: nil)
        let cell = items?.first as! MenuItem
        cell.titleLabel?.text = title
        cell.icon.image = image
        cell.didSelect = didSelect
        return cell
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // ignoring and not calling parent because we don't highlight menu items. only select
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
