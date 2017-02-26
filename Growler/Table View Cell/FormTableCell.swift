//
// Created by Alexander Gorbovets on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FormTableCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var field: UITextField!
    
    var name: String = ""

    private var required: Bool = false

    static func create(title: String, name: String, required: Bool, minLength: Int? = nil, maxLength: Int? = nil) -> FormTableCell {
        let cell = FormTableCell.loadFromNib()
        cell.label.text = title
        cell.errorLabel.text = ""
        cell.required = required
        cell.name = name
        return cell
    }

    func isValid() -> Bool {
        let isEmpty = field.text?.isEmpty ?? true
        if required && isEmpty {
            errorLabel.text = "This field is required"
            return false
        }
        return true
    }
    
}
