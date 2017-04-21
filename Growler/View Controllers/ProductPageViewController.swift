//
// Created by Jeff H. on 2017-03-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public var product: BUYProduct! // should be assigned by creating code

    private var products: [BUYProduct] = []
    
    private var buttonItems: [UIBarButtonItem] = []

    private var currentProduct: BUYProduct!

    private var currentController: ProductViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        currentProduct = product

        products = [product]

        getProductsPage(page: 1).then {
            products -> Void in
            var filteredProducts = products.filter { $0.identifierValue != self.product.identifierValue }
            filteredProducts.insert(self.product, at: 0)
            self.products = filteredProducts
        }

        self.dataSource = self
        self.delegate = self

        currentController = getViewControllerAtIndex(0)
        self.setViewControllers([currentController], direction: .forward, animated: false, completion: nil)

        let checkoutButton = UIButton()
        checkoutButton.setTitle("Add to Cart", for: .normal)
        checkoutButton.setTitleColor(UIColor.white, for: .normal)
        checkoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        checkoutButton.addTarget(self, action: #selector(self.addToCart), for: .touchUpInside)
        checkoutButton.sizeToFit()
        let checkoutButtonWrapper = UIBarButtonItem(customView: checkoutButton)

        buttonItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            checkoutButtonWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToolbarItems(buttonItems, animated: false)
    }

    private func getViewControllerAtIndex(_ i: Int) -> ProductViewController {
        let controller = ProductViewController()
        controller.product = products[i]
        controller.productPageViewController = self
        controller.pageIndex = i
        if let navigationController = navigationController {
            controller.topContentInset = Utils.calculateTopInset(navigationController: navigationController)
        }
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! ProductViewController
        var index = pageContent.pageIndex
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1;
        return getViewControllerAtIndex(index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! ProductViewController
        var index = pageContent.pageIndex
        if index == NSNotFound {
            return nil;
        }
        index += 1;
        if (index >= products.count) {
            return nil;
        }
        return getViewControllerAtIndex(index)
    }

    func addToCart() {
        let result = ShopifyController.instance.addProductToCart(currentProduct)
        if result {
            currentController.showMessageBanner = true
            mq { self.currentController.tableView.reloadData() }
        } else {
            Utils.alert(message: "Failed to create cart. Check network connection", parent: self)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            currentController = pageViewController.viewControllers?.first as! ProductViewController
            currentProduct = currentController.product
        }
    }

}
