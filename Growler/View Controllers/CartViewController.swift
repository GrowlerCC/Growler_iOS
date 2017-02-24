//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class CartViewController: ProductListViewController {

    private var footer: UIView!

    private var checkoutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        checkoutButton = UIBarButtonItem(title: "Checkout", style: .plain, target: self, action: #selector(self.checkout))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToolbarItems([checkoutButton], animated: true)
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        ShopifyController.instance.getCart().then {
            products -> Void in
            self.products = products
            mq { self.tableView.reloadData() }
        }
    }

    func checkout() {
        ShopifyController.instance.checkout(navigationController: navigationController!)
    }

}
