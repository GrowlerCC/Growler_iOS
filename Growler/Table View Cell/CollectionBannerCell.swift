//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionBannerCell: UITableViewCell {

    @IBOutlet weak var picture: AsyncImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    class func create(collectionId: CollectionIdentifier) -> CollectionBannerCell {
        let cell = CollectionBannerCell.loadFromNib()

        ShopifyController.instance.client.getCollectionsByIds([String(collectionId.rawValue)], page: 1) {
            collections, page in
            guard let collection = collections?.first else {
                return
            }
            cell.picture.loadImage(with: collection.image?.sourceURL.absoluteURL, completion: nil)
            cell.titleLabel.text = collection.title
            cell.descriptionLabel.text = collection.stringDescription
        }

        return cell
    }

}
