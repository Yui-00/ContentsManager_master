//
//  NewFavoritesViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/13.
//

import UIKit
import RealmSwift
import Cosmos
import AssetsLibrary

class NewFavoritesViewController: UIViewController {
    
    var genre :String = ""
    
    @IBOutlet weak var favoritesName: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    @IBAction func addButtonAction(_ sender: Any) {
        // 新規お気に入りリストをデータベースに追加
        let newFavoritesListItem = FavoritesListItem()
        
        // カラムの値を設定
        newFavoritesListItem.genre = genre
        newFavoritesListItem.favoritesListName = favoritesName.text!
        
        let realmInstance = try! Realm()
        try! realmInstance.write {
            realmInstance.add(newFavoritesListItem)
        }
        
        //前画面に戻る
        //一個前の画面に遷移
        self.navigationController?.popViewController(animated: true)
    }
}
