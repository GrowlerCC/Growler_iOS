//
// Created by Alexander Gorbovets on 2017-02-23.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

protocol AbstractBannerFactory {

    func getBannerCount() -> Int

    func getBannerForIndex(_ index: Int, owner: AnyObject) -> UIView

}
