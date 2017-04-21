//
// Created by Jeff H. on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate, Notifiable {

    var toolbarItems: [UIBarButtonItem]!

    private var profileButton: UIBarButtonItem!

    private var searchButton: UIBarButtonItem!

    private var slidingMenuGestureRecognizer: UIScreenEdgePanGestureRecognizer!

    private var cartStatusBar: CartStatusBar!

    var titleViews: [UIButton] = []

    override init() {
        super.init()

        slidingMenuGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.didPanScreenEdge))
        slidingMenuGestureRecognizer.edges = .left

        cartStatusBar = CartStatusBar()
        let cartButton = UIBarButtonItem(title: "View Cart", style: .plain, target: self, action: #selector(self.viewCart))

        toolbarItems = [
            cartStatusBar.cartItemCountWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartStatusBar.cartTotalAmount,
        ]

        updateAddress()

        let profileButtonImage = UIImage(named: "ProfileButton")?.withRenderingMode(.alwaysOriginal)
        profileButton = UIBarButtonItem(image: profileButtonImage, style: .plain, target: self, action: #selector(self.didTapProfileButton))

        let searchButtonImage = UIImage(named: "SearchButton")?.withRenderingMode(.alwaysOriginal)
        searchButton = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.didTapSearchButton))

        subscribeTo(Notification.Name.accountChanged, selector: #selector(self.updateAddress))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    var navigationController: UINavigationController!

    func updateAddress() {
        let address = ShopifyController.instance.getAddress()?.address1
        let title = (address ?? "") + " ▾"
        for titleView in titleViews {
            titleView.setTitle(title, for: .normal)
        }
    }

    func changeAddress() {
        AddressFormController().popupWithNavigationController()
    }

    func setTitleView(forViewController viewController: UIViewController) {
        switch viewController {
            case
                is AddressFormController,
                is CreditCardFormController,
                is ShippingRatesTableViewController,
                is PreCheckoutViewController,
                is CheckoutViewController:
                return
            default: break
        }
        if !(viewController.navigationItem.titleView is UIButton) {
            let titleView = UIButton()
            titleView.setTitleColor(UIColor.black, for: .normal)
            titleView.addTarget(self, action: #selector(self.changeAddress), for: .touchUpInside)
            viewController.navigationItem.titleView = titleView
            titleViews.append(titleView)
            updateAddress() // setting title for this new view
        }
        // trick to re-add title view
        let titleView = viewController.navigationItem.titleView
        viewController.navigationItem.titleView = nil
        viewController.navigationItem.titleView = titleView
        viewController.navigationItem.titleView?.isHidden = false
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.navigationController = navigationController

        viewController.view.addGestureRecognizer(slidingMenuGestureRecognizer)

        switch viewController {
            case
                is CartViewController,
                is AddressFormController,
                is ShippingRatesTableViewController,
                is PreCheckoutViewController,
                is CheckoutViewController,
                is CreditCardFormController:
                    break // these forms are used in checkout process so we don't need checkout toolbar for them
            default:
                viewController.setToolbarItems(toolbarItems, animated: false)
        }

        switch viewController {
            case
                is FavoriteListViewController,
                is RecommendationListViewController:
                    viewController.navigationItem.leftBarButtonItem = profileButton
            case
                is AddressFormController,
                is CreditCardFormController,
                is ProductListViewController,
                is ShippingRatesTableViewController,
                is PreCheckoutViewController,
                is CheckoutViewController,
                is ProductViewController:
                // it's inconvenient to return to list using menu after viewing each product or editing address/card. so for these controllers we keep back button
                break
            default:
                viewController.navigationItem.leftBarButtonItem = profileButton
        }

        setTitleView(forViewController: viewController)

        // todo search button should be visible on all screens?
        viewController.navigationItem.rightBarButtonItem = searchButton
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        setTitleView(forViewController: viewController)
    }

    func viewCart() {
        CartViewController().popupWithNavigationController()
    }
    
    func didTapProfileButton() {
//        let controller = AccountProfileViewController()
//        navigationController!.pushViewController(controller, animated: true)
        AppDelegate.shared.sideMenuViewController.presentLeftMenuViewController()
    }

    func didTapSearchButton() {
        let controller = SearchViewController.loadFromStoryboard()
        navigationController!.present(controller, animated: true)
    }

    @IBAction func didPanScreenEdge(_ sender: Any) {
        AppDelegate.shared.sideMenuViewController.presentLeftMenuViewController()
    }

}
