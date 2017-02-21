//
// Created by Alexander Gorbovets on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var toolbarItems: [UIBarButtonItem]!

    override init() {
        super.init()

        let cartItemCount = UIBarButtonItem(title: "0", style: .plain, target: nil, action: nil)
        cartItemCount.tintColor = UIColor.black
        let cartButton = UIBarButtonItem(title: "View Cart", style: .plain, target: self, action: #selector(self.viewCart))
        let cartTotalAmount = UIBarButtonItem(title: "$0", style: .plain, target: nil, action: nil)
        cartTotalAmount.tintColor = UIColor.black

        toolbarItems = [
            cartItemCount,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartTotalAmount,
        ]
    }

    var navigationController: UINavigationController!

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.navigationController = navigationController
        switch viewController {
            case is CartViewController:
                 break // doing nothing. this check is needed because CartViewController is descendant of ProductListViewController
            case
                is HomeViewController,
                is CollectionListViewController,
                is ProductListViewController,
                is ProductViewController:
                    viewController.setToolbarItems(toolbarItems, animated: false)
            default:
                break
        }
    }

    func viewCart() {
        let controller = CartViewController(client: ShopifyController.instance.client, collection: nil)!
        navigationController!.pushViewController(controller, animated: true)
    }
    
    // @Notification(.didChangeCart)
    func didChangeCart() {
        
    }

}
