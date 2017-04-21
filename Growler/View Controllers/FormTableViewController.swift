//
// Created by Jeff H. on 2017-02-27.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class FormTableViewController: UITableViewController, UITextFieldDelegate {

    public var onSave: (() -> Void)?

    private var cells: [UITableViewCell] = []

    private var fields: [FormInput] = []

    private var buttonItems: [UIBarButtonItem]!

    private var closeButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Colors.grayBackground
        tableView.separatorColor = Colors.grayBackground
        
        let okButton = UIButton()
        okButton.setTitle(getOkButtonTitle(), for: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        okButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        okButton.sizeToFit()
        okButton.addTarget(self, action: #selector(self.didTapSaveButton), for: .touchUpInside)
        let okButtonWrapper = UIBarButtonItem(customView: okButton)

        closeButton = UIBarButtonItem(image: UIImage(named: "CloseMenuButton"), style: .plain, target: self, action: #selector(self.didTapCloseButton))
        
        buttonItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            okButtonWrapper,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]

        cells = getCells()
        
        fields = cells
            .filter{ $0 is FormTableCell }
            .reduce([FormInput]()) { $0 + ($1 as! FormTableCell).inputs }

        let data = loadData()
        for field in fields {
            field.field.text = data[field.name].string
            field.field.delegate = self
            field.updateLabel()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didTapSaveButton()
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToolbars()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolbars()
    }

    public func getOkButtonTitle() -> String {
        return "Save"
    }

    func setupToolbars() {
        setupDarkToolbars()
        navigationItem.leftBarButtonItem = closeButton
        setToolbarItems(buttonItems, animated: false)
    }

    func getCells() -> [UITableViewCell] {
        return []
    }

    public func getTitle() -> String {
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CoreGraphics.CGFloat {
        return 45
    }

    func isValid() -> Bool {
        var result = true

        // using for loop instead of items.reduce because we don't need lazy evaluation. we need to validate all fields
        for field in fields {
            if !field.isValid() {
                result = false
            }
        }
        return result
    }
    
    func getValues() -> JSON {
        var result = JSON(parseJSON: "{}")
        for field in fields {
            let value = field.field.text ?? ""
            result[field.name].string = value.isEmpty ? field.`default` : value
        }
        return result
    }

    func didTapSaveButton() {
        if isValid() {
            let values = getValues()
            guard saveData(values) else {
                return
            }
            if let onSave = onSave {
                onSave()
            } else {
                navigationController!.dismiss(animated: true)
            }
        }
    }

    func didTapCloseButton() {
        navigationController?.dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    public func saveData(_ data: JSON) -> Bool {
        return true
    }

    public func loadData() -> JSON {
        return JSON(parseJSON: "{}")
    }

}
