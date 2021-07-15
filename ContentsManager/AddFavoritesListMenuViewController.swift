//
//  AddFavoritesListMenu.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/13.
//


import UIKit
import RealmSwift

class AddFavoritesListMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var addFavoritesListMenuTableView: UITableView!
    
    var genre = ""
    var titleName = ""
    
    let realm = try! Realm()
    var favoritesListItemList: Results<FavoritesListItem>!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        addFavoritesListMenuTableView.dataSource = self
        addFavoritesListMenuTableView.delegate = self
        
        favoritesListItemList = realm.objects(FavoritesListItem.self).filter("genre == %@", genre)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cell is how
        return favoritesListItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = addFavoritesListMenuTableView.dequeueReusableCell(withIdentifier: "cell") as! AddFavoritesListMenuTableViewCell
        
        let temp = favoritesListItemList[indexPath.row]
        cell.favoritesName.text = temp.favoritesListName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tempname = favoritesListItemList[indexPath.row].favoritesListName
        
        // リストに追加
        let newItem = AddFavoritesListItem()
        newItem.genre = genre
        newItem.title = titleName
        newItem.favoritesListName = tempname
        
        try! realm.write {
            realm.add(newItem)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}


class AddFavoritesListMenuTableViewCell: UITableViewCell{
    
    @IBOutlet weak var favoritesName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super .setSelected(selected, animated: animated)
    }
}

