//
// Created by Jeff H. on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import RESideMenu

let signInItem = MenuItem.create(title: "Sing In", image: UIImage(named: "AboutIcon")) {

    let loggedIn = ShopifyController.instance.customer != nil
    if loggedIn {
        ShopifyController.instance.client.logoutCustomerCallback({ _,_ in  })
        ShopifyController.instance.customer = nil
        ShopifyController.instance.cartProductIds.removeAll()
    } else {
        LoginFormController().popupWithNavigationController()
    }
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate {

    // todo store link to navigation controller here or retrieve it from app.
    // todo store all view controllers which can be reused instead of recreating them. they can be store in menu object or in AppDelegate/AppController

    @IBOutlet weak var tableView: UITableView!
    
    var menuItems: [MenuItem] = [
        // menu items with darker color
        MenuItem.create(title: "Home", color: Colors.lightGrayMenuBackground, image: UIImage(named: "AccountProfileIcon")) {
            AppDelegate.shared.replaceController(AppDelegate.shared.homeViewController)
        },
        MenuItem.create(title: "Profile", color: Colors.lightGrayMenuBackground, image: UIImage(named: "AccountProfileIcon")) {
            AddressFormController().popupWithNavigationController()
        },
        //MenuItem.create(title: "My orders", color: Colors.lightGrayMenuBackground, image: UIImage(named: "MyOrdersIcon")) {
        //    AppDelegate.shared.navigationController.viewControllers = [MyOrdersViewController()]
        //},
        MenuItem.create(title: "Recommendations", color: Colors.lightGrayMenuBackground, image: UIImage(named: "RecommendationsIcon")) {
            let controller = RecommendationListViewController(client: ShopifyController.instance.client, collection: nil)!
            AppDelegate.shared.replaceController(controller)
        },
        MenuItem.create(title: "Favorites", color: Colors.lightGrayMenuBackground, image: UIImage(named: "FavoritesIcon")) {
            let controller = FavoriteListViewController(client: ShopifyController.instance.client, collection: nil)!
            AppDelegate.shared.replaceController(controller)
        },

        // menu items with lighter color
//        MenuItem.create(title: "App settings", image: UIImage(named: "SettingsIcon")),
        MenuItem.create(title: "FAQs", image: UIImage(named: "FaqsIcon")) {
            AppDelegate.shared.replaceController(FaqViewController.loadFromStoryboard())
        },
        MenuItem.create(title: "About", image: UIImage(named: "AboutIcon")) {
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
        AppDelegate.shared.sideMenuViewController!.hideViewController()
        selectedItem.didSelect?()
        return indexPath
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menuItems[indexPath.row]
    }

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        AppDelegate.shared.sideMenuViewController!.hideViewController()
    }

    @IBAction func didTapLogo(_ sender: Any) {
        let homeController = AppDelegate.shared.homeViewController
        AppDelegate.shared.navigationController.viewControllers = [homeController!]
        AppDelegate.shared.sideMenuViewController!.hideViewController()
    }

    func sideMenu(_ sideMenu: RESideMenu, willShowMenuViewController menuViewController: UIViewController) {
        let loggedIn = ShopifyController.instance.customer != nil
        signInItem.titleLabel.text = loggedIn ? "Sign Out" : "Sign In";
    }

}
