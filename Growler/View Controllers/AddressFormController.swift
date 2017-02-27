//
// Created by Alexander Gorbovets on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddressFormController: FormTableViewController {

    override func getItems() -> [FormTableCell] {
        return [
            FormTableCell.create(title: "Address 1", name: AddressFields.address1.rawValue, required: true),
            FormTableCell.create(title: "Address 2", name: AddressFields.address2.rawValue, required: true),
            FormTableCell.create(title: "City", name: AddressFields.city.rawValue, required: true),
            FormTableCell.create(title: "Company", name: AddressFields.company.rawValue, required: true),
            FormTableCell.create(title: "First Name", name: AddressFields.firstName.rawValue, required: true),
            FormTableCell.create(title: "Last Name", name: AddressFields.lastName.rawValue, required: true),
            FormTableCell.create(title: "Phone", name: AddressFields.phone.rawValue, required: true),
            FormTableCell.create(title: "Country Code", name: AddressFields.countryCode.rawValue, required: true),
            FormTableCell.create(title: "Province Code", name: AddressFields.provinceCode.rawValue, required: true),
            FormTableCell.create(title: "Zip", name: AddressFields.zip.rawValue, required: true),
        ]
    }

    override func saveData(_ data: JSON) {
        let rawString = data.rawString(.utf8 )
        ShopifyController.instance.addressJsonString.value = rawString ?? "{}"
    }

    override func loadData() -> JSON {
        let value = ShopifyController.instance.addressJsonString.value
        return JSON(data: value.data(using: .utf8)!) // imaportnat: don't use JSON(parseString:), it doesn't work!!!
    }

}
