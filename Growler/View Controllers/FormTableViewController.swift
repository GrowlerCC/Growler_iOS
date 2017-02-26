//
// Created by Alexander Gorbovets on 2017-02-27.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FormTableViewController: UITableViewController {

    var items: [FormTableCell] = []

    private var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.didTapSaveButton))
        saveButton.title = "Save"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItem = saveButton
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
    
    func getValues() -> [String: String] {
        var result = [String: String]()
        for item in items {
            result[item.name] = item.field.text
        }
        return result
    }

    func didTapSaveButton() {
        if isValid() {
            let values = getValues()
            navigationController!.popViewController(animated: true)
        }
    }

}
