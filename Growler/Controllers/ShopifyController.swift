//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy

@objc
class ShopifyController: NSObject {

    static var instance: ShopifyController = {
        ShopifyController()
    }()

    let client: BUYClient

    override init() {
        client = BUYClient(shopDomain:SHOP_DOMAIN, apiKey: API_KEY, appId: APP_ID)
    }

    private var checkoutCreationOperation: Operation?

    deinit {
        checkoutCreationOperation?.cancel()
    }

    func checkout(_ product: BUYProduct?, navigationController: UINavigationController) {
        if let operation = checkoutCreationOperation, operation.isExecuting {
            operation.cancel()
        }

        guard let cart = client.modelManager.insertCart(withJSONDictionary: nil) else {
            print("Failed to create card")
            return
        }

        if let product = product {
            cart.add(product.variants.firstObject as! BUYProductVariant)
        }

        let checkout = BUYCheckout(modelManager: cart.modelManager!, cart: cart)
        checkout.shippingAddress = address()
        checkout.billingAddress = address()
        checkout.email = "banana@testasaurus.com";

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        checkoutCreationOperation = self.client.createCheckout(checkout) {
            checkout, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let checkout = checkout, error == nil {
                let shippingController = ShippingRatesTableViewController(client: self.client, checkout: checkout)
                navigationController.pushViewController(shippingController!, animated: true)
            } else {
                print("Error creating checkout: \(error)")
            }
        }
    }

    func address() -> BUYAddress? {
        guard let address = client.modelManager.insertAddress(withJSONDictionary: nil) else {
            return nil
        }
        address.address1 = "150 Elgin Street"
        address.address2 = "8th Floor"
        address.city = "Ottawa"
        address.company = "Shopify Inc."
        address.firstName = "Egon"
        address.lastName = "Spengler"
        address.phone = "1-555-555-5555"
        address.countryCode = "CA"
        address.provinceCode = "ON"
        address.zip = "K1N5T5"
        return address
    }

}
