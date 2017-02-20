//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CartViewController: ProductListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        self.products = ShopifyController.instance.getCart()
        tableView.reloadData()
    }

    func checkout() {
        ShopifyController.instance.checkout(navigationController: navigationController!)
    }

}
