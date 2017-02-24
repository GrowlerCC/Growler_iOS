//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FavoriteListViewController: ProductListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        subscribeTo(notification: Notification.Name.favoritesChanged, selector: #selector(self.favoritesChanged))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        _ = getProductsPage(page: 1).then {
            products -> Void in
            let favoriteIds = FavoritesController.getFavoriteIds()
            self.products = products.filter{ favoriteIds.contains($0.identifierValue) }
            mq { self.tableView.reloadData() }
        }
    }

    func favoritesChanged() {
        loadProducts()
    }

}
