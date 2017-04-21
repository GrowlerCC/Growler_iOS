//
// Created by Jeff H. on 2017-02-27.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON

class FormTableViewController: UITableViewController {

    public var onSave: (() -> Void)?

    private var items: [FormTableCell] = []

    private var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        saveButton = UIBarButtonItem(title: onSave != nil ? "Continue" : "Save", style: .plain, target: self, action: #selector(self.didTapSaveButton))

        items = getItems()
        let data = loadData()
        for item in items {
            item.field.text = data[item.name].string
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = saveButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItem = saveButton
    }

    func getItems() -> [FormTableCell] {
        return []
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return items[indexPath.row]
    }

    func isValid() -> Bool {
        var result = true

        // using for loop instead of items.reduce because we don't need lazy evaluation. we need to validate all fields
        for item in items {
            if !item.isValid() {
                result = false
            }
        }
        return result
    }
    
    func getValues() -> JSON {
        var result = JSON(parseJSON: "{}")
        for item in items {
            let value = item.field.text ?? ""
            result[item.name].string = value.isEmpty ? item.`default` : value
        }
        return result
    }

    func didTapSaveButton() {
        if isValid() {
            let values = getValues()
            saveData(values)
            if let onSave = onSave {
                onSave()
            } else {
                navigationController!.popViewController(animated: true)
            }
        }
    }

    public func saveData(_ data: JSON) {
    }

    public func loadData() -> JSON {
        return JSON(parseJSON: "{}")
    }

}
