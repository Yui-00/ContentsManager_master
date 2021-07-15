//
//  FavoritesTitleListViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/17.
//

import XLPagerTabStrip
import UIKit
import RealmSwift
import Cosmos

class FavoritesTitleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var favoritesTitleListTableView: UITableView!
    
    // お気に入りリストを受け取る
    var selectedFavoritesList = FavoritesListItem()
    
    // genreのtitleItemListを入れる箱
    let realm = try! Realm()
    var titleItemList: Results<TitleItem>!
    
    // oお気に入りに入ってるアイテムたち
    var addfavoritesListItem: Results<AddFavoritesListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTitleListTableView.dataSource = self
        favoritesTitleListTableView.delegate = self
        
        titleItemList = realm.objects(TitleItem.self).filter("genre == %@", selectedFavoritesList.genre)
        addfavoritesListItem = realm.objects(AddFavoritesListItem.self).filter("genre == %@ AND favoritesListName == %@", selectedFavoritesList.genre, selectedFavoritesList.favoritesListName)
        
        navigationItem.title = selectedFavoritesList.favoritesListName
        
        // 追加ボタン
        let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightAddButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // sortButton
        let rightSortButton = UIBarButtonItem(title: "並び替え", style: .done, target: self, action: #selector(tappedNavRightBarSortButton))
        navigationItem.rightBarButtonItem = rightSortButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [rightAddButton, rightSortButton]
    }
    
    //追加アクション
    @objc private func tappedNavRightBarButton(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "ToDoList", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "ToDoListViewController") as! ToDoListViewController//遷移先のViewControllerを設定
        
        nextView.genre = selectedFavoritesList.genre
        nextView.selectedFavoretesList = selectedFavoritesList
        
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
       
    }
    
    @objc private func tappedNavRightBarSortButton(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SortMenu", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "SortMenuViewController") as! SortMenuViewController//遷移先のViewControllerを設定
        
        nextView.genre = selectedFavoritesList.genre
        
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addfavoritesListItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTitleListTableView.dequeueReusableCell(withIdentifier: "cell") as! FavoritesTitleListTableViewCell
        
        let temp = addfavoritesListItem[indexPath.row]
        let item = titleItemList.filter("title == %@", temp.title)[0]
        
        // title set
        cell.titleName.text = item.title
        
        // review set
        cell.review.settings.fillMode = .half
        cell.review.rating = Double(item.review)
        
        // date set
        let date = item.addDay
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let sDate = format.string(from: date)
        cell.addDay.text = sDate
        
        // set image
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageFileName = item.genre + temp.title + ".png"
        documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
        
        if let image = UIImage(contentsOfFile: documentDirectoryFileURL.path){
            let image = UIImageView(image: image)
            cell.titleImage.image = image.image
            cell.titleImage.contentMode = .scaleAspectFit
            cell.titleImage.clipsToBounds = true
            cell.titleImage.layer.cornerRadius = 15
        }else{
            let image = UIImage(named: "notImage")
            cell.titleImage.image = image
            cell.titleImage.contentMode = .scaleAspectFit
            cell.titleImage.clipsToBounds = true
            cell.titleImage.layer.cornerRadius = 15
        }
        return cell
    }
    
    //スワイプ時呼び出し
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        let temp = addfavoritesListItem[indexPath.row]
        //お気に入りリストから選択したアイテムを削除する
        let deleteAction = UIContextualAction(style: .destructive,title: "削除"){(action, view, completionHandler) in
            
            try! self.realm.write {
                self.realm.delete(temp)
            }
        
            self.favoritesTitleListTableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //現在のVCの値をセット
        nowVC = 3
        self.favoritesTitleListTableView.reloadData()
    }
    
}

class FavoritesTitleListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var titleName: UILabel!
    
    @IBOutlet weak var addDay: UILabel!
    @IBOutlet weak var review: CosmosView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

