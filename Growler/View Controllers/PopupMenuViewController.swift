//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class PopupMenuViewController: UITableViewController {

    weak var homeController: HomeViewController?

    var menuItems: [MenuItem] = [
        MenuItem(title: "Account Profile") {
            navigationController in
            let controller = AccountProfileViewController()
            navigationController!.pushViewController(controller, animated: true)
        },
        MenuItem(title: "My Orders"),
        MenuItem(title: "Recommendations"),
        MenuItem(title: "App Settings"),
        MenuItem(title: "FAQs"),
        MenuItem(title: "About GrEx"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0) // make room for status bar
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedItem = menuItems[indexPath.row]
        dismiss(animated: false) {
            selectedItem.didSelect?(self.homeController!.navigationController)
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menuItems[indexPath.row]
    }

}
