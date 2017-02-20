//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CartViewController: ProductListViewController {

    private var footer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController.right
        title = "Cart"
        createBottomBar()
    }

    override func loadProducts() {
        // important: don't call super! we don't want to show all products, but only ones in the cart
        self.products = ShopifyController.instance.getCart()
        tableView.reloadData()
    }

    func checkout() {
        ShopifyController.instance.checkout(navigationController: navigationController!)
    }

    func createBottomBar() {
        let customButton = UIButton(type: .system)
        customButton.setTitle("Checkout", for: .normal)
        customButton.sizeToFit()
        customButton.addTarget(self, action: #selector(CartViewController.checkout), for: .touchUpInside)
        let customBarButtonItem = UIBarButtonItem(customView: customButton)


        let items = [
            customBarButtonItem,
            //UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CartViewController.checkout))
        ]
        setToolbarItems(items, animated: true)
        /*
        footer = UIView()
        footer.backgroundColor = UIColor.blue
        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.footer)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[_footer]|", options: [], metrics: nil,
            views: ["_footer": footer]
        ))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[_footer(100)]-|", options: [], metrics: nil,
            views: ["_footer": footer]
        ))
        */
    }

}
