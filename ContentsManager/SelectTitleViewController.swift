//
//  selectTitle.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/27.
//

import UIKit
import RealmSwift
import Cosmos

class SelectTitleViewController: UIViewController{
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var review: CosmosView!
    @IBOutlet weak var memoText: UITextView!
    
    var selectItem :TitleItem = TitleItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = selectItem.title
        
        //画像の貼り付け
        // ドキュメントディレクトリの「ファイルURL」（URL型）定義
        var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imageFileName = selectItem.genre + selectItem.title + ".png"
        documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
        
        if let imageData = UIImage(contentsOfFile: documentDirectoryFileURL.path){
            let imageData = UIImageView(image: imageData)
            image.image = imageData.image
        }
        
        //review貼り付け
        review.settings.fillMode = .half
        review.rating = Double(selectItem.review)
        
        //memo貼り付け
        memoText.text = selectItem.memo
        print(selectItem.memo)
    }
}
