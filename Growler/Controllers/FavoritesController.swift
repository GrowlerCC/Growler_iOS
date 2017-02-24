//
// Created by Alexander Gorbovets on 2017-02-24.
// Copyright (c) 2017 growler. All rights reserved.
//

import Foundation

@objc
class FavoritesController: NSObject {

    private static let FAVORITE_IDS_DEFAULTS_KEY = "FAVORITE_IDENTIFIERS"

    class func getFavoriteIds() -> Set<Int64> {
        let rawFavoriteIds = UserDefaults.standard.string(forKey: FAVORITE_IDS_DEFAULTS_KEY) ?? ""
        return Utils.stringToIdentifiers(rawFavoriteIds)
    }

    private class func setFavoriteIds(ids: Set<Int64>) {
        let rawFavoriteIds = Utils.identifiersToString(ids)
        UserDefaults.standard.set(rawFavoriteIds, forKey: FavoritesController.FAVORITE_IDS_DEFAULTS_KEY)
    }

    class func isFavoriteProduct(productId: Int64) -> Bool {
        let favoriteIds = getFavoriteIds()
        return favoriteIds.contains(productId)
    }

    class func toggleFavorite(productId: Int64) {
        var favoriteIds = getFavoriteIds()
        if favoriteIds.contains(productId) {
            favoriteIds.remove(productId)
        } else {
            favoriteIds.insert(productId)
        }
        setFavoriteIds(ids: favoriteIds)
    }

}
