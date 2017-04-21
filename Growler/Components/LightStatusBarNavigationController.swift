//
// Created by Jeff H. on 2017-03-20.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class LightStatusBarNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        setNeedsStatusBarAppearanceUpdate()
    }

}
