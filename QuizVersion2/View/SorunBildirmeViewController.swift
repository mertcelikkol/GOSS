//
//  SorunBildirmeViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase

class SorunBildirmeViewController: UIViewController {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var konuText: UITextField!
    
    @IBOutlet weak var mesajText: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    // Parametrelerin Tanımlanması
    
    

    override func viewDidLoad() {
            super.viewDidLoad()
            gunduzMod()
            // Do any additional setup after loading the view.
            
            closeButton.isUserInteractionEnabled = true
            let closeGesture = UITapGestureRecognizer(target: self, action: #selector(ekraniKapat))
            closeButton.addGestureRecognizer(closeGesture)
            
            submitButton.addTarget(self, action: #selector(sorunBildir), for: .allTouchEvents)
            
        }
        
        @objc func ekraniKapat(){
            self.dismiss(animated: true, completion: nil)
        }
        
        @objc func sorunBildir(){
            if let subject = konuText.text {
                if subject != "" {
                    if let message = mesajText.text {
                        if message != "" {
                            let auth = Auth.auth()
                            let firestore = Firestore.firestore()
                            if let user = auth.currentUser?.uid {
                                let quizName = QuizViewController.quizName ?? ""
                                let question = QuizViewController.questionNumber
                                let saveData = [
                                    "subject" : subject,
                                    "message" : message,
                                    "user" : user,
                                    "date" : FieldValue.serverTimestamp(),
                                    "quizName" : quizName,
                                    "question" : question
                                ] as [String : Any]
                                firestore.collection("questionReports").addDocument(data: saveData) { error in
                                    if error == nil {
                                        let alert = UIAlertController(title: "Sorununuzu Aldık", message: "En yakın zamanda sorununuzu gidereceğiz.", preferredStyle: .alert)
                                        let okButton = UIAlertAction(title: "Tamam", style: .default) { aksiyon in
                                            self.ekraniKapat()
                                        }
                                        alert.addAction(okButton)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        self.alarmVer(baslik: "Hata", mesaj: error?.localizedDescription ?? "İnterner bağlantınızdan emin olun.")
                                    }
                                }
                            } else {
                                let user = "Kullanıcı Bulunamadı"
                                let quizName = QuizViewController.quizName ?? ""
                                let question = QuizViewController.questionNumber
                                let saveData = [
                                    "subject" : subject,
                                    "message" : message,
                                    "user" : user,
                                    "date" : FieldValue.serverTimestamp(),
                                    "quizName" : quizName,
                                    "question" : question
                                ] as [String : Any]
                                firestore.collection("questionReports").addDocument(data: saveData) { error in
                                    if error == nil {
                                        let alert = UIAlertController(title: "Sorununuzu Aldık", message: "En yakın zamanda sorununuzu gidereceğiz.", preferredStyle: .alert)
                                        let okButton = UIAlertAction(title: "Tamam", style: .default) { aksiyon in
                                            self.ekraniKapat()
                                        }
                                        alert.addAction(okButton)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        self.alarmVer(baslik: "Hata", mesaj: error?.localizedDescription ?? "İnterner bağlantınızdan emin olun.")
                                    }
                                }
                            }
                        } else {
                            self.alarmVer(baslik: "Hata", mesaj: "Lütfen mesajınızı belirtiniz.")
                        }
                    } else {
                        self.alarmVer(baslik: "Hata", mesaj: "Lütfen mesajınızı belirtiniz.")
                    }
                } else {
                    self.alarmVer(baslik: "Hata", mesaj: "Lütfen konu belirtiniz.")
                }
            } else {
                self.alarmVer(baslik: "Hata", mesaj: "Lütfen konu belirtiniz.")
            }
            
        }
    

}
