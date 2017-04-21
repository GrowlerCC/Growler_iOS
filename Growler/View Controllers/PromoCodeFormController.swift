//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class PromoCodeFormController: FormTableViewController {

    override func getCells() -> [UITableViewCell] {
        return [
            FormTableCell.create(FormInput.create(title: "Promo code", name: PromoCodeFields.promoCode.rawValue, required: false)),
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Promo Code"
    }

    override func saveData(_ data: JSON) -> Bool {
        let rawString = data.rawString()
        ShopifyController.instance.promoCodeJsonString.value = rawString ?? "{}"
        return true
    }

    override func loadData() -> JSON {
        let value = ShopifyController.instance.promoCodeJsonString.value
        return JSON(data: value.data(using: .utf8)!) // important: don't use JSON(parseString:), it doesn't work!!!
    }

}
