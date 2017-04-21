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

    let client: BUYClient!

    public var favoriteProductIds: PersistentIdContainer!

    public var cartProductIds: PersistentIdContainer!

    public var addressJsonString = PersistentString(defaultsKey: "ADDRESS_JSON_STRING", changeNotification: Notification.Name.accountChanged)

    public var creditCardJsonString = PersistentString(defaultsKey: "CREDIT_CARD_JSON_STRING", changeNotification: Notification.Name.creditCardChanged)

    public var promoCodeJsonString = PersistentString(defaultsKey: "PROMO_CODE_JSON_STRING", changeNotification: Notification.Name.promoCodeChanged)

    public var loginEmailString = PersistentString(defaultsKey: "LOGIN_EMAIL_STRING", changeNotification: Notification.Name.promoCodeChanged)

    public var loginPasswordString = PersistentString(defaultsKey: "LOGIN_PASSWORD_STRING", changeNotification: Notification.Name.promoCodeChanged)

    public var customer: BUYCustomer?

    private(set) var cart: BUYCart?

    private(set) var checkout: BUYCheckout?

    func loadSerializedCart() {
        cart = self.client.modelManager.insertCart(withJSONDictionary: nil)
        if let cart = self.cart {
            self.getCartProducts().then {
                products -> Void in
                for product in products {
                    cart.add(product.variants.firstObject as! BUYProductVariant)
                }
                mq {
                    Notification.Name.cartChanged.send()
                }
            }
        }
    }

    override init() {
        client = BUYClient(shopDomain:SHOP_DOMAIN, apiKey: API_KEY, appId: APP_ID)
        
        super.init()
        
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

    func getCartProducts() -> Promise<[BUYProduct]> {
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
                // this is to add some products more than once
                // because getProductsByIds returns each requested product only once
                // no matter that you pass some ids more than once
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

    func addProductToCart(_ product: BUYProduct) -> Bool {
        if cart == nil {
            cart = client.modelManager.insertCart(withJSONDictionary: nil)
        }
        guard let cart = cart else {
            // if still can't create cart, then stop
            return false
        }
        cart.add(product.variants.firstObject as! BUYProductVariant)
        cartProductIds.add(product.identifierValue)
        return true
    }

    deinit {
        checkoutCreationOperation?.cancel()
    }

    func getCheckout() -> Promise<BUYCheckout> {
        if let operation = checkoutCreationOperation, operation.isExecuting {
            operation.cancel()
        }

        return Promise {
            fulfill, reject in
            guard let cart = self.cart else {
                reject(NSError(domain: "com.shopify.CreateCart", code: 0, userInfo: ["error": "Failed to send cart to server"]))
                return
            }
            if checkout == nil {
                checkout = BUYCheckout(modelManager: cart.modelManager!, cart: cart)
            }
            guard let checkout = checkout else {
                reject(NSError(domain: "com.shopify.CreateCheckout", code: 0, userInfo: ["error": "Failed create checkout"]))
                return
            }
            checkout.shippingAddress = getAddress()
            checkout.billingAddress = getAddress()
            checkout.email = getEmail()
            let promoCode = getPromoCode()
            checkout.discount = promoCode.isEmpty ? nil : client.modelManager.discount(withCode: promoCode)
            
            
            if checkout.token == nil { // if token is nil, then it wasn't created on Server yet 
                checkoutCreationOperation = self.client.createCheckout(checkout) {
                    checkout, error in
                    if let checkout = checkout, error == nil {
                        self.checkout = checkout // this checkout now have token
                        fulfill(checkout)
                    } else {
                        if let error = error {
                            reject(error)
                        } else {
                            reject(NSError(domain: "com.shopify.CreateCart", code: 0, userInfo: ["error": "Failed to create checkout"]))
                        }
                    }
                }
            } else {
                fulfill(checkout)
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

    class func getRecommendedProducts() -> Promise<[BUYProduct]> {
        if ShopifyController.instance.isLoggedIn() {
            return getOrders().then {
                orders in
                let productIds = orders.reduce([Int64]()) {
                    (accumulator: [Int64], order: BUYOrder) -> [Int64] in
                    var newIds: [Int64] = []
                    for item in order.lineItems {
                        let item = item as! BUYLineItem
                        newIds.append(item.productIdValue)
                    }
                    return accumulator + newIds
                }
                return getProductsByIds(productIds)
            }
        } else {
            return Promise<[BUYProduct]> {
                fulfill, reject in
                getProductsPage(page: 1).then {
                    products -> Void in
                    let lastIndex = max(0, products.count - 1)
                    let firstIndex = max(0, lastIndex - 5)
                    fulfill(Array<BUYProduct>(products[firstIndex ... lastIndex]))
                }
            }
        }
    }

    func logout() {
        client.logoutCustomerCallback({ _,_ in  })
        customer = nil
        createNewCart()
        loginEmailString.value = ""
        loginPasswordString.value = ""
    }

    func isLoggedIn() -> Bool {
        return customer != nil
    }

    func autoLogin() {
        let email = ShopifyController.instance.loginEmailString.value
        let password = ShopifyController.instance.loginPasswordString.value
        guard !email.isEmpty && !password.isEmpty else {
            return
        }
        let items: [BUYAccountCredentialItem] = [
            BUYAccountCredentialItem(email: email),
            BUYAccountCredentialItem(password: password),
        ]
        let credentials = BUYAccountCredentials(items: items)
        ShopifyController.instance.client.loginCustomer(with: credentials) {
            (customer, token, error) -> Void in
            if error == nil {
                ShopifyController.instance.customer = customer
            }
        }
    }

    func createNewCart() {
        checkout = nil
        ShopifyController.instance.cartProductIds.removeAll()
        cart?.clear()
        cart = client.modelManager.insertCart(withJSONDictionary: nil) // create new cart because old might be assigned to another user
    }

    func removeProduct(_ product: BUYProduct) {
        guard let cart = cart else {
            return
        }
        cart.remove(product.variantsArray().first!)
        /*
        if token is nil, then checkout is not registered on server.
        there's no need to reset it to release it's products.
        moreover, updating checkout with nil token will cause assertion error
        */
        if let checkout = checkout, checkout.token != nil  {
            checkout.reservationTime = 0 // releasing all checkout items
            client.update(checkout, completion: { _, _ in })
        }
        checkout = nil // this will force creating new checkout
        ShopifyController.instance.cartProductIds.removeAll(equalTo: product.identifierValue)
    }

}
