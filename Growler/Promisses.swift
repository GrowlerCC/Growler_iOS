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

func getProductsByIds(_ ids: Set<Int64>) -> Promise<[BUYProduct]> {
    return getProductsByIds(Array<Int64>(ids))
}

// important: it's recommended to always use this function instead of BUYClient.getProductsByIds
// because BUYClient.getProductsByIds has bug - if id list is empty, it returns all products
func getProductsByIds(_ ids: [Int64]) -> Promise<[BUYProduct]> {
    return Promise {
        fulfill, reject in
        if ids.isEmpty {
            fulfill([])
        }
        let nsnumbers = ids.map { $0 as NSNumber }
        ShopifyController.instance.client.getProductsByIds(nsnumbers) {
            products, error in
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
func getProducts(fromCollectionWithId collectionId: Int64, page: UInt) -> Promise<[BUYProduct]> {
    let id = NSNumber(value: collectionId)
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getProductsPage(page, inCollection: id) {
            products, page, reachedEnd, error in
            if let error = error {
                reject(error)
            }
            fulfill(products ?? [])
        }
    }
}

// todo fetch all instead of one page?
func getTags(page: UInt) -> Promise<[String]> {
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getProductTagsPage(1) {
            products, page, reachedEnd, error in
            if let error = error {
                reject(error)
            }
            fulfill(products ?? [])
        }
    }
}

func getOrders() -> Promise<[BUYOrder]> {
    return Promise {
        fulfill, reject in
        ShopifyController.instance.client.getOrdersForCustomerCallback() {
            orders, error in
            if let error = error {
                reject(error)
            }
            fulfill(orders ?? [])
        }
    }
}
