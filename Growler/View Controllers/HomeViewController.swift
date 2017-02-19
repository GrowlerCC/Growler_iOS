//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {

    // todo show CollectionListViewController when tapping on banners

    private var menuController: PopupMenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        menuController = PopupMenuViewController()

        let menuButtonImage = UIImage(named: "MenuButton")?.withRenderingMode(.alwaysOriginal)
        let menuButton = UIBarButtonItem(image: menuButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapMenuButton))
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = menuButton

        let searchButtonImage = UIImage(named: "SearchButton")?.withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapSearchButton))

        let checkoutButtonImage = UIImage(named: "CheckoutButton")?.withRenderingMode(.alwaysOriginal)
        let checkoutButton = UIBarButtonItem(image: checkoutButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapCheckoutButton))

        navigationController?.topViewController?.navigationItem.rightBarButtonItems = [checkoutButton, searchButton]
    }

    func didTapMenuButton() {
        present(menuController, animated: true)
    }

    func didTapCheckoutButton() {
    }

    func didTapSearchButton() {
    }

}
