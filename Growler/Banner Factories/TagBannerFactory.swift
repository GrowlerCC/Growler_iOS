//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class TagBannerFactory: AbstractBannerFactory {

    let tags: [String]

    init(tags: [String]) {
        self.tags = tags
    }

    func getBannerCount() -> Int {
        return tags.count
    }

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView {
        let tag = tags[index]
        return TagBanner.create(tag: tag)
    }

}
