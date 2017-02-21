//
// Created by Alexander Gorbovets on 2017-02-21.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(_ colorCode: Int) {
        self.init(
            red: CGFloat(colorCode >> 16) / 255.0,
            green: CGFloat((colorCode >> 8) & 0xFF) / 255.0,
            blue: CGFloat(colorCode & 0xFF) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }

    func colorCode() -> Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: nil) {
            let redInt: Int = Int(red * 255)
            let greenInt: Int = Int(green * 255)
            let blueInt: Int = Int(blue * 255)
            return (redInt << 16) | (greenInt << 8) | blueInt
        }
        return 0
    }

}
