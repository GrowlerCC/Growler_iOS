//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var keywordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        keywordField.layer.cornerRadius = 16.5
        keywordField.layer.borderColor = Colors.grayControlBorderColor.cgColor
        keywordField.layer.borderWidth = 1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keywordField.becomeFirstResponder()
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
