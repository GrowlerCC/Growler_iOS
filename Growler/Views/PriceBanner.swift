//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class PriceBanner: UIView {

    @IBOutlet weak var picture: AsyncImageView!
    
    @IBOutlet weak var priceLabel: UILabel!

    public var priceRange: PriceRange!

    private var recognizer: UITapGestureRecognizer!

    class func create(priceRange: PriceRange) -> PriceBanner {
        let cell = Utils.loadViewFromNib(nibName: "PriceBanner", owner: nil) as! PriceBanner
        cell.priceRange = priceRange
        cell.priceLabel.text = priceRange.title
        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(recognizer)
    }

    func didTap(_ sender: UITapGestureRecognizer) {
        let controller = ProductListViewController(client: ShopifyController.instance.client, collection: nil)!
        if let start = priceRange.startPrice {
            controller.minPrice = NSDecimalNumber(integerLiteral: start)
        }
        if let end = priceRange.endPrice {
            controller.maxPrice = NSDecimalNumber(integerLiteral: end)
        }
        AppDelegate.shared.navigationController.pushViewController(controller, animated: true)
    }

}
