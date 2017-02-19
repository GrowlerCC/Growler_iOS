//
// Created by Alexander Gorbovets on 2017-02-19.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

class ConfirmAddressViewController: UIViewController {

    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var addressFieldContainer: UIView!

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressField.attributedPlaceholder = NSAttributedString(
            string: addressField.placeholder ?? "",
            attributes: [NSForegroundColorAttributeName: UIColor.white]
        )
        addressFieldContainer.layer.cornerRadius = 22
        startButton.layer.cornerRadius = 22

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapRecognizer)
    }

    @IBAction func didTouchSkipButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchStartButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        addressField.resignFirstResponder()
    }

}
