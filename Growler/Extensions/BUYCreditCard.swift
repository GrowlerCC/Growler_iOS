//
// Created by Jeff H. on 2017-02-27.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

extension BUYCreditCard {

    func loadFrom(json: JSON) {
        number      = json[CreditCardFields.number.rawValue].string
        expiryMonth = json[CreditCardFields.expiryMonth.rawValue].string
        expiryYear  = json[CreditCardFields.expiryYear.rawValue].string
        cvv         = json[CreditCardFields.cvv.rawValue].string
        nameOnCard  = json[CreditCardFields.nameOnCard.rawValue].string
    }

}
