//
//  TitleItem.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/10.
//

import UIKit
import RealmSwift

class TitleItem: Object {
    @objc dynamic var genre: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var furi: String = ""
    @objc dynamic var addDay: Date = Date()
    @objc dynamic var review = 4.5
    @objc dynamic var memo: String = ""
    @objc dynamic var tab: String? = ""
}
