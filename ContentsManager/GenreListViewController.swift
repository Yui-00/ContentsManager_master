//
//  GenreListViewControll.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/22.
//

import UIKit
import RealmSwift

class GenreListViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate {

    //@IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var contentList: Results<ContentItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.contentTableView.dataSource = self
        self.contentTableView.delegate = self
        
        let realmInstance = try! Realm()
        
        self.contentList = realmInstance.objects(ContentItem.self)
        self.contentTableView.reloadData()
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "ジャンル"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let RightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = RightAddButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc private func tappedNavRightBarButton(_ sender: Any) {
        showAlertController()
    }
    
    /// 画面再表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentTableView.reloadData()
    }
    
}

extension GenreListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GenreListTableViewCell
        
        let temp = contentList[indexPath.row]
        let genre :String = temp.content!
        cell.genreName.text = genre
        
        //中に入ってるタイトル数を取得
        let realmInstance = try! Realm()
        let titleItemList = realmInstance.objects(TitleItem.self).filter("genre == %@", genre)
        
        let titleCount = titleItemList.count
        
        cell.titleCount.text = "(" + String(titleCount) + ")"
        
        cell.genreImage.image = UIImage(named: "log")
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(title: "本当に削除しますか？", message: "この分類のタイトルはすべて削除されます", preferredStyle: .alert)

                let yes = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
                    
                    let realmInstance = try! Realm()
                    
                    //削除するジャンルのタイトルデータを全て削除する
                    let genre = self.contentList[indexPath.row].content!
                    
                    let deleteTitle = realmInstance.objects(TitleItem.self).filter("genre == %@", genre)
                    
                    try! realmInstance.write {
                        realmInstance.delete(deleteTitle)
                    }
                    
                    try! realmInstance.write {
                        realmInstance.delete(self.contentList[indexPath.row])
                    }
                    
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
                })
                
                let no = UIAlertAction(title: "NO", style: .cancel, handler: { (action) -> Void in
                    print("No button tapped")
                })
                
                alert.addAction(yes);
                alert.addAction(no);
                
                self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let storyboard: UIStoryboard = UIStoryboard(name: "TitleList", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "TitleListViewController") as! TitleListViewController//遷移先のViewControllerを設定
        
        if let genreName = contentList[indexPath.row].content {
            nextView.genre = genreName
        }
        self.navigationController?.pushViewController(nextView, animated: true)//遷移
        */
        let storyboard: UIStoryboard = UIStoryboard(name: "TabMenu", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "TabMenuViewController") as! TabMenuViewController//遷移先のViewControllerを設定
        
        nextView.genre = contentList[indexPath.row].content!
        
        self.navigationController?.pushViewController(nextView, animated: true)//遷移
        
    }
    
    func showAlertController() {
        let alert = UIAlertController(title: "タイトル名", message: "追加したいタイトルを入力してください", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "ここに入力してください"
            })

            let add = UIAlertAction(title: "追加", style: .default, handler: { (action) -> Void in
                
                let instancedContentItem = ContentItem()
                instancedContentItem.content = alert.textFields?[0].text
                let realmInstance = try! Realm()
                try! realmInstance.write {
                    realmInstance.add(instancedContentItem)
                }
                self.contentTableView.reloadData()
            })
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                print("Cancel button tapped")
            })
            
            alert.addAction(add);
            alert.addAction(cancel);
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func updateAlertControllerText(_ alertcontroller: UIAlertController, _ indexPath: IndexPath) {
        
        guard let textFields = alertcontroller.textFields else { return }
        guard let text = textFields[0].text else { return }
        
        print(text)
        
        let realmInstance = try! Realm()
        try! realmInstance.write {
            contentList[indexPath.row].content = text
        }
        self.contentTableView.reloadData()
    }
}

class GenreListTableViewCell: UITableViewCell{
    
    @IBOutlet weak var genreName: UILabel!
    
    @IBOutlet weak var genreImage: UIImageView!
    
    @IBOutlet weak var titleCount: UILabel!
    
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




