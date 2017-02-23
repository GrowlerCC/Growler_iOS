//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionBannerCell: UITableViewCell {

    class func create(collectionId: CollectionIdentifier) -> CollectionBannerCell {
        let cell = CollectionBannerCell()

        ShopifyController.instance.client.getCollectionsByIds([String(collectionId.rawValue)], page: 1) {
            collections, page in
            guard let collection = collections?.first else {
                return
            }
            let imageUrl = collection.image?.sourceURL.absoluteURL
            let title = collection.title
            let description = collection.stringDescription
            print("\(title)\n \(description) \(imageUrl)\n")
        }

        return cell
    }

}
