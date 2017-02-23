//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import Buy
import CoreGraphics

class HomeViewController: UITableViewController {

    @IBOutlet weak var topCarousel: SwiftCarousel!
    
    @IBOutlet weak var bottomCarousel: SwiftCarousel!

    private var items: [UITableViewCell] = (0...7).map{ _ in ActivityIndicatorTableCell.loadFromNib() }

    private var contentHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.createCarouselCells), userInfo: nil, repeats: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentHeight = Utils.calculateContentHeight(navigationController: navigationController!)
    }

    func createCarouselCells() {
        self.items[0] = CarouselTableCell.create(title: "", itemsPerPage: 1)

        self.items[1] = CarouselTableCell.create(title: "Recommended for You", itemsPerPage: 1.5)

        self.items[2] = CarouselTableCell.create(title: "Featured Collections", itemsPerPage: 2.5)

        self.items[3] = CarouselTableCell.create(title: "Cicerone’s Choice", itemsPerPage: 2.5)

        self.items[4] = CarouselTableCell.create(title: "Staff’s Pick", itemsPerPage: 2.5)

        self.items[5] = CarouselTableCell.create(title: "Shop By Collections", itemsPerPage: 2.5)

        self.items[6] = CarouselTableCell.create(title: "Shop By Style", itemsPerPage: 2.5)

        self.items[7] = CarouselTableCell.create(title: "Shop By Price", itemsPerPage: 2.5)

        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return items[indexPath.item]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row < 2 ? contentHeight / 2 : contentHeight / 3 // first 2 carousels take 1/2 of screen height, others - 1/3
    }

}
