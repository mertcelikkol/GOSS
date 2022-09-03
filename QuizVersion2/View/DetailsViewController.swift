//
//  DetailsViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase
import SDWebImage


class DetailsViewController: UIViewController {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var quizImage: UIImageView!
    @IBOutlet weak var quizTitle: UILabel!
    @IBOutlet weak var quizDescription: UILabel!
    @IBOutlet weak var quizZorluk: UILabel!
    @IBOutlet weak var quizSoru: UILabel!
    
    @IBOutlet weak var quizStartButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    // Parametrelerin Tanımlanması
    var quizId : String?
    var currentQuiz : QuizListModel?
    var auth : Auth?
    var firestore : Firestore?
    var categori_id : String? = CategoriesViewController.selectedCatId
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizStartButton.addTarget(self, action: #selector(goQuizes), for: .allTouchEvents)
        quizTitle.numberOfLines = 0
                
        quizStartButton.backgroundColor = UIColor(red: 0, green: 188/255, blue: 212/255, alpha: 1)
        quizStartButton.layer.cornerRadius = 10
                
                
        getData()
        
        backButton.addTarget(self, action: #selector(self.sayfaKapat), for: .allTouchEvents)
         
    }
    
    func getData(){
            print("FONKSİYON ÇAĞRILDI")
            auth = Auth.auth()
            if let currentQuiz = currentQuiz {
                print("DURAK 1")
                quizImage.sd_setImage(with: URL(string: currentQuiz.image), completed: nil)
                quizDescription.text = currentQuiz.desc
                quizTitle.text = currentQuiz.name
                quizZorluk.text = currentQuiz.level
                quizSoru.text = "\(currentQuiz.questions) soru"
                
            } else {
                print("DURAK 2")
                if let quizId = quizId {
                    print("DURAK 3 QUIZ ID : \(quizId)")
                        
                    firestore = Firestore.firestore()
                    firestore!.collection("categories").document(categori_id!).collection("quizzes").document(quizId).getDocument(completion: { snapshot, error in
                            if error == nil {
                                if let quiz = snapshot {
                                    self.currentQuiz = QuizListModel(quiz_id: quiz.documentID, name: quiz["name"] as? String ?? "", desc: quiz["desc"] as? String ?? "", image: quiz["image"] as? String ?? "", level: quiz["level"] as? String ?? "", visibility: quiz["visibility"] as? String ?? "", questions: quiz["questions"] as? Int ?? 0)
                                    self.quizImage.sd_setImage(with: URL(string: self.currentQuiz!.image), completed: nil)
                                    self.quizDescription.text = self.currentQuiz!.desc
                                    self.quizTitle.text = self.currentQuiz!.name
                                    self.quizZorluk.text = self.currentQuiz!.level
                                    self.quizSoru.text = "\(self.currentQuiz!.questions) soru"
                                    self.quizId = quiz.documentID
                                    
                                    
                                } else {
                                    self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hata oluştu. İnternet bağlantınızdan emin olun.")
                                }
                            } else {
                                if let error = error {
                                    self.alarmVer(baslik: "Hata", mesaj: error.localizedDescription)
                                } else {
                                    self.alarmVer(baslik: "Hata", mesaj: "Beklenmedik bir hata oluştu. İnternet bağlantınızdan emin olun.")
                                }
                            }
                        })
                    
                    
                } else {
                    // Başka bir sayfaya yönlendir -> Kategoriler Sayfası
                    print("DURAK 4")
                }
            }
        }
        
    
    @objc func goQuizes(){
            // Seçilen Quiz Yoksa QuizListViewController'a geri götür
            /*
            let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6292749914687688/5415361713",
                                            request: request,
                                  completionHandler: { [self] ad, error in
                                    if let error = error {
                                        performSegue(withIdentifier: "QuizSegue", sender: self)
                                      return
                                    }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                                  })
             
             */
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "BaslaSegue", sender: self)
            }
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "BaslaSegue" {
                if let sayfa = segue.destination as? QuizViewController {
                    QuizViewController.quizName = quizTitle.text
                    sayfa.quizId = quizId
                }
            }
        }

}
