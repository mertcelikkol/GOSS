//
//  CategoriesViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 1.08.2022.
//

import UIKit
import Firebase
import SDWebImage
import StoreKit
import GoogleMobileAds

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    
    // Elemanların Tanımlanması
    
    
    @IBOutlet weak var adView: UIView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // Parametrelerin Tanımlanması
    static var selectedCatId : String?
    var auth : Auth?
    var firestore : Firestore?
    var categoriesRA : CategoryRecyclerAdapter?
    var categoriList = [Category]()
    var kullanici : Kullanici? = ViewController.kullanici
    var bannerView : GADBannerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gunduzMod()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = CGFloat(430)
        tableView.estimatedRowHeight = CGFloat(430)
        // Do any additional setup after loading the view.
        butonlarinTiklamaOlaylari()
        
        // Reklam Olayı
                
        if let kullanici = kullanici {
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
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CategoriesToVC", sender: nil)
                }
            }
                    
        }
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
                            self.adView.frame.size.height = 0
                        } else if(tip == "premium") {
                            memberType = .premium
                        }
                        
                        if memberType != .gold {
                            self.bannerView = GADBannerView(frame: self.adView.frame)
                            self.bannerView.rootViewController = self
                            self.addBannerViewToView(self.bannerView)
                        }
                    }
                    ViewController.kullanici = Kullanici(uid: uid, userName: dokuman["userName"] as? String ?? "", mail: dokuman["mail"] as? String ?? "", password: dokuman["password"] as? String ?? "", memberType: memberType)
                    
                    
                    
                }
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    func getData(){
        firestore = Firestore.firestore()
        if let firestore = firestore {
            firestore.collection("categories").getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        self.categoriList.removeAll()
                        for document in snapshot.documents {
                            
                            let cat = Category(category_id: document.documentID, name: document.get("name") as? String ?? "", description: document.get("description") as? String ?? "", image: document.get("image") as? String ?? "", level: document.get("level") as? String ?? "", visibility: document.get("visibility") as? String ?? "", quizzes: document.get("quizzes") as? Int ?? 0)
                            self.categoriList.append(cat)
                        }
                        print("FETCHED CATEGORIES")
                        print(self.categoriList)
                        self.categoriesRA = CategoryRecyclerAdapter(categoryList: self.categoriList)
                        self.tableView.reloadData()
                    }
                } else {
                    if let error = error {
                        self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                    } else {
                        self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hata oluştu.")
                    }
                }
            }
        }
    }

    
    
    // Delegate Requirements
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        if let categoriesRA = categoriesRA {
            number = categoriesRA.numberOfRows()
        }
        return number
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoriesTableViewCell
        
        let selected = self.categoriesRA?.selectedItem(index: indexPath.row)
        
        if let selected = selected {
            cell.category_id = selected.category_id
           
            cell.categoryImage.sd_setImage(with: URL(string: selected.image), placeholderImage: UIImage(named: "guverte"), options: .continueInBackground, context: nil)
            
            cell.categoriTitle.text = selected.name
            cell.categoryDesription.text = selected.description
            cell.difficulty.text = selected.level
            
            
            
            cell.dokumanButton.isUserInteractionEnabled = true
            
            cell.dokumanButton.addTarget(self, action: #selector(dokumanSecildi(_:)), for: .allEvents)
             
            
            cell.quizButton.isUserInteractionEnabled = true
            cell.quizButton.addTarget(self, action: #selector(sinavSecildi(_:)), for: .allEvents)
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(430)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(430)
    }
    //   objc func ->
    // Butonların Tıklama Olayları
    
    func icBosal(){
        logoutButton.titleLabel?.text = ""
        rateButton.titleLabel?.text = ""
        shareButton.titleLabel?.text = ""
        chatButton.titleLabel?.text = ""
    }
    
    func butonlarinTiklamaOlaylari(){
        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(cikisYap))
        logoutButton.isUserInteractionEnabled = true
        logoutButton.addGestureRecognizer(logoutGesture)
        
        
        if #available(iOS 14.0, *) {
            let rateGesture = UITapGestureRecognizer(target: self, action: #selector(puanla))
            rateButton.isUserInteractionEnabled = true
            rateButton.addGestureRecognizer(rateGesture)
        } else {
            // Fallback on earlier versions
        }
        
        
        
        let shareGesture = UITapGestureRecognizer(target: self, action: #selector(paylas))
        shareButton.isUserInteractionEnabled = true
        shareButton.addGestureRecognizer(shareGesture)
        
        
        let chatGesture = UITapGestureRecognizer(target: self, action: #selector(chate))
        chatButton.isUserInteractionEnabled = true
        chatButton.addGestureRecognizer(chatGesture)
        icBosal()
    }
    
    @objc func cikisYap(){
        icBosal()
        if let auth = auth {
            do {
                try auth.signOut()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CategoriesToVC", sender: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CategoriesToVC", sender: nil)
                }
            }
        } else {
            do {
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CategoriesToVC", sender: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CategoriesToVC", sender: nil)
                }
            }
            
        }
    }
    
    @available(iOS 14.0, *)
    @objc func puanla(){
        
        if let window = view.window?.windowScene {
            
            SKStoreReviewController.requestReview(in: window)
        
        }
        icBosal()
    }
    
    @objc func paylas(){
        
        let shareLink = "https://apps.apple.com/us/app/quizappturk/id1588645225"
        let activityController = UIActivityViewController(activityItems: [shareLink], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            self.icBosal()
            if completed {
                self.alarmVer(baslik: "Teşekkür Ederiz", mesaj: "Bizi paylaştığınız için size teşekkür ederiz.")
            } else {
                self.icBosal()
            }
            
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    @objc func chate(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ChatSegue", sender: nil)
        }
    }
    
    @objc func sinavSecildi(_ cell : UIButton){
        if let hucre = cell.superview?.superview as? CategoriesTableViewCell {
            if let cat_id = hucre.category_id {
                CategoriesViewController.selectedCatId = cat_id
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SinavlarSegue", sender: nil)
                }
                
            }
        } else {
            if let hucre = cell.superview as? CategoriesTableViewCell {
                if let cat_id = hucre.category_id {
                    CategoriesViewController.selectedCatId = cat_id
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "SinavlarSegue", sender: nil)
                    }
                    
                }
            }
        }
        
    }
    @objc func dokumanSecildi(_ cell : UIButton){
        
        if let hucre = cell.superview?.superview as? CategoriesTableViewCell {
            if let cat_id = hucre.category_id {
                CategoriesViewController.selectedCatId = cat_id
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "DokumanlarSegue", sender: nil)
                }
                
            }
        } else {
            if let hucre = cell.superview as? CategoriesTableViewCell {
                if let cat_id = hucre.category_id {
                    CategoriesViewController.selectedCatId = cat_id
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "DokumanlarSegue", sender: nil)
                    }
                    
                }
            }
        }
        
        
    }

}
