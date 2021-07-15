//
//  FirstViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/01.
//

import UIKit
import RealmSwift
import Cosmos
import XLPagerTabStrip

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "Want to"

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //ここで
    
    
    @IBOutlet weak var firstListTableView: UITableView!
    
    
    private let cellid = "cellid"

    //前の画面から受け取るジャンル名を入れるはこ
    var genre = ""
    
    let firstItem = try! Realm()
    var firstItemList: Results<TitleItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstListTableView.dataSource = self
        firstListTableView.delegate = self
        
        firstItemList = firstItem.objects(TitleItem.self).filter("genre == %@ AND tab == 'wantTo'", genre)
        
        tableSort()
        
    }
    
    // 長押しのメニュー
    func makeContextMenu(item: TitleItem) -> UIMenu {
        let addFavorite = UIAction(title: "ToDoに追加", image: nil) { action in
            // データの更新
            try! self.firstItem.write {
                item.tab = "toDo"
            }
            self.firstListTableView.reloadData()
        }
        
        return UIMenu(title: "Menu", children: [addFavorite])
    }
    
    //長押し検知
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let temp = self.firstItemList[indexPath.row]
            return self.makeContextMenu(item: temp)
        })
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cell is how
        return firstItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = firstListTableView.dequeueReusableCell(withIdentifier: cellid) as! FirstListTableViewCell
        
        let temp = firstItemList[indexPath.row]
        
        cell.titleName.text = temp.title
        //cell.review.settings.fillMode = .half
        //cell.review.rating = Double(temp.review)
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        let temp = self.firstItemList[indexPath.row]
        
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imageFileName = genre + temp.title + ".png"
        documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
        
        let deleteAction = UIContextualAction(style: .destructive,title: "削除"){(action, view, completionHandler) in
            
            //ファイルの削除
            try? FileManager.default.removeItem(atPath: documentDirectoryFileURL.path)
            
            
            try! self.firstItem.write {
                self.firstItem.delete(self.firstItemList[indexPath.row])
            }
            
            self.firstListTableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //select時呼び出し
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectTitle = firstItemList[indexPath.row]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "NewTitle2", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "NewTitle2ViewController") as! NewTitle2ViewController//遷移先のViewControllerを設定
        
        nextView.genre = genre
        nextView.existingItem = selectTitle
    
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    /// 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableSort()
        self.firstListTableView.reloadData()
        nowVC = 1
    }
    
    //sort func
    func tableSort() {
        //sortの種類を取得
        let realm = try! Realm()
        let resutls = realm.objects(ContentItem.self).filter("content == %@", genre)
        let snum = resutls[0].wantToSortNumber
        
        if snum == 0 {
            firstItemList = firstItemList.sorted(byKeyPath: "addDay")
        }
        
        if snum == 1 {
            firstItemList = firstItemList.sorted(byKeyPath: "furi")
        } 
    }
    
    
}

class FirstListTableViewCell: UITableViewCell{
    
    
    
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


