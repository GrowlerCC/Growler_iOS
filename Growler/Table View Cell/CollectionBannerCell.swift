//
// Created by Jeff H. on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionBannerCell: UITableViewCell {

    @IBOutlet weak var picture: AsyncImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    private var recognizer: UITapGestureRecognizer!

    private var collectionId: CollectionIdentifier!

    private var collection: BUYCollection!

    class func create(collectionId: CollectionIdentifier) -> CollectionBannerCell {
        let cell = CollectionBannerCell.loadFromNib()
        cell.collectionId = collectionId

        ShopifyController.instance.client.getCollectionsByIds([String(collectionId.rawValue)], page: 1) {
            collections, page in
            guard let collection = collections?.first else {
                return
            }
            cell.collection = collection
            if let url = collection.image?.sourceURL.absoluteURL {
                cell.picture.loadImage(with: url, completion: nil)
            } else {
                cell.picture.image = UIImage(named: "NoImageAvailable")
            }
            cell.titleLabel.text = collection.title
            cell.descriptionLabel.text = collection.stringDescription
        }

        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(recognizer)
    }

    func didTap(_ sender: UITapGestureRecognizer) {
        guard collection != nil else {
            return
        }
        let controller = ProductListViewController(client: ShopifyController.instance.client, collection: collection)!
        AppDelegate.shared.navigationController.pushViewController(controller, animated: true)
    }

}
