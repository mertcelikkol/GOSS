//
//  ChatViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 8.08.2022.
//

import UIKit
import Firebase
import GoogleMobileAds

class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, GADBannerViewDelegate {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: UIView!
    
    
    
    @IBOutlet weak var mainRepliedView: UIView!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var gonderButton: UIButton!
    
    
    
    @IBOutlet weak var mainCevaplaView: UIView!
    
    // Parametrelerin Tanımlanması
    var repliedAction : Bool = false
    var repliedMessageId : String?
    var chatViewModel : ChatRecyclerAdapter?
    var chatList = [Message]()
    var auth : Auth?
    var firestore : Firestore?
    var storage : Storage?
    var pickedImage : UIImage?
    var currentUserId : String?
    var arananKelime : String = ""
    var guncelKullanici = ViewController.kullanici
    var cevaplananMesajList = [Message]()
    
    var selectedDocumentUrl : String?
    
    var scrollDownButonu : UIButton?
    
    let screenWidth = UIScreen.main.bounds.width * 0.55 / 14
    
    var messageControlList = [String]()
    
    
    
    var bannerView : GADBannerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gunduzMod()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        //tableView.remembersLastFocusedIndexPath = true
        tableView.separatorStyle = .none
        
        backButton.addTarget(self, action: #selector(self.sayfaKapat), for: .allTouchEvents)
        
        /*
         
         1- Mesajları Getir -> Done
            1.1- Cevaplama Konsepti
            1.2- Döküman Konsepti
            1.3- Dökümana Tıklama Olayı
         2- Galeriye Gitme -> Done
         3- Mesajın Gönderilmesi
         4- Cevaplama olayları
         5- Göndermeden Sonra Herşeyin temizlenmesi
         
         */
        // Tıklama Aksiyonlari
        
        self.clickingAction()
        self.getMessages()
        
        
        // Reklam Olayı
        
        
        if let kullanici = ViewController.kullanici {
            print("NEREYE GİRİYOR 1")
            if kullanici.memberType == .gold {
                self.adView.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true
                self.view.updateConstraints()
            } else {
                bannerView = GADBannerView(frame: adView.frame)
                bannerView.rootViewController = self
                addBannerViewToView(bannerView)
            }
        } else {
            print("NEREYE GİRİYOR 2")
            if let guncel = auth?.currentUser {
                print("NEREYE GİRİYOR 3")
               
                getUser(uid: guncel.uid)
            }
            
        }
        
        
        
        messageText.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: self.view.window)
        
 
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .top,
                              relatedBy: .equal,
                              toItem: adView,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: adView,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
        bannerView.adUnitID = "ca-app-pub-6292749914687688/9897219513"
        bannerView.load(GADRequest())
       }
    
    func getUser( uid : String ){
        let database = Database.database()
        let reference = database.reference()
        reference.child("user").child(uid).observeSingleEvent(of: .childChanged) { querySnapshot in
            if let dokuman =  querySnapshot.value as? [String:Any]{
                var memberType : MemberType = .standart
                
                if let tip = dokuman["memberType"] as? String {
                    if tip == "standart" {
                        memberType = .standart
                    } else if (tip == "gold") {
                        memberType = .gold
                    } else if(tip == "premium") {
                        memberType = .premium
                    }
                    
                    if memberType == .gold {
                        self.adView.frame.size.height = 0
                    } else {
                        self.bannerView = GADBannerView(frame: self.adView.frame)
                        self.bannerView.rootViewController = self
                        self.addBannerViewToView(self.bannerView)
                    }
                    
                }
                ViewController.kullanici = Kullanici(uid: uid, userName: dokuman["userName"] as? String ?? "", mail: dokuman["mail"] as? String ?? "", password: dokuman["password"] as? String ?? "", memberType: memberType)
                if memberType == .gold {
                    self.adView.frame.size.height = 0
                } else {
                    
                    self.bannerView = GADBannerView(frame: self.adView.frame)
                    self.bannerView.rootViewController = self
                    self.addBannerViewToView(self.bannerView)
                    
                    
                }
                
            } else {
                
            }
        }
    }
    
    func reklamAyarlari( adView : UIView , type : String = "banner" , kullanici : Kullanici , bannerView : GADBannerView ){
        if kullanici.memberType == .standart {
            if type == "banner" {
                bannerReklamYukle(reklamView: adView, bannerView : bannerView )
            } else {
                
            }
        } else {
            adView.frame.size.height = 0
        }
    }
    
    func bannerReklamYukle( reklamView : UIView , bannerView : GADBannerView  ){
        // Delegate unutma , özellikle video reklamında
        bannerView.adUnitID = "ca-app-pub-6292749914687688/6445889274"
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.frame = reklamView.frame
        bannerView.center = reklamView.center
        reklamView.addSubview(bannerView)
        
    }
     
    func clickingAction(){
        
        galleryButton.isUserInteractionEnabled = true
        let galeryIntent = UITapGestureRecognizer(target: self, action: #selector(galeri))
        galleryButton.addGestureRecognizer(galeryIntent)
        
        gonderButton.isUserInteractionEnabled = true
        let sendMessageGesture = UITapGestureRecognizer(target: self, action: #selector(mesajGonder))
        gonderButton.addGestureRecognizer(sendMessageGesture)
        
    }
    
    @objc func mesajGonder(){
        let message = messageText.text
        if message != "" {
            let userName = guncelKullanici?.userName
            let userUid = auth!.currentUser!.uid
            let sendDate = FieldValue.serverTimestamp()
            
            if let pickedImage = pickedImage {
                // Gönderi Eklenmiş
                if repliedAction {
                    // Gönderi Eklenmiş ve Mesaja Cevap Olarak Gönderilmiş
                    let documentUrl = dosyaYukleme(gorsel: pickedImage)
                    if let repliedMessageId = repliedMessageId {
                        let savedData = [
                            "userName" : userName ?? "Kullanıcı",
                            "userUid" : userUid,
                            "sendDate" : sendDate,
                            "message" : message!,
                            "documentUrl" : documentUrl!,
                            "repliedMessage" : repliedMessageId
                        ] as [String:Any]
                        self.mesajKaydetme(kaydedilecekData: savedData)
                    } else {
                        let savedData = [
                            "userName" : userName ?? "Kullanıcı",
                            "userUid" : userUid,
                            "sendDate" : sendDate,
                            "message" : message!,
                            "documentUrl" : documentUrl!
                        ] as [String:Any]
                        self.mesajKaydetme(kaydedilecekData: savedData)
                    }
                } else {
                    // Gönderi Eklenmiş
                    let documentUrl = dosyaYukleme(gorsel: pickedImage)
                    let savedData = [
                        "userName" : userName ?? "Kullanıcı",
                        "userUid" : userUid,
                        "sendDate" : sendDate,
                        "message" : message!,
                        "documentUrl" : documentUrl!
                    ] as [String:Any]
                    self.mesajKaydetme(kaydedilecekData: savedData)
                }
            } else {
                // Gönderi Eklenmemiş
                if repliedAction {
                    // Cevaplama Var
                    if let repliedMessageId = repliedMessageId {
                        let savedData = [
                            "userName" : userName ?? "Kullanıcı",
                            "userUid" : userUid,
                            "sendDate" : sendDate,
                            "message" : message!,
                            "repliedMessage" : repliedMessageId
                        ] as [String:Any]
                        self.mesajKaydetme(kaydedilecekData: savedData)
                    } else {
                        let savedData = [
                            "userName" : userName ?? "Kullanıcı",
                            "userUid" : userUid,
                            "sendDate" : sendDate,
                            "message" : message!
                        ] as [String:Any]
                        
                        self.mesajKaydetme(kaydedilecekData: savedData)
                    }
                } else {
                    // Cevaplama Yok
                    let savedData = [
                        "userName" : userName ?? "Kullanıcı",
                        "userUid" : userUid,
                        "sendDate" : sendDate,
                        "message" : message!
                    ] as [String:Any]
                    
                    self.mesajKaydetme(kaydedilecekData: savedData)
                }
            }
            // Kaydetme Aksiyonları
            
            
        } else {
            self.alarmVer(baslik: "Hata", mesaj: "Lütfen mesajınızı girin.")
        }
    }
    
    func mesajKaydetme( kaydedilecekData : [String : Any ]){
        if let firestore = firestore {
            firestore.collection("chat").addDocument(data: kaydedilecekData) { error in
                if error == nil {
                    self.messageText.text = ""
                    self.repliedAction = false
                    self.repliedMessageId = nil
                    self.pickedImage = nil
                    
                    self.mainCevaplaView.isHidden = true
                    self.mainCevaplaView.frame.size.height = 0
                } else {
                    if let error = error {
                        self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                    } else {
                        self.alarmVer(baslik: "Hata", mesaj: "İnternet bağlantınızdan emin olun")
                    }
                }
            }
        } else {
            firestore = Firestore.firestore()
            firestore!.collection("chat").addDocument(data: kaydedilecekData) { error in
                if error == nil {
                    self.messageText.text = ""
                    self.repliedAction = false
                    self.repliedMessageId = nil
                    self.pickedImage = nil
                    
                    self.mainCevaplaView.isHidden = true
                    self.mainCevaplaView.frame.size.height = 0
                } else {
                    if let error = error {
                        self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                    } else {
                        self.alarmVer(baslik: "Hata", mesaj: "İnternet bağlantınızdan emin olun")
                    }
                }
            }
        }
    }
    
    func scrollDownButonuYerlestirme(){
        scrollDownButonu = UIButton()
        scrollDownButonu?.imageView?.image = UIImage(systemName: "chevron.down")
        scrollDownButonu?.frame = CGRect(x: 0, y: mainCevaplaView.frame.origin.y + 10, width: 45, height: 45)
        scrollDownButonu?.isUserInteractionEnabled = true
        let scrollTapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollDownAutomatically))
        scrollDownButonu?.addGestureRecognizer(scrollTapGesture)
        scrollDownButonu?.isHidden = true
        
        view.addSubview(scrollDownButonu!)
    }
    
    func dosyaYukleme(gorsel : UIImage) -> String? {
        var documentUrl = ""
        if let data = gorsel.jpegData(compressionQuality: 1) {
            let fileName = "\(UUID().uuidString).jpg"
            if let storage = storage {
                let uploadReference = storage.reference(withPath: "chatDocuments").child(fileName)
                uploadReference.putData(data, metadata: nil) { storageMetaData, error in
                    if error == nil {
                        uploadReference.downloadURL { link, error in
                            if let link = link {
                                documentUrl = link.absoluteString
                                
                            }
                        }
                    } else {
                        if let error = error {
                            self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "Dosyanız yüklenirken bir hata oldu. Daha sonra tekrar deneyin")
                        }
                        
                    }
                }
                return documentUrl
            } else {
                storage = Storage.storage()
                let uploadReference = storage!.reference(withPath: "chatDocuments").child(fileName)
                uploadReference.putData(data, metadata: nil) { storageMetaData, error in
                    if error == nil {
                        uploadReference.downloadURL { link, error in
                            if let link = link {
                                documentUrl = link.absoluteString
                                
                            }
                        }
                    } else {
                        if let error = error {
                            self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "Dosyanız yüklenirken bir hata oldu. Daha sonra tekrar deneyin")
                        }
                        
                    }
                }
                return documentUrl
            }
        }
        
        return documentUrl
        
    }
    
    @objc func galeri(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pickedImage = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func getMessages(){
        DispatchQueue.global().async {
            // Align START
            self.auth = Auth.auth()
            if let guncelKullanici = self.auth?.currentUser {
                self.currentUserId = guncelKullanici.uid
                self.firestore = Firestore.firestore()
                
                self.firestore?.collection("chat").order(by: "sendDate", descending: true).addSnapshotListener({ querySnapshot, error in
                    if error == nil {
                        if let querySnapshot = querySnapshot {
                            self.chatList.removeAll()
                            self.messageControlList.removeAll()
                            self.cevaplananMesajList.removeAll()
                            var loopIndex = 0
                            for dokuman in querySnapshot.documents {
                                
                                var sendedDateObject = Date()
                                if let zaman = dokuman["sendDate"] as? Timestamp {
                                    sendedDateObject = zaman.dateValue()
                                }
                                if let cevapId = dokuman["repliedMessage"] as? String {
                                    let mesaj = Message(id: dokuman.documentID, message: dokuman["message"] as? String ?? "", userName: dokuman["userName"] as? String ?? "", userUid: dokuman["userUid"] as? String ?? "", documentUrl: dokuman["documentUrl"] as? String, sendDate: sendedDateObject , repliedMessage: dokuman["repliedMessage"] as? String)
                                    
                                    self.chatList.append(mesaj)
                                    print("KRİTİK ALANA GİRDİ Mİ")
                                    
                                    self.firestore!.collection("chat").document(cevapId).getDocument { snapshot, error in
                                        if let snapshot = snapshot {
                                                
                                            let cevapMesaj = Message(id: dokuman.documentID, message: dokuman["message"] as? String ?? "", userName: dokuman["userName"] as? String ?? "", userUid: dokuman["userUid"] as? String ?? "", documentUrl: dokuman["documentUrl"] as? String, sendDate: sendedDateObject , repliedMessage: dokuman["repliedMessage"] as? String, repliedSender: snapshot["userName"] as? String, cevaplananMesaj: snapshot["message"] as? String)
                                            
                                            self.cevaplananMesajList.append(cevapMesaj)
                                            
                                        }
                                    }
                                     

                                } else {
                                    let mesaj = Message(id: dokuman.documentID, message: dokuman["message"] as? String ?? "", userName: dokuman["userName"] as? String ?? "", userUid: dokuman["userUid"] as? String ?? "", documentUrl: dokuman["documentUrl"] as? String, sendDate: sendedDateObject)
                                    
                                    self.chatList.append(mesaj)
                                    
                                    
                                    
                                }
                                loopIndex = loopIndex + 1
                                DispatchQueue.main.async {
                                    
                                    self.chatViewModel = ChatRecyclerAdapter(messageList: self.chatList.reversed())
                                    self.tableView.reloadData()
                                    self.scrollDownAutomatically()
                                    
                                }
                                
                               
                                
                            }
                            
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "İnternet bağlantınızdan emin olun.")
                        }
                    } else {
                        if let error = error {
                            self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "İnternet bağlantınızdan emin olun.")
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.goLogin()
                }
                
            }
            // Align END
        }
    }
    
    func whichSide(currentUserId : String , senderUserId : String) -> Bool{
        var durum = true
        if currentUserId == senderUserId {
            // Right Side -> Me
            durum = true
            
        } else {
            // Left Side -> Other
            durum = false
        }
        return durum
    }
    
    
    
    
    // Delegate Requirements
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var donenSayi = 0
        if let chatViewModel = chatViewModel {
            donenSayi = chatViewModel.numberOfRows()
        }
        return donenSayi
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selected = self.chatViewModel?.selectedItem(index: indexPath.row) {
            print("SEÇİLEN HÜCRE")
            print(selected)
            let sender_id = selected.userUid
            if whichSide(currentUserId: currentUserId!, senderUserId: sender_id) {
                // Me
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeCell", for: indexPath) as! MeMessageTableViewCell
                
                cell.verticalStack.layer.cornerRadius = 5
                cell.verticalStack.layer.borderColor = UIColor(red: 4, green: 29, blue: 67, alpha: 1).cgColor
                cell.verticalStack.layer.borderWidth = CGFloat(2)
                cell.verticalStack.backgroundColor = UIColor.green
                cell.verticalStack.spacing = CGFloat(10)
                cell.verticalStack.frame.origin = cell.frame.origin
                cell.verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                cell.verticalStack.isLayoutMarginsRelativeArrangement = true
                
                
                // Sender
                let senderText = UILabel()
                senderText.text = " \(selected.userName)"
                senderText.textColor = UIColor.black
                senderText.font = UIFont.boldSystemFont(ofSize: senderText.font.pointSize)
                senderText.numberOfLines = 0
                senderText.lineBreakMode = .byWordWrapping
                
                
                // Message
                let messageText = UILabel()
                messageText.text = " \(selected.message)"
                messageText.numberOfLines = 0
                messageText.lineBreakMode = .byWordWrapping
                messageText.textColor = UIColor.black
                
                
                // Date
                let dateText = UILabel()
                if let zaman = selected.sendDate {
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "HH:mm"
                    dateFormat.timeZone = .current
                    
                    let edittedDate = dateFormat.string(from: zaman)
                    
                    dateText.text = " \(edittedDate)  "
                    dateText.numberOfLines = 1
                    dateText.textColor = UIColor.cyan
                    dateText.textAlignment = .right
                    
                    
                    
                } else {
                    
                    dateText.text = "  "
                    dateText.numberOfLines = 1
                    dateText.textColor = UIColor.cyan
                    dateText.textAlignment = .right
                }
                
                
                
                // Replied Case
                if let retrievedId = selected.repliedMessage {
                    
                    print("DOKUMANA BAKALIM")
                    print(self.cevaplananMesajList)
                    
                    for eleman in self.cevaplananMesajList {
                        print("ARAMA BAŞLATILDI")
                        print(eleman)
                        if eleman.repliedMessage == retrievedId {
                            let repliedSenderText = UILabel()
                            repliedSenderText.text = " \(eleman.repliedSender ?? "")"
                            repliedSenderText.textColor = UIColor.black
                            repliedSenderText.font = UIFont.boldSystemFont(ofSize: senderText.font.pointSize)
                            repliedSenderText.numberOfLines = 0
                            repliedSenderText.lineBreakMode = .byWordWrapping
                            repliedSenderText.backgroundColor = UIColor.gray
                            
                            
                            let repliedMessageText = UILabel()
                            repliedMessageText.text = " \(String(describing: eleman.cevaplananMesaj ?? ""))"
                            repliedMessageText.textColor = UIColor.black
                            repliedMessageText.numberOfLines = 0
                            repliedMessageText.lineBreakMode = .byWordWrapping
                            repliedMessageText.backgroundColor = UIColor.gray
                            
                            
                            let repVerticalStact = UIStackView()
                            repVerticalStact.backgroundColor = UIColor.gray
                            repVerticalStact.axis = .vertical
                            repVerticalStact.addArrangedSubview(repliedSenderText)
                            repVerticalStact.addArrangedSubview(repliedMessageText)
                            
                            self.iceriyiTemizle(stack: cell.verticalStack)
                            cell.verticalStack.addArrangedSubview(senderText)
                            cell.verticalStack.addArrangedSubview(repVerticalStact)
                            cell.verticalStack.addArrangedSubview(messageText)
                            cell.verticalStack.addArrangedSubview(dateText)
                            
                            break
                        }
                    }
                    
                    
                } else {
                    iceriyiTemizle(stack: cell.verticalStack)
                    cell.verticalStack.addArrangedSubview(senderText)
                    cell.verticalStack.addArrangedSubview(messageText)
                    cell.verticalStack.addArrangedSubview(dateText)
                }
                 
                
                
                
                
                cell.messageId = selected.id
                if let documentUrl = selected.documentUrl {
                    // Documan'ın url'sini diger tarafa gonder
                    cell.documentButton.isHidden = false
                    cell.documentButton.isUserInteractionEnabled = true
                    cell.documnetUrl = documentUrl
                    let documentGesture = UITapGestureRecognizer(target: self, action: #selector(dokumanaTiklandi(_:)))
                    cell.documentButton.addGestureRecognizer(documentGesture)
                    
                } else {
                    cell.documentButton.isHidden = true
                    cell.documentButton.isUserInteractionEnabled = false
                    cell.documnetUrl = nil
                }
                
                cell.isUserInteractionEnabled = true
                cell.contentView.isUserInteractionEnabled = true
                cell.verticalStack.isUserInteractionEnabled = true
                
                
                return cell
            } else {
                // Other
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherCell", for: indexPath) as! OtherMessageTableViewCell
                
                cell.verticalStack.layer.cornerRadius = 5
                cell.verticalStack.layer.borderColor = UIColor(red: 4, green: 29, blue: 67, alpha: 1).cgColor
                cell.verticalStack.layer.borderWidth = CGFloat(2)
                cell.verticalStack.spacing = CGFloat(10)
                cell.verticalStack.frame.origin = cell.frame.origin
                cell.verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                cell.verticalStack.isLayoutMarginsRelativeArrangement = true
                
                // Sender
                let senderText = UILabel()
                senderText.text = " \(selected.userName)"
                senderText.textColor = UIColor.black
                senderText.font = UIFont.boldSystemFont(ofSize: senderText.font.pointSize)
                senderText.numberOfLines = 0
                senderText.lineBreakMode = .byWordWrapping
                
                
                // Message
                let messageText = UILabel()
                messageText.text = " \(selected.message)"
                messageText.numberOfLines = 0
                messageText.lineBreakMode = .byWordWrapping
                messageText.textColor = UIColor.black
                
                
                // Date
                let dateText = UILabel()
                if let zaman = selected.sendDate {
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "HH:mm"
                    dateFormat.timeZone = .current
                    
                    let edittedDate = dateFormat.string(from: zaman)
                    
                    dateText.text = " \(edittedDate)  "
                    dateText.numberOfLines = 1
                    dateText.textColor = UIColor.cyan
                    dateText.textAlignment = .right
                    
                    
                    
                } else {
                    
                    dateText.text = "  "
                    dateText.numberOfLines = 1
                    dateText.textColor = UIColor.cyan
                    dateText.textAlignment = .right
                }
                
                
                // Replied Case
                if let retrievedId = selected.repliedMessage {
                    
                    print("DOKUMANA BAKALIM")
                    print(self.cevaplananMesajList)
                    
                    for eleman in self.cevaplananMesajList {
                        print("ARAMA BAŞLATILDI")
                        print(eleman)
                        if eleman.repliedMessage == retrievedId {
                            let repliedSenderText = UILabel()
                            repliedSenderText.text = " \(eleman.repliedSender ?? "")"
                            repliedSenderText.textColor = UIColor.black
                            repliedSenderText.font = UIFont.boldSystemFont(ofSize: senderText.font.pointSize)
                            repliedSenderText.numberOfLines = 0
                            repliedSenderText.lineBreakMode = .byWordWrapping
                            repliedSenderText.backgroundColor = UIColor.gray
                            
                            
                            let repliedMessageText = UILabel()
                            repliedMessageText.text = " \(String(describing: eleman.cevaplananMesaj ?? ""))"
                            repliedMessageText.textColor = UIColor.black
                            repliedMessageText.numberOfLines = 0
                            repliedMessageText.lineBreakMode = .byWordWrapping
                            repliedMessageText.backgroundColor = UIColor.gray
                            
                            
                            let repVerticalStact = UIStackView()
                            repVerticalStact.backgroundColor = UIColor.gray
                            repVerticalStact.axis = .vertical
                            repVerticalStact.addArrangedSubview(repliedSenderText)
                            repVerticalStact.addArrangedSubview(repliedMessageText)
                            
                            self.iceriyiTemizle(stack: cell.verticalStack)
                            cell.verticalStack.addArrangedSubview(senderText)
                            cell.verticalStack.addArrangedSubview(repVerticalStact)
                            cell.verticalStack.addArrangedSubview(messageText)
                            cell.verticalStack.addArrangedSubview(dateText)
                            
                            break
                        }
                    }
                    
                    
                } else {
                    iceriyiTemizle(stack: cell.verticalStack)
                    cell.verticalStack.addArrangedSubview(senderText)
                    cell.verticalStack.addArrangedSubview(messageText)
                    cell.verticalStack.addArrangedSubview(dateText)
                }
                 
                
                
                
                
                cell.messageId = selected.id
                if let documentUrl = selected.documentUrl {
                    // Documan'ın url'sini diger tarafa gonder
                    cell.documentButton.isHidden = false
                    cell.documentButton.isUserInteractionEnabled = true
                    cell.documentUrl = documentUrl
                    let documentGesture = UITapGestureRecognizer(target: self, action: #selector(documentClicked(_:)))
                    cell.documentButton.addGestureRecognizer(documentGesture)
                    
                } else {
                    cell.documentButton.isHidden = true
                    cell.documentButton.isUserInteractionEnabled = false
                    cell.documentUrl = nil
                }
                
                
                cell.contentView.isUserInteractionEnabled = true
                cell.isUserInteractionEnabled = true
                
                let panGesture = UISwipeGestureRecognizer(target: self, action: #selector(swippedSideCell(_:)))
                cell.addGestureRecognizer(panGesture)
                return cell
                
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            
            
            
            
            return cell
        }
       
        
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    
    func iceriyiTemizle( stack : UIStackView ) {
        for view in stack.arrangedSubviews {
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    

    @objc func dokumanaTiklandi(_ gesture : UITapGestureRecognizer ){
        
        if let cell = gesture.view?.superview?.superview as? MeMessageTableViewCell {
            if let dokumanUrl = cell.documnetUrl {
                self.selectedDocumentUrl = dokumanUrl
                performSegue(withIdentifier: "ChatDocumentCell", sender: self)
                
            }
        }
    }
    
    @objc func documentClicked(_ gesture : UITapGestureRecognizer ){
        print("DOKUMANA TIKLANDI")
        print(gesture)
        if let cell = gesture.view?.superview?.superview as? OtherMessageTableViewCell {
            if let dokumanUrl = cell.documentUrl {
                self.selectedDocumentUrl = dokumanUrl
                performSegue(withIdentifier: "ChatDocumentCell", sender: self)
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatDocumentCell" {
            if let hucre = segue.destination as? ChatDocumentViewController {
                hucre.dispayLink = self.selectedDocumentUrl
            }
        }
    }
    
    func kapat(){
        
        // Bak
        
    }
    
    func ac(){
        
        // Bak
        
    }
    
    @objc func swippedSideCell(_ cell : UISwipeGestureRecognizer ){
        
        // Bak
        
    }
    
    func ayarCek(repliedSender : String = "" , repliedMessage : String = ""){
        // Bak
    }
    
    @objc func replyCancel(){
        self.repliedAction = false
        self.repliedMessageId = nil
        ayarCek()
    }
    
    @objc func scrollDownAutomatically(){
        // First figure out how many sections there are
        let lastSectionIndex = self.tableView.numberOfSections - 1

        // Then grab the number of rows in the last section
        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex) - 1

        // Now just construct the index path
        let pathToLastRow = NSIndexPath(row: lastRowIndex, section: lastSectionIndex)

        // Make the last row visible
        self.tableView.scrollToRow(at: pathToLastRow as IndexPath, at: .bottom, animated: true)
    }
    
    
    func keyboardHeight(){
        let notification = NSNotification()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                print(keyboardHeight)
        }
        
    }

}
