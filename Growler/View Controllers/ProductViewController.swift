//
// Created by Jeff H. on 2017-03-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

enum ProductViewSection: Int {
    case banner
    case info
    case variantsHeader
    case variants
}

@objc
class ProductViewController: UITableViewController {

    var product: BUYProduct!

    var pageIndex: Int = 0

    var topContentInset: CGFloat = 0

    var showMessageBanner: Bool = false

    private var infoCell: ProductViewInfoCell!

    weak var productPageViewController: ProductPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        infoCell = ProductViewInfoCell.loadFromNib()
        infoCell.productPageViewController = productPageViewController
        infoCell.setupWithProduct(product)
        tableView.contentInset = UIEdgeInsets(top: topContentInset, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.clear
    }

    override func numberOfSections(`in` tableView: UITableView) -> Int {
        return 2 // disabled variants, because this store didn't configure them  4 // should be equal to count of members in ProductViewSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = ProductViewSection(rawValue: section)!
        switch section {
            case .banner:
                return showMessageBanner ? 1 : 0
            case .info:
                return 1
            case .variantsHeader:
                return 1
            case .variants:
                return product.variantsArray().count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = ProductViewSection(rawValue: indexPath.section)!
        switch section {
            case .banner:
                let cell = CheckoutTableCell.loadFromNib()
                cell.backgroundColor = Colors.launchScreenOrangeColor
                cell.titleLabel?.textColor = UIColor.white
                cell.titleLabel?.text = "Product has been added to cart"
                cell.valueLabel?.textColor = UIColor.white
                cell.valueLabel?.text = "×"
                return cell
            case .info:
                return infoCell
            case .variantsHeader:
                let cell = UITableViewCell()
                cell.textLabel?.text = "CHOOSE A SIZE"
                return cell
            case .variants:
                let cell = UITableViewCell()
                let weightInGrams = product.variantsArray()[indexPath.row].grams
                let weightInOz = weightInGrams?.multiplying(by: NSDecimalNumber(decimal: Decimal(0.035274)))
                cell.textLabel?.text = Utils.formatDecimal(weightInOz ?? 0) + "oz Growler"
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CoreGraphics.CGFloat {
        let section = ProductViewSection(rawValue: indexPath.section)!
        switch section {
            case .banner:
                return 40
            case .info:
                return 450
            case .variantsHeader:
                return 40
            case .variants:
                return 40
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = ProductViewSection(rawValue: indexPath.section)!
        switch section {
            case .banner:
                showMessageBanner = false
                mq { self.tableView.reloadData() }
                return nil
            case .info:
                return nil
            case .variantsHeader:
                return nil
            case .variants:
                return nil
        }
    }

}
