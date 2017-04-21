//
// Created by Jeff H. on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import EMString

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate, Notifiable {

    var toolbarItems: [UIBarButtonItem]!

    private var profileButton: UIBarButtonItem!

    private var searchButton: UIBarButtonItem!

    private var cartStatusBar: CartStatusBar!

    var titleViews: [UIButton] = []

    private var cartNavigationButton: UIBarButtonItem!

    override init() {
        super.init()

        cartStatusBar = CartStatusBar()
        let cartButton = UIButton()
        cartButton.setTitle("View Cart", for: .normal)
        cartButton.addTarget(self, action: #selector(self.viewCart), for: .touchUpInside)
        cartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cartButton.sizeToFit()
        let cartButtonWrapper = UIBarButtonItem(customView: cartButton)
        cartNavigationButton = UIBarButtonItem(image: UIImage(named: "CartIcon"), style: .plain, target: self, action: #selector(self.viewCart))

        let boldText = EMStylingClass(markup: "<growler_bold_text>")!
        let buttonFontSize = UIButton().titleLabel?.font.pointSize ?? UIFont.systemFontSize
        boldText.attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: buttonFontSize)]
        EMStringStylingConfiguration.sharedInstance().addNewStylingClass(boldText)

        toolbarItems = [
            cartStatusBar.cartItemCountWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            cartButtonWrapper,
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
        let address = ShopifyController.instance.getAddress()?.address1 ?? ""
        let title = "<growler_bold_text>Delivery</growler_bold_text> to <growler_bold_text>\(address)</growler_bold_text> ▾".attributedString
        for titleView in titleViews {
            titleView.setAttributedTitle(title, for: .normal)
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

        switch viewController {
            case
                is CartViewController,
                is AddressFormController,
                is ShippingRatesTableViewController,
                is PreCheckoutViewController,
                is CheckoutViewController,
                is ProductPageViewController,
                is ProductViewController,
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

        switch viewController {
            case is ProductPageViewController:
                viewController.navigationItem.rightBarButtonItem = cartNavigationButton
            default:
                viewController.navigationItem.rightBarButtonItem = searchButton
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        setTitleView(forViewController: viewController)
    }

    func viewCart() {
        CartViewController().popupWithNavigationController()
    }
    
    func didTapProfileButton() {
        navigationController.slideMenuController()?.openLeft()
    }

    func didTapSearchButton() {
        let controller = SearchViewController.loadFromStoryboard()
        navigationController!.present(controller, animated: true)
    }

}
