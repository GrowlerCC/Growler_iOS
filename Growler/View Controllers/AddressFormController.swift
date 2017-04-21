//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

// todo rename to ProfileViewController
class AddressFormController: FormTableViewController, MKLocalSearchCompleterDelegate {

    private var autoCompleteMode = false

    let cellIndexOfFirstSearchResult = 6

    let cellIndexOfFirstPureSearchResult = 8 // index of first cell which is not used as form cell but only as search result

    let totalCountOfCells = 30

    var searchCompleter: MKLocalSearchCompleter!

    var addressSearchResults = [MKLocalSearchCompletion]()

    var addressInput: FormInput!
    var cityInput: FormInput!
    var stateInput: FormInput!
    var zipInput: FormInput!

    override func getCells() -> [UITableViewCell] {
        let profileHeaderCell = UITableViewCell()
        profileHeaderCell.textLabel?.text = "PROFILE"
        profileHeaderCell.textLabel?.textColor = Colors.grayText
        profileHeaderCell.backgroundColor = Colors.grayBackground

        let addressHeaderCell = UITableViewCell()
        addressHeaderCell.textLabel?.text = "ADDRESS"
        addressHeaderCell.textLabel?.textColor = Colors.grayText
        addressHeaderCell.backgroundColor = Colors.grayBackground


        addressInput = FormInput.create(title: "Address", name: AddressFields.address1.rawValue, required: true)
        addressInput.field.addTarget(self, action: #selector(addressFieldDidChange(textField:)), for: .editingChanged)
        addressInput.field.addTarget(self, action: #selector(addressFieldEditingDidEnd(textField:)), for: .editingDidEnd)

        cityInput = FormInput.create(title: "City", name: AddressFields.city.rawValue, required: true)
        stateInput = FormInput.create(title: "State", name: AddressFields.provinceCode.rawValue, required: false, default: "MN", inputWidth: 40)
        zipInput = FormInput.create(title: "Zip", name: AddressFields.zip.rawValue, required: true, inputWidth: 80)

        var cells = [
            profileHeaderCell,

            FormTableCell.create(inputs: [
                FormInput.create(title: "Name", name: AddressFields.firstName.rawValue, required: true),
                FormInput.create(title: "", name: AddressFields.lastName.rawValue, required: true, inputWidth: 100)
            ]),
            FormTableCell.create(FormInput.create(
                title: "Email",
                name: AddressFields.email.rawValue,
                required: true,
                type: .email)),
            FormTableCell.create(FormInput.create(title: "Phone", name: AddressFields.phone.rawValue, required: true)),

            addressHeaderCell,

            FormTableCell.create(addressInput),
            FormTableCell.create(FormInput.create(title: "Optional Company or Apt. Number", name: AddressFields.company.rawValue, required: false)),
            FormTableCell.create(inputs: [cityInput, stateInput, zipInput]),
        ]

        // adding cells which will be used only for address autocompletion
        for i in cellIndexOfFirstSearchResult ..< totalCountOfCells {
            let cell = UITableViewCell()
            cell.backgroundColor = Colors.grayBackground
            cells.append(cell)
        }
        return cells
    }

    func addressFieldDidChange(textField: UITextField) {
        autoCompleteMode = true
        searchCompleter.queryFragment = textField.text ?? ""
        mq { self.reloadSearchResults() }
    }

    func addressFieldEditingDidEnd(textField: UITextField) {
// IF YOU WILL UNCOMMENT IT, THEN FORM FIELD MAY DISAPPEAR SUDDENLY       autoCompleteMode = false
// IF YOU WILL UNCOMMENT IT, THEN FORM FIELD MAY DISAPPEAR SUDDENLY       mq { self.reloadSearchResults() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self

        onSave = {
            self.navigationController?.dismiss(animated: true)
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        addressSearchResults = completer.results
        reloadSearchResults()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // todo handle error
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Profile"
    }

    override func saveData(_ data: JSON) -> Bool {
        let rawString = data.rawString(.utf8 )
        ShopifyController.instance.addressJsonString.value = rawString ?? "{}"
        return true
    }

    override func loadData() -> JSON {
        let value = ShopifyController.instance.addressJsonString.value
        return JSON(data: value.data(using: .utf8)!) // important: don't use JSON(parseString:), it doesn't work!!!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if autoCompleteMode && indexPath.row >= cellIndexOfFirstSearchResult {
            let cell = UITableViewCell()
            let searchResultIndex = indexPath.row - cellIndexOfFirstSearchResult
            guard addressSearchResults.indices ~= searchResultIndex else {
                cell.textLabel?.text = ""
                return cell
            }
            let completion = addressSearchResults[searchResultIndex]
            cell.textLabel?.text = completion.title + " " + completion.subtitle
            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    private func reloadSearchResults() {
        let paths = stride(from: cellIndexOfFirstSearchResult, through: totalCountOfCells - 1, by: 1).map{ IndexPath(row: $0, section: 0) }
        tableView.reloadRows(at: paths, with: .none)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard autoCompleteMode && indexPath.row >= cellIndexOfFirstSearchResult else {
            return super.tableView(tableView, willSelectRowAt: indexPath)
        }
        self.autoCompleteMode = false
        mq { self.reloadSearchResults() }
        let searchResultIndex = indexPath.row - cellIndexOfFirstSearchResult
        guard addressSearchResults.indices ~= searchResultIndex else {
            // this way user can cancel search if there's no search results
            autoCompleteMode = false
            reloadSearchResults()
            return nil
        }
        let completion = addressSearchResults[searchResultIndex]
        addressInput.field.text = completion.title// + " " + completion.subtitle
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start {
            response, error in
            guard let response = response else {
                return
            }
            let placemark: MKPlacemark = response.mapItems[0].placemark
            self.cityInput.field.text = placemark.locality
            self.stateInput.field.text = placemark.administrativeArea
            self.zipInput.field.text = placemark.postalCode
        }
        return nil
    }

}
