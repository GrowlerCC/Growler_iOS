//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class ProductBannerView: UIView {

    var product: BUYProduct?

    @IBOutlet weak var image: AsyncImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var deliveryCostLabel: UILabel!
    
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!

    private var recognizer: UITapGestureRecognizer!

    override func awakeFromNib() {
        super.awakeFromNib()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(recognizer)

    }

    func didTap(_ sender: UITapGestureRecognizer) {
        if let product = product {
            let controller = ProductViewController(client: ShopifyController.instance.client)!
            controller.merchantId = MERCHANT_ID
            controller.load(with: product) { success, error in }
            AppDelegate.shared.navigationController.pushViewController(controller, animated: true)
        }
    }

}
