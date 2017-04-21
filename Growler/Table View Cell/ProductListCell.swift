//
// Created by Jeff H. on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

@objc
class ProductListCell: UITableViewCell {

    static let HEIGHT: CGFloat = 76

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var picture: AsyncImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupWithProduct(_ product: BUYProduct) {
        accessoryType = .none
        titleLabel.text = product.title
        descriptionLabel.text = product.stringDescription
        priceLabel.text = Utils.formatUSD(value: product.minimumPrice)

        if let image = product.images.firstObject, let link = image as? BUYImageLink {
            picture.loadImage(with: link.sourceURL, completion: nil)
        }
    }

}
