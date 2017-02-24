//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionBannerFactory: AbstractBannerFactory {

    let collections: [BUYCollection]

    init(collections: [BUYCollection]) {
        self.collections = collections
    }

    func getBannerCount() -> Int {
        return collections.count
    }

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView {
        let collection = collections[index]
        return CollectionBanner.create(collection: collection)
    }

}
