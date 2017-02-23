//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CarouselTableCell: UITableViewCell {

    @IBOutlet weak var carousel: SwiftCarousel!
    
    @IBOutlet weak var topCarouselConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!

    static func create(title: String, itemsPerPage: CGFloat) -> CarouselTableCell {
        let cell = CarouselTableCell.loadFromNib()
        
        cell.titleLabel.text = title
        if title.isEmpty {
            cell.titleLabel.isHidden = true
            cell.topCarouselConstraint.constant = 0
        }
        
        // visibleItemsPerPage is the only resize type in which SwiftCarousel doesn't crash when empty
        // so setting resize type here
        // also resizeType should always be set before setting items
        cell.carousel.resizeType = .visibleItemsPerPage(Int(itemsPerPage))

        return cell
    }

    private func setupCarousel(_ carousel: SwiftCarousel) {
        carousel.selectByTapEnabled = true
        let count = 0//min(10, products.count) // limited by 10 items to not exhaust memory
        try! carousel.itemsFactory(itemsCount: count) {
            index in
            let view = Utils.loadViewFromNib(nibName: "ProductBannerView", owner: self) as! ProductBannerView
            //let product = products[index]
            /*
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
            */
            return view
        }
        carousel.layoutSubviews() // this will update scrollview content size
        // todo? carousel.delegate = self
    }

}
