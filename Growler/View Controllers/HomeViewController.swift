//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import SwiftCarousel

class HomeViewController: UIViewController, SwiftCarouselDelegate {

    // todo show CollectionListViewController when tapping on banners

    private var menuController: PopupMenuViewController!

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!
    
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

        setupTopCarousel()
        setupBottomCarousel()
    }

    func didTapMenuButton() {
        present(menuController, animated: true)
    }

    private func setupTopCarousel() {
        let carousel = topCarousel!
        carousel.selectByTapEnabled = false
        try! carousel.itemsFactory(itemsCount: 5) {
            index in
            let view = Utils.loadViewFromNib(nibName: "ProductBannerView", owner: self) as! ProductBannerView
            return view
        }
        carousel.resizeType = .visibleItemsPerPage(1)
        carousel.delegate = self
        carousel.defaultSelectedIndex = 2
        view.addSubview(carousel)
    }

    private func setupBottomCarousel() {
        let carousel = bottomCarousel!
        carousel.selectByTapEnabled = false
        try! carousel.itemsFactory(itemsCount: 5) {
            index in
            let view = Utils.loadViewFromNib(nibName: "ProductBannerView", owner: self) as! ProductBannerView
            return view
        }
        carousel.resizeType = .visibleItemsPerPage(2)
        carousel.delegate = self
        carousel.defaultSelectedIndex = 2
        view.addSubview(carousel)
    }

    func didTapCheckoutButton() {
    }

    func didTapSearchButton() {
        let controller = CollectionListViewController()
        navigationController!.pushViewController(controller, animated: true)
    }

}
