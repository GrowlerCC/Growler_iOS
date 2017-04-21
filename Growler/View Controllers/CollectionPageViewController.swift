//
// Created by Jeff H. on 2017-03-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class CollectionPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public var collection: BUYCollection! // should be assigned by creating code

    private var collections: [BUYCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collections = [collection]

        getCollectionsPage(page: 1).then {
            collections -> Void in
            var filteredCollections = collections.filter { $0.identifierValue != self.collection.identifierValue }
            filteredCollections.insert(self.collection, at: 0)
            self.collections = filteredCollections
        }

        self.dataSource = self
        self.delegate = self

        self.setViewControllers([getViewControllerAtIndex(0)], direction: .forward, animated: false, completion: nil)
    }

    private func getViewControllerAtIndex(_ i: Int) -> UIViewController {
        let controller = ProductListViewController()
        controller.collection = collections[i]
        controller.pageIndex = i
        controller.navController = navigationController
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! ProductListViewController
        var index = Int(pageContent.pageIndex)
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1;
        return getViewControllerAtIndex(index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent = viewController as! ProductListViewController
        var index = Int(pageContent.pageIndex)
        if index == NSNotFound {
            return nil;
        }
        index += 1;
        if (index >= collections.count) {
            return nil;
        }
        return getViewControllerAtIndex(index)
    }

}
