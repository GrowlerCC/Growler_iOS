//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class SearchTagCell: UICollectionViewCell {

    @IBOutlet weak var button: UIButton!

    var tagName: String = ""
    
    @IBAction func didTapButton(_ sender: Any) {
        print("\(tagName)\n")
    }
}
