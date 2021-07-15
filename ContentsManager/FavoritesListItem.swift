//
//  FavoritesListItem.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/13.
//

import RealmSwift
import UIKit

class FavoritesListItem: Object {
    @objc dynamic var favoritesListName: String = ""
    @objc dynamic var genre: String = ""
    @objc dynamic var sortNum: Int = 0
}
