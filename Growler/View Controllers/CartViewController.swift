//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class CartViewController: ProductListViewController, Notifiable {

    private var footer: UIView!

    private var checkoutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        checkoutButton = UIBarButtonItem(title: "Checkout", style: .plain, target: self, action: #selector(self.checkout))
        subscribeTo(Notification.Name.cartChanged, selector: #selector(self.cartChanged))
    }

    deinit {
        unsubscribeFromNotifications()
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

    override func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") {
            action, indexPath in
            let product = self.products[indexPath.row] as! BUYProduct
            ShopifyController.instance.cartProductIds.remove(product.identifierValue)
        }
        return [deleteAction]
    }

    func checkout() {
        ShopifyController.instance.checkout(navigationController: navigationController!)
    }

    func cartChanged() {
        loadProducts()
    }

}
