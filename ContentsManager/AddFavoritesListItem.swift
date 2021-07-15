//
//  AddFavoritesListItem.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/13.
//

import RealmSwift
import UIKit

class AddFavoritesListItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var genre: String = ""
    @objc dynamic var favoritesListName: String = ""
}

