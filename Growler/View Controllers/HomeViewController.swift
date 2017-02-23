//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy
import CoreGraphics
import PromiseKit

enum CarouserIndex: Int {
    case main
    case recommendedForYou
    case featuredCollections
    case ciceronesChoice
    case staffsPick
    case shopByCollections
    case shopByStyle
    case shopByPrice
}

class HomeViewController: UITableViewController {

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!

    private var items: [UITableViewCell] = (0...7).map{ _ in ActivityIndicatorTableCell.loadFromNib() }

    private var contentHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        createCarouselCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentHeight = Utils.calculateContentHeight(navigationController: navigationController!)
    }

    func createCarouselCells() {
        var products: [BUYProduct] = []
        var collections: [BUYCollection] = []

        getProductsPage(page: 1)
            .then {
                (list: [BUYProduct]) -> Promise<[BUYCollection]> in
                products = list
                return getCollectionsPage(page: 1)
            }
            .then {
                (list: [BUYCollection]) -> Promise<Bool> in
                collections = list
                return Promise<Bool>(value: true)
            }
            .always {
                _ in
                self.items[CarouserIndex.main.rawValue] = CarouselTableCell.create(title: "", itemsPerPage: 1, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.recommendedForYou.rawValue] = CarouselTableCell.create(title: "Recommended for You", itemsPerPage: 1.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.featuredCollections.rawValue] = CarouselTableCell.create(title: "Featured Collections", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.ciceronesChoice.rawValue] = CarouselTableCell.create(title: "Cicerone’s Choice", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.staffsPick.rawValue] = CarouselTableCell.create(title: "Staff’s Pick", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.shopByCollections.rawValue] = CarouselTableCell.create(title: "Shop By Collections", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.shopByStyle.rawValue] = CarouselTableCell.create(title: "Shop By Style", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                self.items[CarouserIndex.shopByPrice.rawValue] = CarouselTableCell.create(title: "Shop By Price", itemsPerPage: 2.5, bannerFactory: ProductBannerFactory(products: products))

                mq {
                    self.tableView.reloadData()
                }
            }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return items[indexPath.item]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row < 2 ? contentHeight / 2 : contentHeight / 3 // first 2 carousels take 1/2 of screen height, others - 1/3
    }

}
