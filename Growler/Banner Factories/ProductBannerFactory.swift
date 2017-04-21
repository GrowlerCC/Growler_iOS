//
// Created by Jeff H. on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class ProductBannerFactory: NSObject, AbstractBannerFactory {

    private let products: [BUYProduct]

    init(products: [BUYProduct]) {
        self.products = products
    }

    func getBannerCount() -> Int {
        return products.count
    }

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView {
        let view = Utils.loadViewFromNib(nibName: "ProductBannerView", owner: self) as! ProductBannerView
        let product = products[index]
        view.product = product
        view.titleLabel.text = product.title
        view.descriptionLabel.text = product.stringDescription
        view.costLabel.text = Utils.formatUSD(value: product.minimumPrice)
        if let image = product.images.firstObject as? BUYImageLink {
            view.image.loadImage(with: image.sourceURL, completion: nil)
        }
        return view
    }


}
