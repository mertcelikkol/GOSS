//
//  ResultsViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase

class ResultsViewController: UIViewController {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var percentText: UILabel!
    @IBOutlet weak var correctText: UILabel!
    @IBOutlet weak var wrongText: UILabel!
    @IBOutlet weak var unansweredText: UILabel!
    @IBOutlet weak var kategoriButton: UIButton!
    
    
    // Parametrelerin Tanımlanması
    var auth : Auth?
    var firestore : Firestore?
    var quizId : String?
    
    
    var dogruSayi : String = ""
    var yanlisSayi : String = ""
    var cevapsizSayi : String = ""
    var yuzde : String = ""
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            getData()
            
            
            kategoriButton.isUserInteractionEnabled = true
            let kategoriGesture = UITapGestureRecognizer(target: self, action: #selector(kategoriyeGit))
            kategoriButton.addGestureRecognizer(kategoriGesture)
            
            kategoriButton.backgroundColor = UIColor(red: 0, green: 188/255, blue: 212/255, alpha: 1)
            kategoriButton.layer.cornerRadius = 10
            
        }
        
        func getData(){
            if let quizId = quizId {
                
                if dogruSayi != "" && yanlisSayi != "" && cevapsizSayi != "" {
                    self.percentText.text = "\(yuzde) %"
                    self.correctText.text = "\(dogruSayi)"
                    self.wrongText.text = "\(yanlisSayi)"
                    self.unansweredText.text = "\(cevapsizSayi)"
                } else {
                    auth = Auth.auth()
                    
                    if let kullanici = auth?.currentUser {
                        firestore = Firestore.firestore()
                        firestore!.collection("QuizList").document(quizId).collection("Results").document(kullanici.uid).getDocument { snapshot, error in
                            if error == nil {
                                if let snapshot = snapshot {
                                    var correct = 0
                                    var unanswered = 0
                                    var answered = 0
                                    if let dogru = snapshot["correct"] as? Int {
                                        correct = dogru
                                    }
                                    if let cevapsiz = snapshot["unanswered"] as? Int {
                                        unanswered = cevapsiz
                                    }
                                    if let cevap = snapshot["wrong"] as? Int {
                                        answered = cevap
                                    }
                                    let toplam = correct + unanswered + answered
                                    var percent = correct*100 / 1
                                    if toplam != 0 {
                                        percent = correct*100 / toplam
                                    }
                                    
                                    
                                    self.percentText.text = "\(percent) %"
                                
                                    self.correctText.text = "\(correct)"
                                    self.wrongText.text = "\(answered)"
                                    self.unansweredText.text = "\(unanswered)"
                                }
                            }
                        }
                    } else {
                        kategoriyeGit()
                    }
                }
                
                
            } else {
                kategoriyeGit()
            }
            
        }
        
        @objc func kategoriyeGit(){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SonuctaKategoriSegue", sender: self)
            }
        }
}
