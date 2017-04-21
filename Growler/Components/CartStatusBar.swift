//
// Created by Jeff H. on 2017-03-17.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CartStatusBar: Notifiable {

    private(set) var cartItemCount: UIButton!

    private(set) var cartTotalAmount: UIBarButtonItem!

    private(set) var cartItemCountWrapper: UIBarButtonItem!

    init() {
        cartItemCount = UIButton()
        cartItemCount.setTitle("0", for: .normal)
        cartItemCount.backgroundColor = Colors.statusButtonColor
        cartItemCount.setTitleColor(Colors.menuAndToolbarDarkBackground, for: .normal)
        cartItemCount.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        cartItemCount.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        cartItemCount.layer.cornerRadius = 3
        cartItemCountWrapper = UIBarButtonItem(customView: cartItemCount)

        cartTotalAmount = UIBarButtonItem(title: "$0", style: .plain, target: nil, action: nil)
        cartTotalAmount.tintColor = Colors.statusButtonColor

        subscribeTo(Notification.Name.cartChanged, selector: #selector(self.cartChanged))

        reloadCartStatus()
    }

    @objc func cartChanged() {
        reloadCartStatus()
    }

    func reloadCartStatus() {
        ShopifyController.instance.getCartProducts().then {
            products -> Void in
            self.cartItemCount.setTitle(String(products.count), for: .normal)
            let totalAmount = products.reduce(NSDecimalNumber(integerLiteral: 0)) {
                total, product in total.adding(product.minimumPrice)
            }
            self.cartTotalAmount.title = "US" + Utils.formatUSD(value: totalAmount)
        }
    }

}
