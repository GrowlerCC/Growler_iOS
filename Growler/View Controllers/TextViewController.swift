//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit
import EMString

class TextViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!

    var onViewDidLoad: (() -> Void)?

    var closeButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
        closeButton = UIBarButtonItem(image: UIImage(named: "CloseMenuButton"), style: .plain, target: self, action: #selector(self.didTapCloseButton))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = closeButton
        setupDarkToolbars(bottomBar: false)
    }

    func didTapCloseButton() {
        navigationController?.dismiss(animated: true)
    }

}
