//
// Created by Alexander Gorbovets on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var toolbarItems: [UIBarButtonItem]!

    private var profileButton: UIBarButtonItem!

    private var searchButton: UIBarButtonItem!

    override init() {
        super.init()

        let cartItemCount = UIBarButtonItem(title: "0", style: .plain, target: nil, action: nil)
        let cartButton = UIBarButtonItem(title: "View Cart", style: .plain, target: self, action: #selector(self.viewCart))
        let cartTotalAmount = UIBarButtonItem(title: "$0", style: .plain, target: nil, action: nil)

        toolbarItems = [
            cartItemCount,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartTotalAmount,
        ]

        let profileButtonImage = UIImage(named: "ProfileButton")?.withRenderingMode(.alwaysOriginal)
        profileButton = UIBarButtonItem(image: profileButtonImage, style: .plain, target: self, action: #selector(self.didTapProfileButton))

        let searchButtonImage = UIImage(named: "SearchButton")?.withRenderingMode(.alwaysOriginal)
        searchButton = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.didTapSearchButton))
    }

    var navigationController: UINavigationController!

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.navigationController = navigationController
        if !(viewController is CartViewController) {
            viewController.setToolbarItems(toolbarItems, animated: false)
        }

        if !(viewController is AccountProfileViewController) {
            viewController.navigationItem.leftBarButtonItem = profileButton
        }

        // todo search button should be visible on all screens?
        viewController.navigationItem.rightBarButtonItem = searchButton
    }

    func viewCart() {
        let controller = CartViewController(client: ShopifyController.instance.client, collection: nil)!
        navigationController!.pushViewController(controller, animated: true)
    }
    
    // @Notification(.didChangeCart)
    func didChangeCart() {
    }
    
    func didTapProfileButton() {
        let controller = AccountProfileViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

    func didTapSearchButton() {
        let controller = CollectionListViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

}
