//
//  MyPagerTabStripName.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/06/01.
//

import XLPagerTabStrip

//現在tabにあるviewc ToDo:0, WantTo:1, List:2
var nowVC :Int = 0

class TabMenuViewController: ButtonBarPagerTabStripViewController {
    
    var genre: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isScrollEnabled = false
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.buttonBarItemTitleColor = UIColor.black
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = genre
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightAddButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // sortButton
        let rightSortButton = UIBarButtonItem(title: "並び替え", style: .done, target: self, action: #selector(tappedNavRightBarSortButton))
        navigationItem.rightBarButtonItem = rightSortButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [rightAddButton,  rightSortButton]
        
    }
    
    @objc private func tappedNavRightBarButton(_ sender: Any) {
        
        // ToDoの画面における＋の処理
        if(nowVC == 0){
            let storyboard: UIStoryboard = UIStoryboard(name: "NewTitle", bundle: nil)//遷移先のStoryboardを設定
            let nextView = storyboard.instantiateViewController(withIdentifier: "NewTitleViewController") as! NewTitleViewController//遷移先のViewControllerを設定
            
            nextView.genre = genre
            
            self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        }
        
        // wantToにおける+の処理
        if (nowVC == 1) {
            let storyboard: UIStoryboard = UIStoryboard(name: "NewTitle2", bundle: nil)//遷移先のStoryboardを設定
            let nextView = storyboard.instantiateViewController(withIdentifier: "NewTitle2ViewController") as! NewTitle2ViewController//遷移先のViewControllerを設定
            
            nextView.genre = genre
            
            self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        }
        
        // Listにおける＋の処理
        if(nowVC == 2){
            let storyboard: UIStoryboard = UIStoryboard(name: "NewFavorites", bundle: nil)//遷移先のStoryboardを設定
            let nextView = storyboard.instantiateViewController(withIdentifier: "NewFavoritesViewController") as! NewFavoritesViewController//遷移先のViewControllerを設定
            
            nextView.genre = genre
            self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        }
    }
    
    @objc private func tappedNavRightBarSortButton(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SortMenu", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "SortMenuViewController") as! SortMenuViewController//遷移先のViewControllerを設定
        
        nextView.genre = genre
        
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
        
    }
    
    //ここでタブに表示するviewの設定
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        //to controller of toDoList
        let storyboard: UIStoryboard = UIStoryboard(name: "TitleList", bundle: nil)//遷移先のStoryboardを設定
        let toDoListView = storyboard.instantiateViewController(withIdentifier: "TitleListViewController") as! TitleListViewController//遷移先のViewControllerを設定
        
        toDoListView.genre = genre
        
        //want to
        let wantToView = UIStoryboard(name: "TabMenu", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        wantToView.genre = genre
        
        //まとめリスト
        let storyboard3: UIStoryboard = UIStoryboard(name: "TabMenu", bundle: nil)
        let listView = storyboard3.instantiateViewController(withIdentifier: "FavoritesListViewController") as! FavoritesListViewController
        
        listView.genre = genre
        
        let childViewControllers:[UIViewController] = [toDoListView, wantToView, listView]
    
        return childViewControllers
    }
}
