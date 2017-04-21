//
// Created by Jeff H. on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

enum AccountCellIndex: Int {
    case email
    case myCreditCards
    case myAddresses
    case myRecommendations
}

class AccountProfileViewController: UITableViewController, Notifiable {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        subscribeTo(Notification.Name.accountChanged, selector: #selector(self.accountChanged))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        let label: String
        switch AccountCellIndex(rawValue: indexPath.row)! {
            case .email: label = "Email: \(getEmail())"
            case .myCreditCards: label = "My Credit Cards: \(getMaskedCreditCard())"
            case .myAddresses: label = "My Address: \(getAddress())"
            case .myRecommendations: label = "My Recommendations"
        }
        cell?.textLabel?.text = label
        return cell!
    }

    func getEmail() -> String {
        return ShopifyController.instance.email.value
    }

    func getMaskedCreditCard() -> String {
        var number = ShopifyController.instance.getCreditCard().number ?? ""
        let endIndex = max(0, number.characters.count - 4)
        let start = number.index(number.startIndex, offsetBy: 0)
        let end = number.index(number.startIndex, offsetBy: endIndex)
        number.replaceSubrange(start..<end, with: "************")
        return number
    }

    func getAddress() -> String {
        return ShopifyController.instance.getAddress()?.address1 ?? ""
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AccountCellIndex(rawValue: indexPath.row)! {
            case .email:
                Utils.inputBox(
                    title: "Email",
                    message: "Enter your email",
                    okTitle: "OK")
                {
                    if let value = $0 {
                        ShopifyController.instance.email.value = value
                    }
                }
            case .myCreditCards:
                let controller = CreditCardFormController()
                navigationController!.pushViewController(controller, animated: true)

            case .myAddresses:
                let controller = AddressFormController()
                navigationController!.pushViewController(controller, animated: true)

            case .myRecommendations:
                AppDelegate.shared.navigationController.viewControllers = [RecommendationListViewController()]
        }
    }

    func accountChanged() {
        mq {
            self.tableView.reloadData()
        }
    }


}
