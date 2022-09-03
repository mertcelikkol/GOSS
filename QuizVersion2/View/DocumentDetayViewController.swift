//
//  DocumentDetayViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import PDFKit
import Firebase
import GoogleMobileAds

class DocumentDetayViewController: UIViewController, GADBannerViewDelegate {
    
    // Elemanların Tanımlanması
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    // Parametrelerin Tanımlanması
    var dokuman : Document?
    var pdfView : PDFView = PDFView()
    var bannerView : GADBannerView!
    var kullanici = ViewController.kullanici
    var auth : Auth?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pdfAyarlanmasi()
        
        // Reklam Olayları START
        auth = Auth.auth()
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
        
        // Reklam Olayları END
        
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
        
        func reklamAyarlari(type : String = "banner" , kullanici : Kullanici){
            if kullanici.memberType == .standart {
                if type == "banner" {
                    bannerReklamYukle()
                } else {
                    
                }
            } else {
                adView.frame.size.height = 0
            }
        }
        
        func bannerReklamYukle(){
            //
            // ca-app-pub-6292749914687688/6445889274
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView!,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: adView,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0),
               NSLayoutConstraint(item: bannerView!,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: adView,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
            bannerView.adUnitID = "ca-app-pub-6292749914687688/6445889274"
            bannerView.load(GADRequest())
            
        
            
            
        }
    
    func pdfAyarlanmasi(){
            if let url = dokuman?.documentUrl {
                let document = PDFDocument(url: URL(string: url)!)
                
                pdfView.document = document
                pdfView.frame.size = mainView.frame.size
                pdfView.autoScales = true
                pdfView.contentMode = .scaleAspectFit
                
                mainView.addSubview(pdfView)
            }
        }
    
}
