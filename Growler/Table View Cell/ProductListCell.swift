//
// Created by Alexander Gorbovets on 2017-02-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

@objc
class ProductListCell: UITableViewCell {

    static let HEIGHT = 84

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var picture: AsyncImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        picture.layer.cornerRadius = 36
    }

}
