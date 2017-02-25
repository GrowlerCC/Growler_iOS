//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class SearchTagCell: UICollectionViewCell {

    @IBOutlet weak var button: UIButton!

    var tagName: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.cornerRadius = 16.5
        button.layer.borderColor = Colors.grayControlBorderColor.cgColor
        button.layer.borderWidth = 1
    }

    @IBAction func didTapButton(_ sender: Any) {
        button.isSelected = !button.isSelected
        button.backgroundColor = button.isSelected ? Colors.launchScreenOrangeColor : UIColor.white
    }
}
