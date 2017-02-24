//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class TagBanner: UIView {

    @IBOutlet weak var picture: AsyncImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    private var tagName: String!
    
    private var recognizer: UITapGestureRecognizer!

    class func create(tag: String) -> TagBanner {
        let cell = Utils.loadViewFromNib(nibName: "TagBanner", owner: nil) as! TagBanner
        cell.tagName = tag
        cell.titleLabel.text = tag
        return cell
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(recognizer)
    }

    func didTap(_ sender: UITapGestureRecognizer) {
        let controller = ProductListViewController(client: ShopifyController.instance.client, collection: nil)!
        controller.tags = [tagName]
        AppDelegate.shared.navigationController.pushViewController(controller, animated: true)
    }

}
