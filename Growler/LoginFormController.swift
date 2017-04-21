//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

// use https://growler-express.myshopify.com/account/register to register
class LoginFormController: FormTableViewController {

    override func getCells() -> [UITableViewCell] {
        let loginCell = UITableViewCell()
        loginCell.backgroundColor = Colors.grayBackground
        loginCell.textLabel?.text = "Not a member? Register"
        loginCell.textLabel?.textColor = Colors.launchScreenOrangeColor
        loginCell.textLabel?.textAlignment = .center
        loginCell.textLabel?.font = UIFont.systemFont(ofSize: 12)

        return [
            FormTableCell.create(FormInput.create(
                title: "Email",
                name: LoginFields.email.rawValue,
                required: true,
                type: .email)),
            FormTableCell.create(FormInput.create(
                title: "Password",
                name: LoginFields.password.rawValue,
                required: true,
                type: .password
            )),
            loginCell
        ]
    }

    public override func getOkButtonTitle() -> String {
        return "Sign in"
    }

    internal override func getTitle() -> String {
        return "Sign in"
    }

    override func saveData(_ data: JSON) -> Bool {
        let email = data[LoginFields.email.rawValue].string ?? ""
        let password = data[LoginFields.password.rawValue].string ?? ""
        let items: [BUYAccountCredentialItem] = [
            BUYAccountCredentialItem(email: email),
            BUYAccountCredentialItem(password: password),
        ]

        let credentials = BUYAccountCredentials(items: items)
        ShopifyController.instance.client.loginCustomer(with: credentials) {
            (customer, token, error) -> Void in
            print("\(customer), \(token), \(error)")
            if let error = error {
                Utils.alert(message: "Invalid user or password", parent: self)
            } else {
                ShopifyController.instance.loginEmailString.value = email
                ShopifyController.instance.loginPasswordString.value = password

                ShopifyController.instance.customer = customer
                self.navigationController?.dismiss(animated: true)
            }
        }
        return false // We don't hide this form right after saveData returns. Instead waiting for callback to complete
    }

    override func loadData() -> JSON {
        return JSON([:])
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 2 {
            let controller = RegisterFormController()
            controller.loginForm = self
            controller.popupWithNavigationController(parentController: self)
        }
        return nil
    }

}
