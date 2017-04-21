//
// Created by Jeff H. on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class PriceBannerFactory: AbstractBannerFactory {

    let priceRanges: [PriceRange] = [
        PriceRange(startPrice: nil, endPrice: 10, title: "$10"),
        PriceRange(startPrice: 10, endPrice: 20, title: "$10-$20"),
        PriceRange(startPrice: nil, endPrice: 30, title: "$30"),
    ]

    func getBannerCount() -> Int {
        return priceRanges.count
    }

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView {
        let priceRange = priceRanges[index]
        return PriceBanner.create(priceRange: priceRange)
    }

}
