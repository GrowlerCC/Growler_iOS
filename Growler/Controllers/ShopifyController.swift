//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy
import PromiseKit
import SwiftyJSON

@objc
class ShopifyController: NSObject {

    static var instance: ShopifyController = {
        ShopifyController()
    }()

    let client: BUYClient

    public var favoriteProductIds: PersistentIdSet!

    public var cartProductIds: PersistentIdSet!

    public var addressJsonString = PersistentString(defaultsKey: "ADDRESS_JSON_STRING", changeNotification: Notification.Name.accountChanged)

    public var email = PersistentString(defaultsKey: "EMAIL", changeNotification: Notification.Name.accountChanged)

    public var creditCardJsonString = PersistentString(defaultsKey: "CREDIT_CARD_JSON_STRING", changeNotification: Notification.Name.accountChanged)

    override init() {
        client = BUYClient(shopDomain:SHOP_DOMAIN, apiKey: API_KEY, appId: APP_ID)

        favoriteProductIds = PersistentIdSet(defaultsKey: "FAVORITE_PRODUCT_IDENTIFIERS", changeNotification: Notification.Name.favoritesChanged)
        cartProductIds = PersistentIdSet(defaultsKey: "CART_PRODUCT_IDENTIFIERS", changeNotification: Notification.Name.cartChanged)
    }

    private var checkoutCreationOperation: Operation?

    func getCart() -> Promise<[BUYProduct]> {
        return getProductsByIds(cartProductIds.getAll())
    }

    func addProductToCart(product: BUYProduct) {
        cartProductIds.add(product.identifierValue)
    }

    deinit {
        checkoutCreationOperation?.cancel()
    }

    func checkout(navigationController: UINavigationController) {
        _ = getCart().then {
            products -> Void in self.checkoutInternal(products: products, navigationController: navigationController)
        }
    }
    
    func checkoutInternal(products: [BUYProduct], navigationController: UINavigationController) {
        if let operation = checkoutCreationOperation, operation.isExecuting {
            operation.cancel()
        }

        guard let cart = client.modelManager.insertCart(withJSONDictionary: nil) else {
            print("Failed to create card")
            return
        }

        for product in products {
            cart.add(product.variants.firstObject as! BUYProductVariant)
        }

        let checkout = BUYCheckout(modelManager: cart.modelManager!, cart: cart)
        checkout.shippingAddress = getAddress()
        checkout.billingAddress = getAddress()
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

    func getAddress() -> BUYAddress? {
        guard let address = client.modelManager.insertAddress(withJSONDictionary: nil) else {
            return nil
        }
        let json = JSON(data: addressJsonString.value.data(using: .utf8)!)
        address.loadFrom(json: json)
        /*
        address.address1 = "Address 1"
        address.address2 = "address 2"
        address.city = "Test city"
        address.company = "Test company"
        address.firstName = "First name"
        address.lastName = "Last Name"
        address.phone = "123456789"
        address.countryCode = "US"
        address.provinceCode = "CA"
        address.zip = "94118"
        */
        return address
    }

    func getCreditCard() -> BUYCreditCard {
        let result = BUYCreditCard()
        let json = JSON(data: creditCardJsonString.value.data(using: .utf8)!)
        result.loadFrom(json: json)
        /*
        creditCard.number = "4242424242424242"
        creditCard.expiryMonth = "12"
        creditCard.expiryYear = "2020"
        creditCard.cvv = "123"
        creditCard.nameOnCard = "John Smith"
        */
        return result
    }

    class func selectRecommendedProducts(from products: [BUYProduct]) -> [BUYProduct] {
        let belgiumAleId: Int64 = 8633520269
        let filtered = products.filter {
            $0.identifierValue != belgiumAleId // belgium ale - it has portrait image which displays bad in carousel
        }
        let lastIndex = filtered.count - 1
        let firstIndex = max(0, lastIndex - 5)
        return Array<BUYProduct>(filtered[firstIndex...lastIndex])
    }

}
