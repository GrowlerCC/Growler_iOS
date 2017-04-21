//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class RecommendationListViewController: ProductListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        ShopifyController.getRecommendedProducts().then {
            products -> Void in
            self.products = products
            mq { self.tableView.reloadData() }
        }
    }

}
