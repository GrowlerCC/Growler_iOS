//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy;

class HomeViewController: UIViewController, SwiftCarouselDelegate {

    // todo show ProductViewController when tapping on banners

    private var menuController: PopupMenuViewController!

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!

    private var products: [BUYProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        menuController = PopupMenuViewController()
        menuController.homeController = self

        let menuButtonImage = UIImage(named: "MenuButton")?.withRenderingMode(.alwaysOriginal)
        let menuButton = UIBarButtonItem(image: menuButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapMenuButton))
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = menuButton

        let searchButtonImage = UIImage(named: "SearchButton")?.withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapSearchButton))

        let checkoutButtonImage = UIImage(named: "CheckoutButton")?.withRenderingMode(.alwaysOriginal)
        let checkoutButton = UIBarButtonItem(image: checkoutButtonImage, style: .plain, target: self, action: #selector(HomeViewController.didTapCheckoutButton))

        navigationController?.topViewController?.navigationItem.rightBarButtonItems = [checkoutButton, searchButton]

        let addressController = ConfirmAddressViewController.loadFromStoryboard(name: "ConfirmAddressViewController", type: ConfirmAddressViewController.self)
        navigationController!.present(addressController, animated: false)

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
                    Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.switchTopCarousel), userInfo: nil, repeats: true)
                    Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.switchBottomCarousel), userInfo: nil, repeats: true)
                }
            } else {
                print("Error fetching products: \(error)")
            }
        }
    }

    func didTapMenuButton() {
        present(menuController, animated: true)
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

    func didTapCheckoutButton() {
        let controller = CartViewController(client: ShopifyController.instance.client, collection: nil)!
        navigationController!.pushViewController(controller, animated: true)
    }

    func didTapSearchButton() {
        let controller = CollectionListViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

    func switchTopCarousel() {
        if let current = topCarousel.selectedIndex {
            topCarousel.selectItem(current + 1, animated: true)
        }
    }

    func switchBottomCarousel() {
        if let current = bottomCarousel.selectedIndex {
            bottomCarousel.selectItem(current + 1, animated: true)
        }
    }

}
