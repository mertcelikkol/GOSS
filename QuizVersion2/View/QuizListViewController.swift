//
//  QuizListViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase
import SDWebImage
import GoogleMobileAds
import StoreKit


class QuizListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADFullScreenContentDelegate {
    
    // Elemanların Tanımlanması
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    // Parametrelerin Tanımlanması
    var auth : Auth?
    var firestore : Firestore?
    var quizListViewModel : QuizListAdapter?
    var quizList = [QuizListModel]()
    var selectedQuizId : String?
    var categoryId : String? = CategoriesViewController.selectedCatId
    var memberType : MemberType = ViewController.kullanici?.memberType ?? .standart
    var bannerView : GADBannerView!
    private var interstitial: GADInterstitialAd?
    var kullanici = ViewController.kullanici
    

    override func viewDidLoad() {
        super.viewDidLoad()
        kurulumlar()
        // Do any additional setup after loading the view.
        
        // Reklam Olayı
                
                
                if let kullanici = kullanici {
                    print("NEREYE GİRİYOR 1")
                    if kullanici.memberType == .gold {
                        self.adView.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true
                        self.view.updateConstraints()
                    } else {
                        self.bannerView = GADBannerView(frame: self.adView.frame)
                        self.bannerView.rootViewController = self
                        self.addBannerViewToView(self.bannerView)
                    }
                } else {
                    print("NEREYE GİRİYOR 2")
                    if let guncel = auth?.currentUser {
                        print("NEREYE GİRİYOR 3")
                       
                        getUser(uid: guncel.uid)
                    }
                    
                }
        
        backButton.addTarget(self, action: #selector(self.sayfaKapat), for: .allTouchEvents)
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
                    
                    
                    
                }
            }
        }
    
    func kurulumlar(){
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = CGFloat(334)
            tableView.estimatedRowHeight = CGFloat(334)
        
            auth = Auth.auth()
            firestore = Firestore.firestore()
            
            // Tıklama Aksiyonları
            rateButton.addTarget(self, action: #selector(puanla), for: .allTouchEvents)
            shareButton.addTarget(self, action: #selector(shareWe), for: .allTouchEvents)
            
            getData()
            
        }
        
        func getData(){
            if let firestore = firestore {
                if let categoryId = categoryId {
                    firestore.collection("categories").document(categoryId).collection("quizzes").getDocuments { querySnapshot, error in
                        if error == nil {
                            if let querySnapshot = querySnapshot {
                                self.quizList.removeAll()
                                for quiz in querySnapshot.documents {
                                    let sinav = QuizListModel(quiz_id: quiz.documentID, name: quiz["name"] as? String ?? "", desc: quiz["desc"] as? String ?? "", image: quiz["image"] as? String ?? "", level: quiz["level"] as? String ?? "", visibility: quiz["visibility"] as? String ?? "", questions: quiz["questions"] as? Int ?? 0)
                                    
                                    self.quizList.append(sinav)
                                }
                                self.quizListViewModel = QuizListAdapter(quizList: self.quizList)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } else {
                                self.alarmVer(baslik: "Hata", mesaj: "Quizleri yükleyemedik. Lütfen internet bağlantınızdan emin olun.")
                            }
                        } else {
                            if let error = error {
                                self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                            } else {
                                self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hata oluştu.")
                            }
                        }
                    }
                } else {
                    // Categories Sayfasına Geri Git
                    
                }
            }
        }
        
        // Delegate Requirement
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            var number = 0
            if let quizListViewModel = quizListViewModel {
                number = quizListViewModel.numberOfRows()
            }
            return number
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuizListCell", for: indexPath) as! SinavTableViewCell
            if let siradaki = quizListViewModel?.selectedItem(index: indexPath.row) {
                cell.quizDescription.text = siradaki.desc
                cell.quizTitle.text = siradaki.name
                cell.quizDifficulty.text = siradaki.level
                cell.quizId = siradaki.quiz_id
                cell.quizImage.sd_setImage(with: URL(string: siradaki.image), completed: nil)
                
                
                
                    
                if indexPath.row > 1 {
                    if memberType == .standart {
                        cell.sinaviGorButton.titleLabel?.text = "Kilitli"
                        // Billing Fragment'a Götür
                        cell.sinaviGorButton.removeTarget(self, action: #selector(quizeGit(_:)), for: .allTouchEvents)
                        cell.sinaviGorButton.addTarget(self, action: #selector(faturaya), for: .allTouchEvents)
                        
                    } else {
                        let quizGesture = UITapGestureRecognizer(target: self, action: #selector(quizeGit(_:)))
                        cell.sinaviGorButton.removeTarget(self, action: #selector(faturaya), for: .allTouchEvents)
                        cell.sinaviGorButton.titleLabel?.text = "Sınavı Gör"
                        cell.sinaviGorButton.addGestureRecognizer(quizGesture)
                    }
                } else {
                    let sinavGesture = UITapGestureRecognizer(target: self, action: #selector(quizeGit(_:)))
                    cell.sinaviGorButton.removeTarget(self, action: #selector(faturaya), for: .allTouchEvents)
                    cell.sinaviGorButton.titleLabel?.text = "Sınavı Gör"
                    cell.sinaviGorButton.addGestureRecognizer(sinavGesture)
                }
                
                
            }
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(334)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(334)
    }
        
        @objc func faturaya(){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "QuizToBilling", sender: nil)
            }
        }
        
        @objc func quizeGit(_ cell : UITapGestureRecognizer){
            print("CAGRILDI BABOŞ")
            // Reklam Kontrolü
            if let guncelKullanici = ViewController.kullanici {
                print("STAGE 1")
                if guncelKullanici.memberType == .standart {
                    print("STAGE 2")
                    if let hucre = cell.view?.superview?.superview as? SinavTableViewCell {
                        print("STAGE 3")
                        if let id = hucre.quizId {
                            print("STAGE 4")
                            self.selectedQuizId = id
                        }
                    } else {
                        print("STAGE 5")
                        if let hucre = cell.view?.superview as? SinavTableViewCell {
                            print("STAGE 6")
                            if let id = hucre.quizId {
                                print("STAGE 7")
                                self.selectedQuizId = id
                            }
                        }
                    }
                    //performSegue(withIdentifier: "QuizSegue", sender: self)
                    if let memberType = kullanici?.memberType {
                        if memberType == .gold {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "QuizSegue", sender: self)
                            }
                        } else {
                            let request = GADRequest()
                                GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6292749914687688/9019252110",
                                                            request: request,
                                                  completionHandler: { [self] ad, error in
                                                    if let error = error {
                                                        print(error)
                                                        DispatchQueue.main.async {
                                                            self.performSegue(withIdentifier: "QuizSegue", sender: self)
                                                        }
                                                        
                                                      return
                                                    }
                                                interstitial = ad
                                                interstitial?.fullScreenContentDelegate = self
                                                interstitial?.present(fromRootViewController: self)
                                                  })
                        }
                    } else {
                        let request = GADRequest()
                            GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6292749914687688/9019252110",
                                                        request: request,
                                              completionHandler: { [self] ad, error in
                                                if let error = error {
                                                    print(error)
                                                    DispatchQueue.main.async {
                                                        self.performSegue(withIdentifier: "QuizSegue", sender: self)
                                                    }
                                                    
                                                  return
                                                }
                                            interstitial = ad
                                            interstitial?.fullScreenContentDelegate = self
                                            interstitial?.present(fromRootViewController: self)
                                              })
                    }
                    
                } else {
                    if let hucre = cell.view?.superview?.superview as? SinavTableViewCell {
                        print("STAGE 8")
                        if let id = hucre.quizId {
                            print("STAGE 9")
                            self.selectedQuizId = id
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "QuizSegue", sender: self)
                            }
                            
                        }
                    } else {
                        print("STAGE 10")
                        if let hucre = cell.view?.superview as? SinavTableViewCell {
                            print("STAGE 11")
                            if let id = hucre.quizId {
                                print("STAGE 12")
                                self.selectedQuizId = id
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "QuizSegue", sender: self)
                                }
                            }
                        }
                    }
                }
            } else {
                print("BOŞLUĞA DÜŞTÜ")
                print(cell)
            }
            
             
            
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "QuizSegue" {
                // Quiz Id'yi Gonder
                print("GİRİYOR MU")
                if let hucre = segue.destination as? DetailsViewController {
                    hucre.quizId = self.selectedQuizId
                }
            }
        }
        
    
    @objc func puanla(){
            if let window = view.window?.windowScene {
                
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: window)
                } else {
                    // Fallback on earlier versions
                    
                }
            
            }
        }
    
    // Video Reklamları Delegate
        
        /// Tells the delegate that the ad failed to present full screen content.
          func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
              print("FAIL OLDU")
              DispatchQueue.main.async {
                  self.performSegue(withIdentifier: "QuizSegue", sender: self)
              }
              
          }

          /// Tells the delegate that the ad presented full screen content.
          func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
              print("GÖSTERİM BİTTİ")
              DispatchQueue.main.async {
                  self.performSegue(withIdentifier: "QuizSegue", sender: self)
              }
          }

          /// Tells the delegate that the ad dismissed full screen content.
          func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
              print("İPTAL EDİLDİ")
              DispatchQueue.main.async {
                  self.performSegue(withIdentifier: "QuizSegue", sender: self)
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
        
        @objc func shareWe(){
            
            let shareLink = "https://apps.apple.com/us/app/quizappturk/id1588645225"
            let activityController = UIActivityViewController(activityItems: [shareLink], applicationActivities: nil)
            
            activityController.completionWithItemsHandler = { (nil, completed, _, error) in
                
                if completed {
                    self.alarmVer(baslik: "Teşekkür Ederiz", mesaj: "Bizi paylaştığınız için size teşekkür ederiz.")
                } else {
                    
                }
                
            }
            
            present(activityController, animated: true, completion: nil)
            
        }

        

}
