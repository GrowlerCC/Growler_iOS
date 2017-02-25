//
// Created by Alexander Gorbovets on 2017-02-25.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

class PersistentString {

    let defaultsKey: String

    let changeNotification: Notification.Name

    init(defaultsKey: String, changeNotification: Notification.Name) {
        self.defaultsKey = defaultsKey
        self.changeNotification = changeNotification
    }

    var value: String {
        get {
            return UserDefaults.standard.string(forKey: defaultsKey) ?? ""
        }

        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: defaultsKey)
            changeNotification.send()
        }
    }

}
