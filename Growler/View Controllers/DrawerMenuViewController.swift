//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class DrawerMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var homeController: HomeViewController?

    @IBOutlet weak var tableView: UITableView!
    
    var menuItems: [MenuItem] = [
        MenuItem.create(title: "Profile", image: UIImage(named: "AccountProfileIcon")) {
            navigationController in
            let controller = AccountProfileViewController()
            navigationController!.pushViewController(controller, animated: true)
        },
        MenuItem.create(title: "My orders", image: UIImage(named: "MyOrdersIcon")),
        MenuItem.create(title: "Recommendations", image: UIImage(named: "RecommendationsIcon")),
        MenuItem.create(title: "Favorites", image: UIImage(named: "Favorites")),
        MenuItem.create(title: "", image: nil), // separator
//        MenuItem.create(title: "App settings", image: UIImage(named: "SettingsIcon")),
        MenuItem.create(title: "FAQs", image: UIImage(named: "FaqsIcon")),
        MenuItem.create(title: "About", image: UIImage(named: "AboutIcon")),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0) // make room for status bar
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedItem = menuItems[indexPath.row]
        AppDelegate.shared.sideMenuViewController!.hideViewController()
        selectedItem.didSelect?(self.homeController!.navigationController)
        return indexPath
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menuItems[indexPath.row]
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        AppDelegate.shared.sideMenuViewController!.hideViewController()
    }

}
