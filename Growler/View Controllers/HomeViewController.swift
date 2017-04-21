//
// Created by Jeff H. on 2017-02-19.
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
                    description: "Most popular beers, as chosen by you.",
                    itemsPerPage: 1.7,
                    itemMargin: 10,
                    bannerFactory: ProductBannerFactory(products: products)
                )
                mq { self.tableView.reloadData() }
            }

        _ = getProducts(fromCollectionWithId: CollectionIdentifier.freshBrews.rawValue, page: 1)
            .then {
                (products: [BUYProduct]) -> Void in
                self.items[CarouserIndex.freshBrews.rawValue] = CarouselTableCell.create(
                    title: "Fresh Brews",
                    description: "Brewed in the past week.",
                    itemsPerPage: 1.7,
                    itemMargin: 10,
                    bannerFactory: ProductBannerFactory(products: products)
                )
                mq { self.tableView.reloadData() }
            }

        _ = getCollectionsPage(page: 1)
            .then {
                (collections: [BUYCollection]) -> Void in
                self.items[CarouserIndex.shopByCollections.rawValue] = CarouselTableCell.create(
                    title: "Shop By Collections",
                    itemsPerPage: 2.5,
                    bannerFactory: CollectionBannerFactory(collections: collections)
                )
                mq { self.tableView.reloadData() }
            }

        _ = getTags(page: 1)
            .then {
                (tags: [String]) -> Void in
                self.items[CarouserIndex.shopByStyle.rawValue] = CarouselTableCell.create(
                    title: "Shop By Style",
                    itemsPerPage: 2.5,
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
        let screenWidth = UIScreen.main.bounds.width
        // proportion constants are taken from mock-ups
        switch CarouserIndex(rawValue: indexPath.row)! {
            case .mostPopular, .freshBrews: return 364.0 /* this also includes gray separator */ / 445.0 * screenWidth
            case CarouserIndex.featuredCollectionsHeader: return 45
            case .ciceronesChoice, .staffsPick, .gameDay: return (298 + 10 /* 10 is spacing between cells */) / 447 * screenWidth
            case CarouserIndex.separator: return 9
            default: return 403 / 746 * screenWidth
        }
    }

}
