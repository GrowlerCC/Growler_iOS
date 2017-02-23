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
        return 0
    }

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView {
        return UIView()
    }

}
