//
//  SortMenuViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/29.
//

import UIKit
import RealmSwift

class SortMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var sortMenuTableView: UITableView!
    let sortList0 = ["追加順", "タイトル順", "レビュー順"]
    let sortList1 = ["追加順", "タイトル順"]
    let sortList2 = ["追加順", "タイトル順", "コンテンツ数順"]
    
    var genre = ""
    var nowSortNum :Int = 0
    
    let realmInstance = try! Realm()
    
    // お気に入りリストを受け取る
    var selectedFavoritesList = FavoritesListItem()
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        if nowVC == 0 {
            navigationItem.title = "ToDo 並び順"
        }
        
        if nowVC == 1 {
            navigationItem.title = "WantTo 並び順"
        }
        
        if nowVC == 2 {
            navigationItem.title = "List 並び順"
        }
        
        sortMenuTableView.dataSource = self
        sortMenuTableView.delegate = self
        
        sortMenuTableView.tableFooterView = UIView()
        
        //sortの種類を取得
        let realm = try! Realm()
        let resutls = realm.objects(ContentItem.self).filter("content == %@", genre)
        
        //todo
        if nowVC == 0 {
            nowSortNum = resutls[0].toDoSortNumber
        }
        
        // wantto
        if nowVC == 1 {
            nowSortNum = resutls[0].wantToSortNumber
        }
        
        // list
        if nowVC == 2 {
            nowSortNum = resutls[0].listSortNumber
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cell is how
        if nowVC == 0 || nowVC == 3 {
            return sortList0.count
        }
        if nowVC == 1 {
            return sortList1.count
        }
        if nowVC == 2 {
            return sortList2.count
        } else {
            return sortList0.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = sortMenuTableView.dequeueReusableCell(withIdentifier: "sortCell") as! SortMenuTableViewCell
        
        if nowVC == 0 || nowVC == 3 {
            cell.sortName.text = sortList0[indexPath.row]
        }
        if nowVC == 1 {
            cell.sortName.text = sortList1[indexPath.row]
        }
        if nowVC == 2 {
            cell.sortName.text = sortList2[indexPath.row]
        }
        
        if indexPath.row == nowSortNum{
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        let resutls = realm.objects(ContentItem.self).filter("content == %@", genre)
        
        if nowVC == 0 {
            try! realm.write {
                resutls[0].toDoSortNumber = indexPath.row
            }
        }
        
        if nowVC == 1 {
            try! realm.write {
                resutls[0].wantToSortNumber = indexPath.row
            }
        }
        
        if nowVC == 2 {
            try! realm.write {
                resutls[0].listSortNumber = indexPath.row
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}


class SortMenuTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var sortName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super .setSelected(selected, animated: animated)
    }
    
    
}

