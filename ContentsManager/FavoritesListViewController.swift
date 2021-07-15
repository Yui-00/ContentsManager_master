//
//  SecondViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/01.
//

import XLPagerTabStrip
import UIKit
import RealmSwift

class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {

    @IBOutlet weak var favoritesListTableView: UITableView!
    
    var genre: String = ""
    
    let realm = try! Realm()
    var favoritesListItemList: Results<FavoritesListItem>!
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "List"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favoritesListTableView.delegate = self
        self.favoritesListTableView.dataSource = self
        
        //データベースからデータ取得
        favoritesListItemList = realm.objects(FavoritesListItem.self).filter("genre == %@", genre)
        self.favoritesListTableView.reloadData()
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesListItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesListTableView.dequeueReusableCell(withIdentifier: "cell") as! FavoritesListTableViewCell
        
        let temp = favoritesListItemList[indexPath.row]
        cell.favoritesListName.text = temp.favoritesListName
        
        cell.favoritesListImage.image = UIImage(named: "folder")
        
        //item数
        let addedFavoritesItem = realm.objects(AddFavoritesListItem.self).filter("genre == %@ AND favoritesListName == %@", temp.genre, temp.favoritesListName)
        
        cell.itemCount.text = "(" + String(addedFavoritesItem.count) + ")"
        
        return cell
    }
    
    //押された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedFavoretesList = favoritesListItemList[indexPath.row]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "FavoritesTitleList", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "FavoritesTitleListViewController") as! FavoritesTitleListViewController//遷移先のViewControllerを設定
        
        nextView.selectedFavoritesList = selectedFavoretesList
    
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    /// 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //現在のVCの値をセット
        nowVC = 2
        self.favoritesListTableView.reloadData()
    }
    
    //スワイプ時呼び出し
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        let temp = favoritesListItemList[indexPath.row]
        //お気に入りリストとその中身を削除する
        let deleteAction = UIContextualAction(style: .destructive,title: "削除"){(action, view, completionHandler) in
            
            //データベースからデータ取得
            let deleteItemList = self.realm.objects(AddFavoritesListItem.self).filter("genre == %@ AND favoritesListName == %@", temp.genre, temp.favoritesListName)
            //リストに追加されているアイテムを全て削除
            try! self.realm.write {
                self.realm.delete(deleteItemList)
            }
            
            //お気に入りリストの削除
            try! self.realm.write {
                self.realm.delete(temp)
            }
            
            self.favoritesListTableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //sort func
    func tableSort() {
        //sortの種類を取得
        let realm = try! Realm()
        let resutls = realm.objects(FavoritesListItem.self).filter("genre == %@", genre)
        let snum = resutls[0].sortNum
        
        if snum == 0 {
            print("not sort")
        } else if snum == 1{
            print("not sort")
        } else if snum == 2 {
            print("not sort")
        }
    }
    
}

class FavoritesListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoritesListName: UILabel!
    
    @IBOutlet weak var favoritesListImage: UIImageView!
    
    @IBOutlet weak var itemCount: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tapCellButton(_ sender: UIButton) {
        print("hello")
    }
}
