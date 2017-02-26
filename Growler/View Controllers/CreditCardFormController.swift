//
// Created by Alexander Gorbovets on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class CreditCardFormController: FormTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            FormTableCell.create(title: "Number", name: CreditCardFields.number.rawValue, required: true),
            FormTableCell.create(title: "Expiry Month", name: CreditCardFields.expiryMonth.rawValue, required: true),
            FormTableCell.create(title: "Expiry Year", name: CreditCardFields.expiryYear.rawValue, required: true),
            FormTableCell.create(title: "CVV", name: CreditCardFields.cvv.rawValue, required: true),
            FormTableCell.create(title: "Name on Card", name: CreditCardFields.nameOnCard.rawValue, required: true),
        ]
    }

}
