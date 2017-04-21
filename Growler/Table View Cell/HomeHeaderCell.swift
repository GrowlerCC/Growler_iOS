//
// Created by Jeff H. on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class HomeHeaderCell: UITableViewCell {

    static func create(title: String) -> HomeHeaderCell {
        let cell = HomeHeaderCell()
        cell.textLabel?.font = UIFont(name: "Lato-Bold", size: 19/*, wight: .bold*/)
        cell.textLabel?.text = title
        return cell
    }

}
