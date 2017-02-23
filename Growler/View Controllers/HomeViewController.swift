//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy;

class HomeViewController: UIViewController, SwiftCarouselDelegate {

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!

    private var products: [BUYProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // visibleItemsPerPage is the only resize type in which SwiftCarousel doesn't crash when empty
        // so setting resize type here
        // also resizeType should always be set before setting items
        topCarousel.resizeType = .visibleItemsPerPage(1)
        bottomCarousel.resizeType = .visibleItemsPerPage(2)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ShopifyController.instance.client.getProductsPage(1) {
            products, page, reachedEnd, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let products = products, error == nil {
                self.products = products
                if !products.isEmpty {
                    self.setupCarousel(self.topCarousel)
                    self.setupCarousel(self.bottomCarousel)
                }
            } else {
                print("Error fetching products: \(error)")
            }
        }
    }

    func didTapMenuButton() {
        AppDelegate.shared.sideMenuViewController.presentLeftMenuViewController()
    }

    private func setupCarousel(_ carousel: SwiftCarousel) {
        carousel.selectByTapEnabled = true
        let count = min(10, products.count) // limited by 10 items to not exhaust memory
        try! carousel.itemsFactory(itemsCount: count) {
            index in
            let view = Utils.loadViewFromNib(nibName: "ProductBannerView", owner: self) as! ProductBannerView
            let product = products[index]
            view.product = product
            view.navigationController = navigationController
            view.titleLabel.text = product.title
            view.descriptionLabel.text = product.stringDescription
            view.costLabel.text = Utils.formatUSD(value: product.minimumPrice)
            view.deliveryTimeLabel.text = ""
            view.deliveryCostLabel.text = ""
            if let image = product.images.firstObject as? BUYImageLink {
                view.image.loadImage(with: image.sourceURL, completion: nil)
            }
            return view
        }
        carousel.layoutSubviews() // this will update scrollview content size
        carousel.delegate = self
    }

}
