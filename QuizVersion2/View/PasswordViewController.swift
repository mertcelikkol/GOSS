//
//  PasswordViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 30.07.2022.
//

import UIKit
import Firebase

class PasswordViewController: UIViewController {
    
    // Elemanların Tanımlanması
    
    @IBOutlet weak var kullaniciEmailText: UITextField!
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        closeButton.addTarget(self, action: #selector(self.sayfaKapat), for: .allTouchEvents)
    }
    
    
    
    @IBAction func submitPassword(_ sender: Any) {
        if let email = kullaniciEmailText.text {
            if email != "" {
                let auth = Auth.auth()
                auth.sendPasswordReset(withEmail: email) { error in
                    if error == nil {
                        self.alarmVer(baslik: "İşlem Başarılı", mesaj: "E-mail adresinize şifreniz gönderildi.")
                    } else {
                        if let error = error {
                            self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "Şifre gönderilemedi. İnternet bağlantınızdan emin olun.")
                        }
                    }
                }
            } else {
                self.alarmVer(baslik: "Hata", mesaj: "E-mail adresinizi gönderin.")
            }
        } else {
            self.alarmVer(baslik: "Hata", mesaj: "E-mail adresinizi gönderin.")
        }
    }
    

}
