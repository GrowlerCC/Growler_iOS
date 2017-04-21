import Foundation
import UIKit
import Buy

class ProductListViewController: UITableViewController {

    var collection: BUYCollection?

    var collectionOperation: Operation?

    var products: [BUYProduct] = []

    var tags: [String]?

    var searchKeyword: String?

    var minPrice: NSDecimalNumber?

    var maxPrice: NSDecimalNumber?

    var pageIndex: Int = 0

    /// navController property is used if product list is inside of page controller.
    /// but we still needs to pop current controller when user taps close button
    var navController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.grayBackground
        self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0) // according to mockups
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let nib = UINib(nibName: "ProductListCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ProductListCell")
        self.loadProducts()
    }

    func loadProducts() {
        if self.collection != nil {
            self.getCollectionWithSortOrder(.collectionDefault)
        } else if self.tags != nil {
            self.getCollectionByTags()
        } else {
            // todo implement loading all pages as user scrolls UITableView
            ShopifyController.instance.client?.getProductsPage(1) {
                products, page, reachedEnd, error -> Void in
                if error == nil && products != nil {
                    self.products = self.filterProducts(products!)
                    self.tableView.reloadData()
                } else {
                    print("Error fetching products: \(error)")
                }
            }
        }
    }


    func filterProducts(_ products: [BUYProduct]) -> [BUYProduct] {
        if self.minPrice == nil && self.maxPrice == nil && self.searchKeyword == nil {
            return products
        }
        let searchKeywordLowerCase: String?
        if let searchKeyword = searchKeyword {
            if searchKeyword.isEmpty {
                searchKeywordLowerCase = nil
            } else {
                searchKeywordLowerCase = searchKeyword.lowercased()
            }
        } else {
            searchKeywordLowerCase = nil
        }
        var result = [BUYProduct]() /* capacity: products.count */
        for i in 0 ..< products.count {
            let product = products[i]
            guard let price = product.minimumPrice else {
                continue
            }
            if let minPrice = minPrice, price.compare(minPrice) == .orderedAscending {
                continue
            }
            if let maxPrice = maxPrice, price.compare(maxPrice) == .orderedDescending {
                continue
            }
            if let searchKeywordLowerCase = searchKeywordLowerCase, !doesProduct(product, matchKeyword: searchKeywordLowerCase) {
                continue
            }
            result.append(product)
        }
        return result
    }

    func doesProduct(_ product: BUYProduct, matchKeyword keyword: String) -> Bool {
        let title: String = product.title.lowercased()
        let description: String = product.title.lowercased()
        return (title as NSString).range(of: keyword).location != NSNotFound || (description as NSString).range(of: keyword).location != NSNotFound
    }

    deinit {
        self.collectionOperation?.cancel()
    }

    func getCollectionWithSortOrder(_ collectionSort: BUYCollectionSort) {
        collectionOperation?.cancel()
        guard let collection = collection else {
            return
        }
        self.collectionOperation = ShopifyController.instance.client.getProductsPage(1, inCollection: collection.identifier, withTags: nil, sortOrder: collectionSort) {
            products, page, reachedEnd, error -> Void in
            if error == nil {
                self.products = self.filterProducts(products ?? [])
                self.tableView.reloadData()
            } else {
                print("Error fetching products: \(error)")
            }
        }
    }

    func getCollectionByTags() {
        collectionOperation?.cancel()
        self.collectionOperation = ShopifyController.instance.client.getProductsByTags(tags ?? [], page: 1) {
            products, error -> Void in
            if error == nil {
                self.products = self.filterProducts(products ?? [])
                self.tableView.reloadData()
            } else {
                print("Error fetching products: \(error)")
            }
        }
    }

    override func numberOfSections(`in` tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return collection == nil ? 0 : 1
            default: return self.products.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                let cell = CollectionHeaderCell.loadFromNib()
                cell.productList = self
                cell.titleLabel.text = collection?.title
                cell.subtitleLabel.text = collection?.stringDescription
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell", for: indexPath) as! ProductListCell
                let product = products[indexPath.row]
                cell.setupWithProduct(product)
                return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0: return 77
            default: return ProductListCell.HEIGHT
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let product: BUYProduct? = self.products[indexPath.row]
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.demoProductViewController(with: product!)
        }
    }

    func demoProductViewController(with product: BUYProduct) {
        let productViewController = ProductPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        productViewController.product = product
        self.navigationController?.pushViewController(productViewController, animated: true)
    }

}
