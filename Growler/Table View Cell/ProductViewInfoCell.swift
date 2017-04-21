//
// Created by Jeff H. on 2017-03-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import Buy

class ProductViewInfoCell: UITableViewCell {

    @IBOutlet weak var picture: AsyncImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    
    // todo rename to vendorLabel
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var specificationsLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var brewersNotesLabel: UILabel!
    
    weak var productPageViewController: ProductPageViewController?
    
    func setupWithProduct(_ product: BUYProduct) {
        if let image = product.images.firstObject as? BUYImageLink {
            picture.loadImage(with: image.sourceURL, completion: nil)
        }
        titleLabel.text = product.title
        priceLabel.text = Utils.formatUSD(value: product.minimumPrice)
        collectionLabel.text = product.vendor ?? ""
        specificationsLabel.text = product.productType // todo?
        descriptionLabel.text = product.stringDescription
        brewersNotesLabel.text = "" //
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        productPageViewController?.navigationController?.popViewController(animated: true)
    }
    
}
