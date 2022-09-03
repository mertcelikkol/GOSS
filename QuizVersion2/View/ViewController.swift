//
//  ViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import UIKit
import Firebase


class ViewController: UIViewController {
    
    //@ Parametrelerin Tanımlanması
    var auth : Auth?
    var timer = Timer()
    static var kullanici : Kullanici?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gunduzMod()
        print("AÇILIYOR MU ACABA")
        kurulum()
        
    }
    
    func kurulum(){
        auth = Auth.auth()
        if auth?.currentUser == nil {
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "SplahToMain", sender: nil)
            }
        } else {
            print("CASE 2")
            if let uid = auth?.currentUser?.uid {
                print("CASE 3")
                let db = Database.database()
                let reference = db.reference()
                
                reference.child("user").child(uid).observeSingleEvent(of: .value) { snapshot in
                    print("CASE 4")
                    if let dokuman = snapshot.value as? [String:Any] {
                        print("CASE 5")
                        let member = dokuman["memberType"] as? String ?? "standart"
                        print("MEMBER TYPE : \(member)")
                        var memberType : MemberType = .standart
                        if member == "premium" {
                            memberType = .premium
                        } else if member == "gold" {
                            memberType = .gold
                        }
                        
                        ViewController.kullanici = Kullanici(uid: uid, userName: dokuman["userName"] as? String ?? "", mail: dokuman["mail"] as? String ?? "", password: dokuman["password"] as? String ?? "", memberType: memberType, subsriptionEndDate: dokuman["subsriptionEndDate"] as? Date)
                        print("KULLANICI")
                        print(ViewController.kullanici)
                        if let _ = ViewController.kullanici {
                            DispatchQueue.main.async(){
                                self.performSegue(withIdentifier: "SplashToCategories", sender: nil)
                            }
                            
                        } else {
                            DispatchQueue.main.async(){
                                self.performSegue(withIdentifier: "SplahToMain", sender: nil)
                            }
                        }
                        
                    } else {
                        print("CASE 6")
                        DispatchQueue.main.async(){
                            self.performSegue(withIdentifier: "SplahToMain", sender: nil)
                        }
                    }
                }
            } else {
                print("CASE 7")
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "SplahToMain", sender: nil)
                }
            }
        }
        
    }

}



extension UIViewController {
    
    
    func alarmVer( baslik : String , mesaj : String) {
        let alert = UIAlertController(title: baslik, message: mesaj, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func goLogin(){
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "QuizToCategory", sender: nil)
        }
        
    }
    
    func goCategory(){
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "QuizToCategory", sender: nil)
        }
        
    }
    
    func showSubsription(){
        let alert = UIAlertController(title: "Bir Dakika", message: "Bu içeriğe erişmek için bir abonelik satın almalısınız. Planlarımıza göz atarak size uygun bir plan seçebilirsiniz.", preferredStyle: .actionSheet)
        
        let okButton = UIAlertAction(title: "İncele", style: .default) { aksiyon in
            self.goBilling()
        }
        alert.addAction(okButton)
        
        let cancelButton = UIAlertAction(title: "İptal", style: .cancel) { aksiyon in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func klavyeKapat(){
        self.view.endEditing(false)
    }
    
    @objc func closeKeyboard(){
        self.view.endEditing(false)
    }
    
    func ekraniKapatma(){
        self.view.isUserInteractionEnabled = true
        let kapatGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(kapatGesture)
    }
    
    func ekranGoruntusuAl()->UIImage? {
        let scale = UIScreen.main.scale
        let bounds = self.view.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, scale)
        if let _ = UIGraphicsGetCurrentContext() {
            self.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        } else {
            return nil
        }
    }
    
    func ekranGoruntusuPaylasma(){
        DispatchQueue.main.async {
            if let currentScreen = self.ekranGoruntusuAl() {
                let shareActivity = UIActivityViewController(activityItems: [currentScreen], applicationActivities: nil)
                self.present(shareActivity, animated: true, completion: nil)
            }
        }
    }
    
    func uyelikKontrolu( kullanici : Kullanici , db : Database ){
        DispatchQueue.global().async {
            let currentPaket = kullanici.memberType
            if currentPaket != .standart {
                if let endDate = kullanici.subsriptionEndDate {
                    let currentDate = Date()
                    let difference = endDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
                    if difference < 0 {
                        if let uid = kullanici.uid {
                            
                            db.reference(withPath: "user").child(uid).child("memberType").setValue("standart")
                            DispatchQueue.main.sync {
                                self.showSubsription()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func gunduzMod(){
        overrideUserInterfaceStyle = .light
        ekraniKapatma()
    }
    
    // Segue Programatically
    
    func goBilling(){
        DispatchQueue.main.async {
            /*
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let billingViewController = storyBoard.instantiateViewController(withIdentifier: "billingViewController") as? BillingViewController{
                self.present(billingViewController, animated: true, completion: nil)
            }
             */
            
            let billingVC = BillingViewController()
            self.present(billingVC, animated: true, completion: nil)
        }
    }
    
    @objc func sayfaKapat(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func showTextInputPrompt(withMessage message: String,
                               completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
          completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
          guard let text = weakPrompt?.textFields?.first?.text else { return }
          completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
      }
    
}

