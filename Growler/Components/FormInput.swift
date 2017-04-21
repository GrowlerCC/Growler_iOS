//
// Created by Jeff H. on 2017-03-16.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FormInput: UIView {

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var field: UITextField!

    @IBOutlet weak var fieldWidthConstraint: NSLayoutConstraint!
    
    var name: String = ""

    var `default`: String?

    private var required: Bool = false

    static func create(
        title: String,
        name: String,
        required: Bool,
        `default`: String? = nil,
        type: FormFieldType = .text,
        inputWidth: CGFloat? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil
    ) -> FormInput {
        let cell = FormInput.loadFromNib()
        cell.label.text = title
        cell.`default` = `default`
        cell.field.placeholder = `default`
        cell.errorLabel.text = ""
        cell.required = required
        cell.name = name
        if let inputWidth = inputWidth {
            cell.fieldWidthConstraint.constant = inputWidth
            cell.fieldWidthConstraint.isActive = true
        } else {
            cell.fieldWidthConstraint.isActive = false
        }
            
        switch type {
        case .text: break
        case .password:
            cell.field.isSecureTextEntry = true
            break
        }
        return cell
    }

    func isValid() -> Bool {
        let isEmpty = field.text?.isEmpty ?? true
        if required && isEmpty {
            errorLabel.text = "This field is required"
            return false
        }
        errorLabel.text = ""
        return true
    }

}
