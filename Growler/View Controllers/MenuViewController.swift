//
// Created by Jeff H. on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift

let signInItem = MenuItem.create(
    title: "Sing In",
    height: 65,
    image: UIImage(named: "LoginLogoutIcon")
)
{

    let loggedIn = ShopifyController.instance.isLoggedIn()
    if loggedIn {
        ShopifyController.instance.logout()
    } else {
        LoginFormController().popupWithNavigationController()
    }
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SlideMenuControllerDelegate {

    // todo store link to navigation controller here or retrieve it from app.
    // todo store all view controllers which can be reused instead of recreating them. they can be stores in menu object or in AppDelegate/AppController

    @IBOutlet weak var tableView: UITableView!

    let MY_ORDERS_MENU_ITEM_INDEX = 2
    
    var menuItems: [MenuItem] = [
        // menu items with darker color
        MenuItem.create(
            title: "Home",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "HomeIcon")
        ) {
            AppDelegate.shared.replaceController(AppDelegate.shared.homeViewController)
        },
        MenuItem.create(
            title: "Profile",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "AccountProfileIcon")
        ) {
            AddressFormController().popupWithNavigationController()
        },
        MenuItem.create(
            title: "Payment Details",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "MyOrdersIcon")
        ) {
            CreditCardFormController().popupWithNavigationController()
        },
        MenuItem.create(
            title: "Past orders",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "ic_history_white")
        ) {
            AppDelegate.shared.navigationController.viewControllers = [MyOrdersViewController()]
        },
        MenuItem.create(
            title: "Recommendations",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "RecommendationsIcon")
        ) {
            let controller = RecommendationListViewController()
            AppDelegate.shared.replaceController(controller)
        },
        MenuItem.create(
            title: "Favorites",
            color: Colors.lightGrayMenuBackground,
            image: UIImage(named: "FavoritesIcon")
        ) {
            let controller = FavoriteListViewController()
            AppDelegate.shared.replaceController(controller)
        },


        // menu items with lighter color

        MenuItem.create(height: 15), // spacer
        // MenuItem.create(title: "App settings", image: UIImage(named: "SettingsIcon")),
        MenuItem.create(title: "FAQs", height: 34, image: UIImage(named: "FaqsIcon")) {
            AppDelegate.shared.faqViewController.popupWithNavigationController()
        },
        MenuItem.create(title: "About", height: 34, image: UIImage(named: "AboutIcon")) {
            AppDelegate.shared.replaceController(AboutViewController.loadFromStoryboard())
        },
        signInItem,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedItem = menuItems[indexPath.row]
        self.slideMenuController()?.closeLeft()
        selectedItem.didSelect?()
        return indexPath
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menuItems[indexPath.row]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = menuItems[indexPath.row]
        return CGFloat(item.height)
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        self.slideMenuController()?.closeLeft()
    }

    @IBAction func didTapLogo(_ sender: Any) {
        let homeController = AppDelegate.shared.homeViewController
        AppDelegate.shared.navigationController.viewControllers = [homeController!]
        self.slideMenuController()?.closeLeft()
    }

    func leftWillOpen() {
        let loggedIn = ShopifyController.instance.isLoggedIn()
        signInItem.titleLabel.text = loggedIn ? "Sign Out" : "Sign In";
    }

}
