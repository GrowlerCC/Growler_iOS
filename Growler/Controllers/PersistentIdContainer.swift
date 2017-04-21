//
// Created by Jeff H. on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class PersistentIdContainer: NSObject {

    private let defaultsKey: String

    private let changeNotification: Notification.Name

    private let unique: Bool

    init(defaultsKey: String, unique: Bool, changeNotification: Notification.Name) {
        self.defaultsKey = defaultsKey
        self.changeNotification = changeNotification
        self.unique = unique
    }

    func getAll() -> [Int64] {
        let rawIds = UserDefaults.standard.string(forKey: defaultsKey) ?? ""
        let list = rawIds._split(separator: ",").map { Int64($0) ?? 0 }
        return [Int64](list)
    }

    private func save(_ ids: [Int64]) {
        let rawIds = ids.map{ String($0) }.joined(separator: ",")
        UserDefaults.standard.set(rawIds, forKey: defaultsKey)
    }

    func contains(_ id: Int64) -> Bool {
        let ids = getAll()
        return ids.contains(id)
    }

    func add(_ id: Int64) {
        var ids = getAll()
        if !ids.contains(id) || !unique {
            ids.append(id)
        }
        save(ids)
        changeNotification.send()
    }
    
    func remove(at: Int) {
        var ids = getAll()
        ids.remove(at: at)
        save(ids)
        changeNotification.send()
    }

    func removeAll(equalTo value: Int64) {
        let ids = getAll().filter{ $0 != value }
        save(ids)
        changeNotification.send()
    }

    func removeAll() {
        save([Int64]())
        changeNotification.send()
    }

    @objc
    func toggle(_ id: Int64) {
        if contains(id) {
            removeAll(equalTo: id)
        } else {
            add(id)
        }
    }

}
