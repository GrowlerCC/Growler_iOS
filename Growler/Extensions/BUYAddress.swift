//
// Created by Alexander Gorbovets on 2017-02-27.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

extension BUYAddress {

    func loadFrom(json: JSON) {
        address1     = json[AddressFields.address1.rawValue].string
        address2     = json[AddressFields.address2.rawValue].string
        city         = json[AddressFields.city.rawValue].string
        company      = json[AddressFields.company.rawValue].string
        firstName    = json[AddressFields.firstName.rawValue].string
        lastName     = json[AddressFields.lastName.rawValue].string
        phone        = json[AddressFields.phone.rawValue].string
        countryCode  = json[AddressFields.countryCode.rawValue].string
        provinceCode = json[AddressFields.provinceCode.rawValue].string
        zip          = json[AddressFields.zip.rawValue].string
    }

}
