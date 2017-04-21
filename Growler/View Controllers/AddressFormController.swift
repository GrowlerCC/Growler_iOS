//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

// todo rename to ProfileViewController
class AddressFormController: FormTableViewController {

    override func getCells() -> [UITableViewCell] {
        let headerCell = UITableViewCell()
        headerCell.textLabel?.text = "ADDRESS"
        headerCell.backgroundColor = Colors.grayBackground

        return [
            FormTableCell.create(inputs: [
                FormInput.create(title: "Name", name: AddressFields.firstName.rawValue, required: true),
                FormInput.create(title: "", name: AddressFields.lastName.rawValue, required: true, inputWidth: 100)
            ]),
            FormTableCell.create(FormInput.create(title: "Email", name: AddressFields.email.rawValue, required: true)),
            FormTableCell.create(FormInput.create(title: "Phone", name: AddressFields.phone.rawValue, required: true)),

            headerCell,

            FormTableCell.create(FormInput.create(title: "Address", name: AddressFields.address1.rawValue, required: true)),
            FormTableCell.create(FormInput.create(title: "Optional Company or Apt. Number", name: AddressFields.company.rawValue, required: false)),
            FormTableCell.create(inputs: [
                FormInput.create(title: "City", name: AddressFields.city.rawValue, required: true),
                FormInput.create(title: "State", name: AddressFields.provinceCode.rawValue, required: false, default: "MN", inputWidth: 40),
                FormInput.create(title: "Zip", name: AddressFields.zip.rawValue, required: true, inputWidth: 80),
            ])
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        onSave = {
            self.navigationController?.dismiss(animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Profile"
    }

    override func saveData(_ data: JSON) -> Bool {
        let rawString = data.rawString(.utf8 )
        ShopifyController.instance.addressJsonString.value = rawString ?? "{}"
        return true
    }

    override func loadData() -> JSON {
        let value = ShopifyController.instance.addressJsonString.value
        return JSON(data: value.data(using: .utf8)!) // important: don't use JSON(parseString:), it doesn't work!!!
    }

}
