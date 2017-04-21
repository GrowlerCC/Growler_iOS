//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class MyOrdersViewController: UITableViewController {

    private var orders: [BUYOrder] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        /**
        not implemented because it requires for user to log into shopify
        getOrders().then {
            orders -> Void in
            self.orders = orders
            mq { self.tableView.reloadData() }
        }
        */
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        let order = orders[indexPath.row]
        cell.textLabel?.text = order.name + ": " + Utils.formatUSD(value: order.totalPrice)
        return cell
    }

}
