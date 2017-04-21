//
// Created by Jeff H. on 2017-02-26.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class FormTableCell: UITableViewCell {

    private(set) var inputs: [FormInput] = []

    static func create(_ input: FormInput) -> UITableViewCell {
        return create(inputs: [input])
    }

    static func create(inputs: [FormInput]) -> UITableViewCell {
        let cell = FormTableCell()
        cell.inputs = inputs
        for input in inputs {
            cell.contentView.addSubview(input)
        }
        cell.createConstraintsForInputs()
        return cell
    }

    func createConstraintsForInputs() {
        for input in inputs {
            input.translatesAutoresizingMaskIntoConstraints = false
        }

        var allConstraints = [NSLayoutConstraint]()

        // vertical constraints
        for input in inputs {
            allConstraints += NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[input]-0-|",
                options: [],
                metrics: nil,
                views: ["input": input]
            )
        }

        // horizontal constraints
        var horizontalViewsMap = [String: UIView]()
        for (index, input) in inputs.enumerated() {
            horizontalViewsMap["input\(index)"] = input
        }
        let horizontalViewFormat = inputs.indices.map { return "[input\($0)]" }.joined(separator: "-0-")
        allConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-\(horizontalViewFormat)-0-|",
            options: [],
            metrics: nil,
            views: horizontalViewsMap
        )

        NSLayoutConstraint.activate(allConstraints)
        contentView.layoutIfNeeded()
    }

}
