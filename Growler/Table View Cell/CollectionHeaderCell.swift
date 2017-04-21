//
// Created by Jeff H. on 2017-03-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionHeaderCell: UITableViewCell {

    weak var productList: ProductListViewController?

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        if let nav = productList?.navigationController {
            nav.popViewController(animated: true)
        } else {
            productList?.navController?.popViewController(animated: true)
        }
    }
    
}
