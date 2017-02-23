//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import PromiseKit

// todo fetch all instead of one page?
func getProductsPage(page: UInt) -> Promise<[BUYProduct]> {
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getProductsPage(page) {
            products, page, reachedEnd, error in
            if let error = error {
                reject(error)
            }
            fulfill(products ?? [])
        }
    }
}

// todo fetch all instead of one page?
func getCollectionsPage(page: UInt) -> Promise<[BUYCollection]> {
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getCollectionsPage(page) {
            collections, page, reachedEnd, error in
            if let error = error {
                reject(error)
            }
            fulfill(collections ?? [])
        }
    }
}

// todo fetch all instead of one page?
func getProducts(fromCollectionWithId collectionId: NSNumber, page: UInt) -> Promise<[BUYProduct]> {
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getProductsPage(page, inCollection: collectionId) {
            products, page, reachedEnd, error in
            if let error = error {
                reject(error)
            }
            fulfill(products ?? [])
        }
    }
}
