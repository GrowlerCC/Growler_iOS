//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class PriceRange {

    var startPrice: Int?

    var endPrice: Int?

    var title: String

    init(startPrice: Int?, endPrice: Int?, title: String) {
        self.startPrice = startPrice
        self.endPrice = endPrice
        self.title = title
    }

}
