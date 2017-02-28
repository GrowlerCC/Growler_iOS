//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy
import CoreGraphics
import PromiseKit

// todo rename to HomePageCellIndex
enum CarouserIndex: Int {
    case mostPopular
    case freshBrews
    case featuredCollectionsHeader
    case ciceronesChoice
    case staffsPick
    case gameDay
    case separator
    case shopByCollections
    case shopByStyle
    case shopByPrice
}

class HomeViewController: UITableViewController {

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!

    private var items: [UITableViewCell] = [
        ActivityIndicatorTableCell.loadFromNib(),
        ActivityIndicatorTableCell.loadFromNib(),
        HomeHeaderCell.create(title: "Featured Collections"),
        CollectionBannerCell.create(collectionId: CollectionIdentifier.ciceronesChoiceBoozyGueuze),
        CollectionBannerCell.create(collectionId: CollectionIdentifier.staffPicks),
        CollectionBannerCell.create(collectionId: CollectionIdentifier.gameDay),
        HomeSeparatorCell.loadFromNib(),
        ActivityIndicatorTableCell.loadFromNib(),
        ActivityIndicatorTableCell.loadFromNib(),
        CarouselTableCell.create(title: "Shop By Price", itemsPerPage: 3, bannerFactory: PriceBannerFactory()),
    ]

    private var contentHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        createCarouselCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentHeight = Utils.calculateContentHeight(navigationController: navigationController!)
    }

    func createCarouselCells() {
        _ = getProducts(fromCollectionWithId: CollectionIdentifier.mostPopular.rawValue, page: 1)
            .then {
                (products: [BUYProduct]) -> Void in
                self.items[CarouserIndex.mostPopular.rawValue] = CarouselTableCell.create(
                    title: "Most Popular",
                    itemsPerPage: 2,
                    bannerFactory: ProductBannerFactory(products: products)
                )
                mq { self.tableView.reloadData() }
            }

        _ = getProducts(fromCollectionWithId: CollectionIdentifier.freshBrews.rawValue, page: 1)
            .then {
                (products: [BUYProduct]) -> Void in
                let recommendedProducts = ShopifyController.selectRecommendedProducts(from: products)
                self.items[CarouserIndex.freshBrews.rawValue] = CarouselTableCell.create(
                    title: "Fresh Brews",
                    itemsPerPage: 2,
                    bannerFactory: ProductBannerFactory(products: recommendedProducts)
                )
                mq { self.tableView.reloadData() }
            }


        _ = getCollectionsPage(page: 1)
            .then {
                (collections: [BUYCollection]) -> Void in
                self.items[CarouserIndex.shopByCollections.rawValue] = CarouselTableCell.create(
                    title: "Shop By Collections",
                    itemsPerPage: 3,
                    bannerFactory: CollectionBannerFactory(collections: collections)
                )
                mq { self.tableView.reloadData() }
            }

        _ = getTags(page: 1)
            .then {
                (tags: [String]) -> Void in
                self.items[CarouserIndex.shopByStyle.rawValue] = CarouselTableCell.create(
                    title: "Shop By Style",
                    itemsPerPage: 3,
                    bannerFactory: TagBannerFactory(tags: tags)
                )
                mq { self.tableView.reloadData() }
            }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return items[indexPath.item]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // first 2 carousels take 1/2 of screen height, others - 1/3
        switch indexPath.row {
            case 0 ..< CarouserIndex.featuredCollectionsHeader.rawValue: return contentHeight / 2
            case CarouserIndex.featuredCollectionsHeader.rawValue: return 45
            case CarouserIndex.separator.rawValue: return 9
            default: return contentHeight / 3
        }
    }

}
