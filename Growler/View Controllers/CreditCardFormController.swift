//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class CreditCardFormController: FormTableViewController {

    override func getItems() -> [FormTableCell] {
        return [
            FormTableCell.create(title: "Number", name: CreditCardFields.number.rawValue, required: true),
            FormTableCell.create(title: "Expiry Month", name: CreditCardFields.expiryMonth.rawValue, required: true),
            FormTableCell.create(title: "Expiry Year", name: CreditCardFields.expiryYear.rawValue, required: true),
            FormTableCell.create(title: "CVV", name: CreditCardFields.cvv.rawValue, required: true),
            FormTableCell.create(title: "Name on Card", name: CreditCardFields.nameOnCard.rawValue, required: true),
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Credit Card"
    }

    override func saveData(_ data: JSON) {
        let rawString = data.rawString()
        ShopifyController.instance.creditCardJsonString.value = rawString ?? "{}"
    }

    override func loadData() -> JSON {
        let value = ShopifyController.instance.creditCardJsonString.value
        return JSON(data: value.data(using: .utf8)!) // imaportnat: don't use JSON(parseString:), it doesn't work!!!
    }

}
