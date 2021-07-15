//
//  toDoList.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/26.
//

import UIKit
import RealmSwift
import Cosmos
import XLPagerTabStrip

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var toDoListTableView: UITableView!
    //前の画面から受け取るジャンル名を入れるはこ
    var genre = ""
    
    var indexPathList: [IndexPath]?
    var selectedFavoretesList = FavoritesListItem()
    
    let titleItem = try! Realm()
    var titleItemList: Results<TitleItem>!
    var selectEnableTitleList: Results<TitleItem>!
    // oお気に入りに入ってるアイテムたち
    var addfavoritesListItem: Results<AddFavoritesListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoListTableView.dataSource = self
        toDoListTableView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        // 複数選択を有効にする
        toDoListTableView.allowsMultipleSelectionDuringEditing = true
        
        titleItemList = titleItem.objects(TitleItem.self).filter("genre == %@ AND tab = 'toDo'", genre)
        
        //すでに追加済みは表示しない
        addfavoritesListItem = titleItem.objects(AddFavoritesListItem.self).filter("genre == %@ AND favoritesListName == %@", selectedFavoretesList.genre, selectedFavoretesList.favoritesListName)
        
        /*
        var count = 0
        var flag = 0 // 1ならすでに登録されている
        
        for i in 0..<titleItemList.count{
            for j in 0..<addfavoritesListItem.count {
                if titleItemList[i].title == addfavoritesListItem[j].title{
                    flag = 1
                }
            }
            if flag == 1 {
                selectEnableTitleList[count] = titleItemList[i]
            
        }
        */
        tableSort()
        isEditing = true
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        toDoListTableView.isEditing = editing
        if editing {
            // 編集開始
        } else {
            if indexPathList != nil{
                // 選択したアイテムをリストに追加
                for indexPaths in indexPathList! {
                    let select = titleItemList[indexPaths.row]
                    let temp = AddFavoritesListItem()
                    temp.genre = select.genre
                    temp.favoritesListName = selectedFavoretesList.favoritesListName
                    temp.title = select.title
                    
                    try! titleItem.write {
                        titleItem.add(temp)
                    }
                }
                
                //listの初期化
                indexPathList = nil
            }
            //一個前の画面に遷移
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select - \(indexPath)")
        
        indexPathList = toDoListTableView.indexPathsForSelectedRows
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect - \(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var flag = 0 // 1ならすでに登録されている
        
        for j in 0..<addfavoritesListItem.count {
            if titleItemList[indexPath.row].title == addfavoritesListItem[j].title{
                flag = 1
            }
        }
        if flag == 1 {
            return 0 // 存在すれば高さをゼロにして実質非表示
        } else {
            return 100 // 存在しなければそのまま高さ100で表示
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cell is how
        return titleItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = toDoListTableView.dequeueReusableCell(withIdentifier: "cellid") as!  ToDoListTableViewCell
        
        let temp = titleItemList[indexPath.row]
        
        //チェックマーク
        for i in 0..<titleItemList.count{
            for j in 0..<addfavoritesListItem.count {
                if titleItemList[i].title == addfavoritesListItem[j].title{
                    cell.accessoryType = .checkmark
                }
            }
        }
        
        cell.titleName.text = temp.title
        cell.review.settings.fillMode = .half
        cell.review.rating = Double(temp.review)
        
        //日付
        //データベースから日付を取得
        let date = temp.addDay
        
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
                
        //日付をStringに変換する
        let sDate = format.string(from: date)
        
        cell.addDate.text! = sDate
        
        //画像を取得
        
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imageFileName = genre + temp.title + ".png"
        documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
        
        if let image = UIImage(contentsOfFile: documentDirectoryFileURL.path){
            let image = UIImageView(image: image)
            cell.addImageView.image = image.image
            
            cell.addImageView.contentMode = .scaleAspectFit
            cell.addImageView.clipsToBounds = true
            cell.addImageView.layer.cornerRadius = 15
        }else{
            let image = UIImage(named: "notImage")
            cell.addImageView.image = image
            
            cell.addImageView.contentMode = .scaleAspectFit
            cell.addImageView.clipsToBounds = true
            cell.addImageView.layer.cornerRadius = 15
        }
        
        
        return cell
    }
    
    //sort func
    func tableSort() {
        //sortの種類を取得
        let realm = try! Realm()
        let resutls = realm.objects(ContentItem.self).filter("content == %@", genre)
        let snum = resutls[0].toDoSortNumber
        
        if snum == 0 {
            titleItemList = titleItemList.sorted(byKeyPath: "addDay")
        } else if snum == 1{
            titleItemList = titleItemList.sorted(byKeyPath: "furi")
        } else if snum == 2 {
            titleItemList = titleItemList.sorted(byKeyPath: "furi")
            titleItemList = titleItemList.sorted(byKeyPath: "review", ascending: false)
        }
    }
}

class ToDoListTableViewCell: UITableViewCell{
    
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var addImageView: UIImageView!
    
    @IBOutlet weak var addDate: UILabel!
    @IBOutlet weak var review: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
