//
// Created by Jeff H. on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CollectionBanner: UIView {

    @IBOutlet weak var picture: AsyncImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    private var recognizer: UITapGestureRecognizer!

    public var collection: BUYCollection!

    class func create(collection: BUYCollection) -> CollectionBanner {
        let cell = Utils.loadViewFromNib(nibName: "CollectionBanner", owner: nil) as! CollectionBanner
        cell.collection = collection
        cell.titleLabel.text = collection.title
        cell.descriptionLabel.text = collection.stringDescription
        if let url = collection.image?.sourceURL.absoluteURL {
            cell.picture.loadImage(with: url, completion: nil)
        } else {
            cell.picture.image = UIImage(named: "NoImageAvailableSmall")
        }
        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(recognizer)
    }

    func didTap(_ sender: UITapGestureRecognizer) {
        let controller = CollectionPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.collection = collection
        AppDelegate.shared.navigationController.pushViewController(controller, animated: true)
    }

}
