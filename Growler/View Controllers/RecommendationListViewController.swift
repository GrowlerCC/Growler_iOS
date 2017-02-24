//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class RecommendationListViewController: ProductListViewController {

    private var footer: UIView!

    private var checkoutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recommendations"
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        _ = getProductsPage(page: 1).then {
            (products) -> Void in
            self.products = ShopifyController.selectRecommendedProducts(from: products)
            mq { self.tableView.reloadData() }
        }
    }

    func checkout() {
        ShopifyController.instance.checkout(navigationController: navigationController!)
    }

}
