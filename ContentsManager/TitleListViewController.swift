//
//  TitleListViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/07.
//

import UIKit
import RealmSwift
import Cosmos
import XLPagerTabStrip

class TitleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "To do"

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //ここで
    
    @IBOutlet weak var titleListTableView: UITableView!
    private let cellid = "cellid"

    //前の画面から受け取るジャンル名を入れるはこ
    var genre = ""
    
    let titleItem = try! Realm()
    var titleItemList: Results<TitleItem>!
    
    // 長押しのメニュー
    func makeContextMenu(name: String, genre: String) -> UIMenu {
        let addFavorite = UIAction(title: "お気に入りに追加", image: nil) { action in
            
            // favoritesMenu選択の画面へゴー
            let storyboard: UIStoryboard = UIStoryboard(name: "AddFavoritesListMenu", bundle: nil)//遷移先のStoryboardを設定
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddFavoritesListMenuViewController") as! AddFavoritesListMenuViewController//遷移先のViewControllerを設定
            
            nextView.genre = genre
            nextView.titleName = name
        
            self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        }
        let deleat = UIAction(title: "削除"){ action in
            print("削除しました")
        }
        
        return UIMenu(title: "Menu", children: [addFavorite, deleat])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleListTableView.dataSource = self
        titleListTableView.delegate = self
        
        titleItemList = titleItem.objects(TitleItem.self).filter("genre == %@ AND tab = 'toDo'", genre)
        
        tableSort()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cell is how
        return titleItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = titleListTableView.dequeueReusableCell(withIdentifier: cellid) as! TitleListTableViewCell
        
        let temp = titleItemList[indexPath.row]
        
        cell.titleName.text = temp.title
        cell.review.settings.fillMode = .half
        cell.review.rating = Double(temp.review)
        // touchで値更新不可とする
        cell.review.settings.updateOnTouch = false
        
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
    
    //長押し検知
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
                let temp = self.titleItemList[indexPath.row]
                return self.makeContextMenu(name: temp.title, genre: temp.genre)
            }
        )
    }
    
    //スワイプ時呼び出し
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        let temp = self.titleItemList[indexPath.row]
        
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imageFileName = genre + temp.title + ".png"
        documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
        
        let deleteAction = UIContextualAction(style: .destructive,title: "削除"){(action, view, completionHandler) in
            
            //ファイルの削除
            try? FileManager.default.removeItem(atPath: documentDirectoryFileURL.path)
            //お気に入りから削除するアイテムを削除(genre AND title)
            let addedItem = self.titleItem.objects(AddFavoritesListItem.self).filter("title == %@ AND genre == %@", temp.title, temp.genre)
            try! self.titleItem.write {
                self.titleItem.delete(addedItem)
            }
            
            // アイテムを削除
            try! self.titleItem.write {
                self.titleItem.delete(self.titleItemList[indexPath.row])
            }
            
            self.titleListTableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //select時呼び出し
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectTitle = titleItemList[indexPath.row]
        
        
        let storyboard: UIStoryboard = UIStoryboard(name: "NewTitle", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "NewTitleViewController") as! NewTitleViewController//遷移先のViewControllerを設定
        
        nextView.genre = genre
        nextView.existingItem = selectTitle
    
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    /// 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableSort()
        self.titleListTableView.reloadData()
        nowVC = 0
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

class TitleListTableViewCell: UITableViewCell{
    
    @IBOutlet weak var titleName: UILabel!
    
    @IBOutlet weak var addDate: UILabel!
    
    @IBOutlet weak var addImageView: UIImageView!
    
    @IBOutlet weak var review: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tapCellButton(_ sender: UIButton) {
        print("hello")
    }
    
}


