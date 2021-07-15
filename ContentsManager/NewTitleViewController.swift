//
//  NewTitleViewController.swift
//  ContentsManager
//
//  Created by 日野原唯人 on 2021/05/22.
//

import UIKit
import RealmSwift
import Cosmos
import AssetsLibrary

class NewTitleViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate ,UITextViewDelegate {
    
    // Realmのインスタンスを取得
    let titleItem = try! Realm()
    //編集ように既存のアイテムを入れる
    var existingItem: TitleItem! = nil
    
    //前画面からジャンル名を受け取る
    var genre = ""
    var str = ""
    
    var imageData: Data? = nil
    
    @IBOutlet weak var titleName: UITextField!
    @IBOutlet weak var review: CosmosView!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Screenの高さ
    var screenHeight:CGFloat!
    // Screenの幅
    var screenWidth:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //******************
        scrollView.delegate = self
        memo.delegate = self
        
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // 表示窓のサイズと位置を設定
        scrollView.frame.size =
            CGSize(width: screenWidth, height: screenHeight)
        
        // UIScrollViewに追加
        scrollView.addSubview(titleName)
        scrollView.addSubview(review)
        scrollView.addSubview(memo)
        scrollView.addSubview(addImageButton)
        
        // UIScrollViewの大きさをスクリーンの縦方向を２倍にする
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight*1.2)
        
        // スクロールの跳ね返り無し
        scrollView.bounces = false
        
        // ビューに追加
        self.view.addSubview(scrollView)
        
        //レイアウトデザインの変更
        addImageButton.layer.cornerRadius = 15
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = UIColor.rgb(red: 220, green: 220, blue: 220).cgColor
        memo.layer.borderColor = UIColor.black.cgColor
        
        //navigationの項目
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "追加"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let RightAddButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = RightAddButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        titleName.text = str
        
        //cosmosを半分で使えるように
        review.settings.fillMode = .half
        
        //既存アイテムの場合各フィールドに値をセット
        if existingItem != nil {
            titleName.text = existingItem.title
            
            //画像の貼り付け
            // ドキュメントディレクトリの「ファイルURL」（URL型）定義
            var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageFileName = genre + existingItem.title + ".png"
            documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
            
            if let imageD = UIImage(contentsOfFile: documentDirectoryFileURL.path){
                
                addImageButton.setImage(imageD.withRenderingMode(.alwaysOriginal), for: .normal)
                do{
                    imageData = try Data(contentsOf: documentDirectoryFileURL)
                    //整える
                    addImageButton.imageView?.contentMode = .scaleAspectFit
                    addImageButton.contentHorizontalAlignment = .fill
                    addImageButton.contentVerticalAlignment = .fill
                    addImageButton.clipsToBounds = true
                } catch {
                    print("error")
                }
            }
            
            //review貼り付け
            review.settings.fillMode = .half
            review.rating = Double(existingItem.review)
            
            //memo貼り付け
            memo.text = existingItem.memo
        }
        
    }
    
    // 改行でキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
     
        NotificationCenter.default.addObserver(self,
                selector: #selector(NewTitleViewController.keyboardWillShow(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(NewTitleViewController.keyboardWillHide(_:)) ,
                name: UIResponder.keyboardDidHideNotification,
                object: nil)
     
    }
       
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // bottom of textField
        let bottomTextField = memo.frame.origin.y + memo.frame.height
        // top of keyboard
        let topKeyboard = screenHeight - keyboardFrame.size.height
        // 重なり
        let distance = bottomTextField - topKeyboard
        
        if distance >= 0 {
            // scrollViewのコンテツを上へオフセット + 50.0(追加のオフセット)
            scrollView.contentOffset.y = distance + 50.0
        }
    }
     
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentOffset.y = 0
    }
     
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           NotificationCenter.default.removeObserver(self,
                    name: UIResponder.keyboardWillShowNotification,
                   object: self.view.window)
           NotificationCenter.default.removeObserver(self,
                    name: UIResponder.keyboardDidHideNotification,
                   object: self.view.window)
    }
    
    
    @IBAction func endInputTextField(_ sender: UITextField) {
    }
    
    func setDismissKeyboard() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //ふりがなを取得する関数
    func changeToKatakanaString(str: String) -> String {
        return TextConverter.convert(str, to: .katakana)
    }
    
    @objc private func tappedNavRightBarButton(_ sender: Any) {
        
        //もし既存アイテムの編集なら既存を消して新しく追加
        if existingItem != nil {
            // ドキュメントディレクトリの「ファイルURL」（URL型）定義
            var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageFileName = genre + existingItem.title + ".png"
            documentDirectoryFileURL.appendPathComponent(imageFileName, isDirectory: true)
            
            //ファイルの削除
            try? FileManager.default.removeItem(atPath: documentDirectoryFileURL.path)
            //お気に入りから削除するアイテムを削除
            //let addedItem =
            // アイテムを削除
            try! self.titleItem.write {
                self.titleItem.delete(existingItem)
            }
        }

       
        let name: String = titleName.text!
        
        //重複チェック
        //まず現在選択してるジャンルのリストを取得する
        let list = titleItem.objects(TitleItem.self).filter("genre == %@", genre)
        
        for i in 0..<list.count {
            
            if list[i].title == name{
                print("existance")
                DuplicateAlert()
                return
            }
        }
        
        let newTitle = TitleItem()
        //並び替えのためにルビをつける
        let furi = changeToKatakanaString(str: name)
        
        if let image = addImageButton.imageView?.image {
            //pathにpngで画像を保存
            if let pngImageData = image.pngData() {
                do {
                    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
                    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    // 保存する画像ファイルの名前
                    let fileName = genre + titleName.text! + ".png"
                    
                    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
                    let path = documentDirectoryFileURL.appendingPathComponent(fileName)
                    documentDirectoryFileURL = path
                    
                    try pngImageData.write(to: documentDirectoryFileURL)
                } catch {
                    //エラー処理
                    print("エラー")
                }
            } else {
                do {
                    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
                    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    // 保存する画像ファイルの名前
                    let fileName = genre + titleName.text! + ".png"
                    
                    // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
                    let path = documentDirectoryFileURL.appendingPathComponent(fileName)
                    documentDirectoryFileURL = path
                    //画像は残してファイル名を変更
                    try imageData?.write(to: documentDirectoryFileURL)
                } catch {
                    print("error")
                }
            }
        } else {
            print("not")
        }
        
        //新規レコードに値を付与
        newTitle.genre = genre
        newTitle.title = name
        newTitle.furi = furi
        newTitle.addDay = Date()
        newTitle.review = review.rating
        newTitle.memo = memo.text
        
        //todoなら
        //if (nowVC == 0) {
            newTitle.tab = "toDo"
        //}
        
        //wantToなら
        //if (nowVC == 1) {
        //    newTitle.tab = "wantTo"
        //}
        
        //れるむに追加
        try! titleItem.write {
            titleItem.add(newTitle)
        }
        
        //一個前の画面に遷移
        self.navigationController?.popViewController(animated: true)
    }
    
    func DuplicateAlert(){
        //アラートのスタイル
        let alert: UIAlertController = UIAlertController(title: "重複エラー", message: "そのタイトルはすでに存在しています", preferredStyle:  UIAlertController.Style.alert)
        
        // ボタンのアクションを設定
        let closeAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        //UIAlertControllerにActionを追加
        alert.addAction(closeAction)
        
        //アラートの表示
        present(alert, animated: true, completion: nil)
    }
    
    //アルバムを開く
    @IBAction func tappedAddImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension NewTitleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage{
            addImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage{
            addImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        addImageButton.setTitle("", for: .normal)
        addImageButton.imageView?.contentMode = .scaleAspectFit
        addImageButton.contentHorizontalAlignment = .fill
        addImageButton.contentVerticalAlignment = .fill
        addImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
}

//文字をひらがなかカタカナに変換
final class TextConverter {
    private init() {}
    enum JPCharacter {
        case hiragana
        case katakana
        fileprivate var transform: CFString {
            switch self {
            case .hiragana:
                return kCFStringTransformLatinHiragana
            case .katakana:
                return kCFStringTransformLatinKatakana
            }
        }
    }

    static func convert(_ text: String, to jpCharacter: JPCharacter) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                CFStringTransform(text as! CFMutableString, nil, jpCharacter.transform, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }
}
