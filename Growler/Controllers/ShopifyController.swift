//
// Created by Jeff H. on 2017-02-20.
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

    public var favoriteProductIds: PersistentIdContainer!

    public var cartProductIds: PersistentIdContainer!

    public var addressJsonString = PersistentString(defaultsKey: "ADDRESS_JSON_STRING", changeNotification: Notification.Name.accountChanged)

    public var email = PersistentString(defaultsKey: "EMAIL", changeNotification: Notification.Name.accountChanged)

    public var creditCardJsonString = PersistentString(defaultsKey: "CREDIT_CARD_JSON_STRING", changeNotification: Notification.Name.creditCardChanged)

    public var promoCodeJsonString = PersistentString(defaultsKey: "PROMO_CODE_JSON_STRING", changeNotification: Notification.Name.promoCodeChanged)

    public var customer: BUYCustomer?

    override init() {
        client = BUYClient(shopDomain:SHOP_DOMAIN, apiKey: API_KEY, appId: APP_ID)

        favoriteProductIds = PersistentIdContainer(
            defaultsKey: "FAVORITE_PRODUCT_IDENTIFIERS",
            unique: true,
            changeNotification: Notification.Name.favoritesChanged
        )

        cartProductIds = PersistentIdContainer(
            defaultsKey: "CART_PRODUCT_IDENTIFIERS",
            unique: false,
            changeNotification: Notification.Name.cartChanged
        )
    }

    private var checkoutCreationOperation: Operation?

    func getCart() -> Promise<[BUYProduct]> {
        return Promise {
            fulfill, error in
            let ids = cartProductIds.getAll()
            getProductsByIds(ids).then {
                products -> Void in
                var productMap = [Int64: BUYProduct]()
                for product in products {
                    productMap[product.identifierValue] = product
                }
                var cartProducts = [BUYProduct]()
                for id in ids {
                    if let product = productMap[id] {
                        cartProducts.append(product)
                    }
                }
                fulfill(cartProducts)
            }
        }
    }

    func isEmptyCart() -> Bool {
        return cartProductIds.getAll().count == 0
    }

    func addProductToCart(product: BUYProduct) {
        cartProductIds.add(product.identifierValue)
    }

    deinit {
        checkoutCreationOperation?.cancel()
    }

    func createCheckout(products: [BUYProduct]) -> Promise<BUYCheckout> {
        if let operation = checkoutCreationOperation, operation.isExecuting {
            operation.cancel()
        }

        return Promise {
            fulfill, reject in

            // todo make cart singleton. and add each product only when button is pressed or when app is launched (from NSUserDefaults)
            guard let cart = client.modelManager.insertCart(withJSONDictionary: nil) else {
                reject(NSError(domain: "com.shopify.CreateCart", code: 0, userInfo: ["error": "Failed to create cart"]))
                return
            }

            for product in products {
                cart.add(product.variants.firstObject as! BUYProductVariant)
            }

            let checkout = BUYCheckout(modelManager: cart.modelManager!, cart: cart)
            checkout.shippingAddress = getAddress()
            checkout.billingAddress = getAddress()
            checkout.email = getEmail()
            let promoCode = getPromoCode()
            checkout.discount = promoCode.isEmpty ? nil : client.modelManager.discount(withCode: promoCode)

            checkoutCreationOperation = self.client.createCheckout(checkout) {
                checkout, error in
                if let checkout = checkout, error == nil {
                    fulfill(checkout)
                } else {
                    if let error = error {
                        reject(error)
                    } else {
                        reject(NSError(domain: "com.shopify.CreateCart", code: 0, userInfo: ["error": "Failed to create checkout"]))
                    }
                }
            }
        }
    }

    func getAddress() -> BUYAddress? {
        guard let address = client.modelManager.insertAddress(withJSONDictionary: nil) else {
            return nil
        }
        let json = JSON(data: addressJsonString.value.data(using: .utf8)!)
        address.loadFrom(json: json)
        return address
    }

    func getEmail() -> String {
        let json = JSON(data: addressJsonString.value.data(using: .utf8)!)
        return json[AddressFields.email.rawValue].string ?? ""
    }

    func getPromoCode() -> String {
        let json = JSON(data: promoCodeJsonString.value.data(using: .utf8)!)
        return json[PromoCodeFields.promoCode.rawValue].string ?? ""
    }

    func getCreditCard() -> BUYCreditCard {
        let result = BUYCreditCard()
        let json = JSON(data: creditCardJsonString.value.data(using: .utf8)!)
        result.loadFrom(json: json)
        return result
    }

    class func selectRecommendedProducts(from products: [BUYProduct]) -> [BUYProduct] {
        if products.count == 0 {
            return products
        }
        let lastIndex = max(0, products.count - 1)
        let firstIndex = max(0, lastIndex - 5)
        return Array<BUYProduct>(products[firstIndex...lastIndex])
    }

}
