//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FavoriteListViewController: ProductListViewController, Notifiable {

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeTo(Notification.Name.favoritesChanged, selector: #selector(self.favoritesChanged))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        let favoriteIds = ShopifyController.instance.favoriteProductIds.getAll()
        _ = getProductsByIds(favoriteIds).then {
            products -> Void in
            self.products = products
            mq { self.tableView.reloadData() }
        }
    }

    func favoritesChanged() {
        loadProducts()
    }

}
