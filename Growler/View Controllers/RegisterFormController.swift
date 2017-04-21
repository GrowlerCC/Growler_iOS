//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class RegisterFormController: FormTableViewController {

    var loginForm: LoginFormController?

    override func getCells() -> [UITableViewCell] {

        return [
            FormTableCell.create(FormInput.create(title: "First Name", name: RegisterFields.firstName.rawValue, required: true)),
            FormTableCell.create(FormInput.create(title: "Last Name", name: RegisterFields.lastName.rawValue, required: true)),
            FormTableCell.create(FormInput.create(
                title: "Email",
                name: RegisterFields.email.rawValue,
                required: true,
                type: .email
            )),
            FormTableCell.create(FormInput.create(
                title: "Password",
                name: RegisterFields.password.rawValue,
                required: true,
                type: .password
            )),
        ]
    }

    public override func getOkButtonTitle() -> String {
        return "Register"
    }

    internal override func getTitle() -> String {
        return "Register"
    }

    override func saveData(_ data: JSON) -> Bool {
        let email = data[RegisterFields.email.rawValue].string ?? ""
        let password = data[RegisterFields.password.rawValue].string ?? ""
        let first = data[RegisterFields.firstName.rawValue].string ?? ""
        let last = data[RegisterFields.lastName.rawValue].string ?? ""
        let items: [BUYAccountCredentialItem] = [
            BUYAccountCredentialItem(email: email),
            BUYAccountCredentialItem(password: password),
            BUYAccountCredentialItem(firstName: first),
            BUYAccountCredentialItem(lastName: last),
        ]

        let credentials = BUYAccountCredentials(items: items)
        ShopifyController.instance.client.createCustomer(with: credentials) {
            (customer, token, error) -> Void in
            print("\(customer), \(token), \(error)")
            if let error = error as? NSError {
                let message = Utils.formatErrorInfo(error.userInfo, message: "Cannot create user")
                Utils.alert(message: message, parent: self)
            } else {
                ShopifyController.instance.customer = customer
                self.navigationController?.dismiss(animated: true)
                self.loginForm?.navigationController?.dismiss(animated: false)
            }
        }
        return false // We don't hide this form right after saveData returns. Instead waiting for callback to complete
    }

    override func loadData() -> JSON {
        return JSON([:])
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 2 {
            print("Register")
        }
        return nil
    }

}
