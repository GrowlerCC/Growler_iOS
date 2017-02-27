//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class PersistentIdSet: NSObject {

    let defaultsKey: String

    let changeNotification: Notification.Name

    init(defaultsKey: String, changeNotification: Notification.Name) {
        self.defaultsKey = defaultsKey
        self.changeNotification = changeNotification
    }

    func getAll() -> Set<Int64> {
        let rawIds = UserDefaults.standard.string(forKey: defaultsKey) ?? ""
        let list = rawIds._split(separator: ",").map { Int64($0) ?? 0 }
        return Set<Int64>(list)
    }

    private func save(_ ids: Set<Int64>) {
        let rawIds = ids.map{ String($0) }.joined(separator: ",")
        UserDefaults.standard.set(rawIds, forKey: defaultsKey)
    }

    func contains(_ id: Int64) -> Bool {
        let ids = getAll()
        return ids.contains(id)
    }

    func add(_ id: Int64) {
        var ids = getAll()
        ids.insert(id)
        save(ids)
        changeNotification.send()
    }
    
    func remove(_ id: Int64) {
        var ids = getAll()
        ids.remove(id)
        save(ids)
        changeNotification.send()
    }

    func removeAll() {
        save(Set<Int64>())
        changeNotification.send()
    }

    @objc
    func toggle(_ id: Int64) {
        var ids = getAll()
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        save(ids)
        changeNotification.send()
    }

}
