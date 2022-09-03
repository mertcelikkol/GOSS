//
//  BillingViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase
import StoreKit

class BillingViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    // Elemanların Tanımlanması
    
    @IBOutlet weak var premiumView: UIView!
    
    
    @IBOutlet weak var goldView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    // Parametrelerin Tanımlanması
    
    var selectedIndex : Int = 0
    private var models = [SKProduct]()
        
    var kullanici : Kullanici? = ViewController.kullanici
    private var request : SKProductsRequest?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        gunduzMod()
        paketDetaylariniGetir()
        // Do any additional setup after loading the view.
        backButton.addTarget(self, action: #selector(self.sayfaKapat), for: .allTouchEvents)
        premiumView.isUserInteractionEnabled = true
        let premiumGesture = UITapGestureRecognizer(target: self, action: #selector(premiumIslem))
        premiumView.addGestureRecognizer(premiumGesture)
            
        goldView.isUserInteractionEnabled = true
        let goldGesture = UITapGestureRecognizer(target: self, action: #selector(goldIslem))
        goldView.addGestureRecognizer(goldGesture)
            
            
        // For Payment
        request?.delegate = self
        SKPaymentQueue.default().add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
        
        // Products
        
        enum Product : String, CaseIterable {
            // App Store'dan Her bir urun için ID bilgisi gelmesi gerekiyor !!
            case premium = "premiumMember"
            case gold = "goldMember"
        }
        
        func paketDetaylariniGetir(){
            print("CAGRILDI 1")
            
            if (SKPaymentQueue.canMakePayments())
                    {
                let productID:Set<String> = Set<String>(arrayLiteral: "goldMember","premiumMember")
                let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID);
                productsRequest.delegate = self;
                productsRequest.start();
                print("Fething Products");
            }else{
                print("can't make purchases");
            }
        }
        
        func bastanPaketDetaylariniGetir(){
            print("CAGRILDI 3")
            let productID: NSSet = NSSet(objects: "goldUyelik","premiumUyelik")
            request = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            if let request = request {
                request.start()
                print("ÖDEME İŞLEMİ BAŞLIYOORR")
                odemeIslemiBaslat(index: selectedIndex)
            }
        }
        
        @objc func goldIslem(){
            self.selectedIndex = 0
            odemeIslemiBaslat(index: 0)
            
        }
        
        @objc func premiumIslem(){
            self.selectedIndex = 1
            odemeIslemiBaslat(index: 1)
            
        }
        
        func odemeIslemiBaslat(index : Int) {
            print("FONKSİYON ÇAĞRILDI MI")
            if models.count > 0 {
                let urun = models[index]
                let payment = SKPayment(product: urun)
                SKPaymentQueue.default().add(payment)
                print("EKLENDİ")
            } else {
                print("BOŞA DÜŞTÜ")
                //bastanPaketDetaylariniGetir()
            }
        }
        
        // Delegate Requirement
        
        func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
            print("SONUÇ")
            print(response)
            self.models.removeAll()
            self.models = response.products
            print(self.models)
        }
        
        
        
        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            transactions.forEach { islem in
                print("BURASI ÇAĞRILIYOR MU")
                switch islem.transactionState {
                case .purchasing:
                    print("Ödeme işlemi başladı")
                case .purchased:
                    print("Ödeme işlemi tamamlandı")
                    SKPaymentQueue.default().finishTransaction(islem)
                    // Ödeme İşleminin Sonucunu Kaydet, Bilgilendir ve Yönlendir.
                    // 6 aylık üyelik tanımla.
                    let subscriptionEndDate = Date().addingTimeInterval(TimeInterval(6 * 30 * 24 * 60 * 60 * 60))
                    kullanici?.memberType = .premium
                    if let kullanici = kullanici {
                        var memberType = "premium"
                        var userData = [
                            "memberType" : "premium",
                            "subscriptionEndDate" : subscriptionEndDate
                        ] as [String : Any]
                        ViewController.kullanici?.memberType = .gold
                        if selectedIndex == 0 {
                            ViewController.kullanici?.memberType = .premium
                            memberType = "gold"
                            userData = [
                                "memberType" : "gold",
                                "subscriptionEndDate" : subscriptionEndDate
                            ] as [String : Any]
                        }
                        
                        let database = Database.database()
                        
                        database.reference(withPath: "user").child(kullanici.uid ?? "").child("memberType").setValue(memberType) { Error, dataRef in
                            let alert = UIAlertController(title: "Ödeme İşlemi Tamamlandı", message: "Üyeliğiniz tanımlandı. Hayırlı olsun", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "Tamam", style: .default) { aksiyon in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(islem)
                    self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hatadan dolayı ödeme işleminiz yapılamamıştır. Daha sonra tekrar deneyin")
                case .restored:
                    SKPaymentQueue.default().finishTransaction(islem)
                    // Ödeme İşleminin Sonucunu Kaydet, Bilgilendir ve Yönlendir.
                    // 6 aylık üyelik tanımla.
                    let subscriptionEndDate = Date().addingTimeInterval(TimeInterval(6 * 30 * 24 * 60 * 60 * 60))
                    kullanici?.memberType = .premium
                    if let kullanici = kullanici {
                        var userData = [
                            "memberType" : "gold",
                            "subscriptionEndDate" : subscriptionEndDate
                        ] as [String : Any]
                        if selectedIndex == 0 {
                            userData = [
                                "memberType" : "premium",
                                "subscriptionEndDate" : subscriptionEndDate
                            ] as [String : Any]
                        }
                        
                        Firestore.firestore().collection("user").document(kullanici.uid!).updateData(userData) { hata in
                            if hata == nil {
                                
                                let alert = UIAlertController(title: "Ödeme İşlemi Tamamlandı", message: "Üyeliğiniz tanımlandı. Hayırlı olsun", preferredStyle: .alert)
                                let okButton = UIAlertAction(title: "Tamam", style: .default) { aksiyon in
                                    self.dismiss(animated: true, completion: nil)
                                }
                                alert.addAction(okButton)
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                    }
                case .deferred:
                    break
                @unknown default:
                    self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hatadan dolayı ödeme işleminiz yapılamamıştır. Daha sonra tekrar deneyin")
                }
            }
        }
    
    
}
