//
// Created by Alexander Gorbovets on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate, Notifiable {

    var toolbarItems: [UIBarButtonItem]!

    private var profileButton: UIBarButtonItem!

    private var searchButton: UIBarButtonItem!

    private var slidingMenuGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    private var cartItemCount: UIBarButtonItem!
    
    private var cartTotalAmount: UIBarButtonItem!

    override init() {
        super.init()

        slidingMenuGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.didPanScreenEdge))
        slidingMenuGestureRecognizer.edges = .left

        cartItemCount = UIBarButtonItem(title: "0", style: .plain, target: nil, action: nil)
        let cartButton = UIBarButtonItem(title: "View Cart", style: .plain, target: self, action: #selector(self.viewCart))
        cartTotalAmount = UIBarButtonItem(title: "$0", style: .plain, target: nil, action: nil)

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

        reloadCartStatus()

        subscribeTo(Notification.Name.cartChanged, selector: #selector(self.cartChanged))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    var navigationController: UINavigationController!

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.navigationController = navigationController

        viewController.view.addGestureRecognizer(slidingMenuGestureRecognizer)

        if !(viewController is CartViewController) {
            viewController.setToolbarItems(toolbarItems, animated: false)
        }

        switch viewController {
            case is AccountProfileViewController:
                // we already on account page, there's no point to show account page button
                // mayb we should hide back button as follows?
                // viewController.navigationItem.hidesBackButton = true
                break
            case is ProductViewController:
                // it's inconvenient to return to list using menu after viewing each product. so for product we keep back button
                break
            default:
                viewController.navigationItem.leftBarButtonItem = profileButton
        }

        // todo search button should be visible on all screens?
        viewController.navigationItem.rightBarButtonItem = searchButton
    }

    func viewCart() {
        let controller = CartViewController(client: ShopifyController.instance.client, collection: nil)!
        navigationController!.pushViewController(controller, animated: true)
    }
    
    func cartChanged() {
        reloadCartStatus()
    }

    func reloadCartStatus() {
        let ids = ShopifyController.instance.cartProductIds.getAll()
        _ = getProductsByIds(ids).then {
            products -> Void in
            self.cartItemCount.title = String(products.count)
            let totalAmount = products.reduce(NSDecimalNumber(integerLiteral: 0)) {
                total, product in total.adding(product.minimumPrice)
            }
            self.cartTotalAmount.title = Utils.formatUSD(value: totalAmount)
        }
    }
    
    func didTapProfileButton() {
        let controller = AccountProfileViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

    func didTapSearchButton() {
        let controller = CollectionListViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

    @IBAction func didPanScreenEdge(_ sender: Any) {
        AppDelegate.shared.sideMenuViewController.presentLeftMenuViewController()
    }

}
