//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

extension Notification.Name {

    static let favoritesChanged = Notification.Name("favoritesChanged")
    
    static let cartChanged = Notification.Name("cartChanged")

    func send() {
        NotificationCenter.default.post(name: self, object: nil)
    }
    
}

protocol Notifiable {
}

extension Notifiable {
    
    func subscribeTo(_ notification: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(
                self,
                selector: selector,
                name: notification,
                object: nil
            )
    }

    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}
