//
//  QuizViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import Firebase
import AudioToolbox


class QuizViewController: UIViewController {
    
    // Elemanların Tanımlanması
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var reportProblemButton: UIButton!
    @IBOutlet weak var questionShareButton: UIButton!
    
    @IBOutlet weak var questionTitleText: UILabel!
    @IBOutlet weak var questionNumberText: UILabel!
    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var remainTimeText: UILabel!
    
    // Şıklar
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    
    @IBOutlet weak var resultText: UILabel!
    
    @IBOutlet weak var resultDetails: UILabel!
    
    @IBOutlet weak var nextQuestionButton: UIButton!
    
    
    // Parametrelerin Tanımlanması
    var auth : Auth?
    var firestore : Firestore?
    var categoryId : String? = CategoriesViewController.selectedCatId
    var currentUserId : String?
    static var quizName : String?
    static var questionNumber = 1
    var remainTime = 60
    var quizId : String?
    var guncelSoru : Question?
        
    // Buton Listesi
    var buttonListesi = [UIButton]()
        
    // Timer
    var timer : Timer?
        
    var allQuestionsList = [Question]()
    // var questionsToAnswer
        
        
    var canAnswer : Bool = false
    var currentQuestion = 0
    var correctAnswers = 0
    var wrongAnswers = 0
    var notAnswered = 0
        
    let shape = CAShapeLayer()
    let outCircle = CAShapeLayer()
        
    // var bannerView : GADBannerView!
    var kullanici = ViewController.kullanici
    



    override func viewDidLoad() {
            super.viewDidLoad()
            gunduzMod()
            resultDetails.numberOfLines = 0
            nextQuestionButton.backgroundColor = UIColor(red: 0, green: 188/255, blue: 212/255, alpha: 1)
            nextQuestionButton.layer.cornerRadius = 10
            if let categoryId = categoryId {
                getData(kategori_id: categoryId)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            // Do any additional setup after loading the view.
            buttonListesi = [firstButton,secondButton,thirdButton,fourthButton,fifthButton]
            
            for tiklanan in buttonListesi {
                tiklanan.addTarget(self, action: #selector(butonaTiklandi(_:)), for: .touchUpInside)
                tiklanan.titleLabel?.numberOfLines = 0
                tiklanan.layer.borderWidth = 1
                tiklanan.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                tiklanan.layer.cornerRadius = 10
                tiklanan.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                tiklanan.layoutMarginsDidChange()
            }
            
            questionShareButton.isUserInteractionEnabled = true
            let paylasmaGesture = UITapGestureRecognizer(target: self, action: #selector(paylasmaOlayi))
            questionShareButton.addGestureRecognizer(paylasmaGesture)
            
            
            // Circular Animation
            circularAnimation()
            resultText.isHidden = true
            resultDetails.isHidden = true
            
        
            let nextGestureRecog = UITapGestureRecognizer(target: self, action: #selector(yeniSoruYukle))
            nextQuestionButton.addGestureRecognizer(nextGestureRecog)
            
        
            // Reklam Olayı
            /*
            bannerView = GADBannerView(frame: adsView.frame)
            bannerView.rootViewController = self
            addBannerViewToView(bannerView)
            if let kullanici = kullanici {
                print("NEREYE GİRİYOR 1")
                if kullanici.memberType != .standart {
                    self.adsView.frame.size.height = 0
                }
            } else {
                print("NEREYE GİRİYOR 2")
                if let guncel = auth?.currentUser {
                    print("NEREYE GİRİYOR 3")
                   
                    
                }
                
            }
            */
        }
        /*
        func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            view.addConstraints(
              [NSLayoutConstraint(item: bannerView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: adsView,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0),
               NSLayoutConstraint(item: bannerView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: adsView,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
            bannerView.adUnitID = "ca-app-pub-6292749914687688/9897219513"
            bannerView.load(GADRequest())
           }
        */
        func circularAnimation(){
            // remainTimeText.frame.origin.x - remainTimeText.frame.width / 10
            let merkezAyarlama = CGPoint(x: UIScreen.main.bounds.width - (50), y: remainTimeText.frame.origin.y + remainTimeText.frame.height / 2)
            // Boş Daire
            let circlePath = UIBezierPath(arcCenter: merkezAyarlama, radius: 30, startAngle: -(.pi / 2), endAngle: .pi * 2 , clockwise: true)
            
            // Outer Circler
            let emptyCircler = CAShapeLayer()
            emptyCircler.path = circlePath.cgPath
            emptyCircler.lineWidth = 5
            emptyCircler.strokeColor = UIColor.white.cgColor
            emptyCircler.fillColor = UIColor.clear.cgColor
            self.view.layer.addSublayer(emptyCircler)
            
            
            shape.path = circlePath.cgPath
            shape.lineWidth = 5
            shape.strokeColor = UIColor.green.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeEnd = 0
            self.view.layer.addSublayer(shape)
            
            
            
        }
        
        func getData( kategori_id : String ){
            auth = Auth.auth()
            if let kullanici = auth?.currentUser {
                currentUserId = kullanici.uid
                if let quizId = quizId {
                    firestore = Firestore.firestore()
                    // Get Quiz Details
                    firestore?.collection("categories").document(kategori_id).collection("quizzes").document(quizId).getDocument(completion: { querySnapshot, error in
                        if error == nil {
                            if let querySnapshot = querySnapshot {
                                let quiz = QuizListModel(quiz_id: quizId, name: querySnapshot["name"] as? String ?? "", desc: querySnapshot["desc"] as? String ?? "", image: querySnapshot["image"] as? String ?? "", level: querySnapshot["level"] as? String ?? "", visibility: querySnapshot["visibility"] as? String ?? "", questions: querySnapshot["questions"] as? Int ?? 0)
                                
                                QuizViewController.quizName = quiz.name
                                
                                
                                
                                self.firestore?.collection("categories").document(kategori_id).collection("quizzes").document(quizId).collection("questions").getDocuments(completion: { dokuman, hata in
                                    if hata == nil {
                                        if let dokuman = dokuman {
                                            self.allQuestionsList.removeAll()
                                            for argumanEleman in dokuman.documents {
                                                let soru = Question(answer: argumanEleman["answer"] as? String ?? "", option_a: argumanEleman["option_a"] as? String ?? "", option_b: argumanEleman["option_b"] as? String ?? "", option_c: argumanEleman["option_c"] as? String ?? "", option_d: argumanEleman["option_d"] as? String ?? "", option_e: argumanEleman["option_e"] as? String ?? "", question: argumanEleman["question"] as? String ?? "", timer: argumanEleman["timer"] as? Int ?? 1)
                                                self.allQuestionsList.append(soru)
                                            }
                                            self.yerleriDoldur(currentIndex: QuizViewController.questionNumber, questionList: self.allQuestionsList)
                                            
                                        }
                                    } else {
                                        self.alarmVer(baslik: "Hata", mesaj: "Sorular yüklenemedi")
                                        self.goCategory()
                                    }
                                })
                                
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
                    self.goCategory()
                }
            } else {
                self.goLogin()
            }
            
        }
        
        @objc func sayacAyari(){
            self.remainTime = self.remainTime - 1
            if self.remainTime < 1 {
                self.remainTime = 0
                self.remainTimeText.text = "\(self.remainTime)"
                sureDolduOtomatikGecis()
            } else {
                self.remainTimeText.text = "\(self.remainTime)"
                if self.remainTime < 10 {
                    self.shape.strokeColor = UIColor.red.cgColor
                } else {
                    if self.remainTime < 16 {
                        self.shape.strokeColor = UIColor.yellow.cgColor
                    } else {
                        self.shape.strokeColor = UIColor.green.cgColor
                    }
                    
                }
            }
            
        }
        
        func sureDolduOtomatikGecis(){
            resultText.isHidden = false
            resultDetails.isHidden = false
            if let aktifSoru = guncelSoru {
                let metin = "\(String(describing: aktifSoru.answer!))"
                let alert = UIAlertController(title: "Süreniz Doldu", message: metin, preferredStyle: .actionSheet)
                let siradaki = UIAlertAction(title: "Sıradaki Soruya Geç", style: .default) { aksiyon in
                    // Yeni Soru Yükleme Fonksiyonu
                    
                    alert.dismiss(animated: true) {
                        self.yeniSoruYukle()
                    }
                }
                let anasayfa = UIAlertAction(title: "Anasayfaya Dön", style: .default) { aksiyon in
                    self.timer?.invalidate()
                    self.goLogin()
                }
                let cancel = UIAlertAction(title: "Geç", style: .cancel) { aksiyon in
                    self.timer?.invalidate()
                }
                
                alert.addAction(siradaki)
                alert.addAction(anasayfa)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                
            }
        }
        
        func butonlariPasiflestir(){
            for tiklanan in buttonListesi {
                tiklanan.isUserInteractionEnabled = false
            }
        }
        func butonlariAktiflestir(){
            for tiklanan in buttonListesi {
                tiklanan.isUserInteractionEnabled = true
                tiklanan.backgroundColor = UIColor.clear
            }
        }
        
        @objc func yeniSoruYukle(){
            // Soruyu kontrol edip sınav bittiyse sonuc sayfasına yonlendir
            if QuizViewController.questionNumber < allQuestionsList.count {
                
                if QuizViewController.questionNumber  == allQuestionsList.count - 1 {
                    nextQuestionButton.setTitle("Sınavı Tamamla", for: .highlighted)
                } else {
                    nextQuestionButton.setTitle("Sıradaki Soru", for: .highlighted)
                }
                self.resultText.text = ""
                self.resultDetails.text = ""
                
                var currentIndex = QuizViewController.questionNumber
                print("CURRENT INDEX : \(currentIndex)")
                if let sayi = self.questionNumberText.text {
                    let number = Int(sayi) ?? 0
                    currentIndex = number + 1
                    print("UPDATED CURRENT INDEX : \(currentIndex)")
                }
                yerleriDoldur(currentIndex: currentIndex, questionList: allQuestionsList)
                butonlariAktiflestir()
            } else {
                // Sonuçları Kaydet
                if let quizId = quizId {
                    
                    let soruSayisi = self.allQuestionsList.count - 1
                    
                    let cevapToplam = correctAnswers + wrongAnswers
                    
                    // Sonuç Sayılarının Kontrolü
                    notAnswered = soruSayisi - cevapToplam
                    
                    let sonuc = [
                        "correct" : correctAnswers,
                        "wrong" : wrongAnswers,
                        "unanswered" : notAnswered
                    ] as [String : Any]
                    print("SONUC LİSTESİ")
                    print(sonuc)
                    firestore?.collection("QuizList").document(quizId).collection("Results").document(currentUserId!).setData(sonuc, completion: { error in
                        self.timer?.invalidate()
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "ResultSegue", sender: self)
                        }
                    })
                }
            }
        }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("BURASI ÇAĞRILIYOR MU")
        if segue.identifier == "ResultSegue" {
            if let hucre = segue.destination as? ResultsViewController {
                hucre.quizId = self.quizId
                hucre.dogruSayi = "\(correctAnswers)"
                hucre.yanlisSayi = "\(wrongAnswers)"
                hucre.cevapsizSayi = "\(notAnswered)"
                
                let toplam = correctAnswers + notAnswered + wrongAnswers
                var percent = correctAnswers*100 / 1
                if toplam != 0 {
                    percent = correctAnswers*100 / toplam
                }
                hucre.yuzde = "\(percent)"
            }
        }
    }
    
        
        func yerleriDoldur( currentIndex : Int, questionList : [Question] ){
            
            DispatchQueue.main.async {
                self.questionTitleText.text = QuizViewController.quizName
                self.questionNumberText.text = "\(currentIndex)"
                
                if currentIndex < questionList.count {
                    let gelenGuncelSoru = questionList[currentIndex]
                    self.canAnswer = false
                    let animate = CABasicAnimation(keyPath: "strokeEnd")
                    self.remainTime = gelenGuncelSoru.timer
                    animate.toValue = 1
                    animate.duration = CFTimeInterval(self.remainTime)
                    animate.fillMode = .forwards
                    self.shape.add(animate, forKey: "animation")
                    
                    
                    
                    QuizViewController.questionNumber = currentIndex
                    self.guncelSoru = gelenGuncelSoru
                    self.questionText.text = gelenGuncelSoru.question
                    self.questionText.autoresizesSubviews = true
                    self.questionText.sizeToFit()
                    
                    var scrollWidth = CGFloat(0)
                    var scrollHeight = CGFloat(200)
                    
                    if let cevapA = gelenGuncelSoru.option_a {
                        self.firstButton.isHidden = false
                        self.firstButton.setTitle(cevapA, for: .normal)
                        self.firstButton.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                        self.firstButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.firstButton.layoutMarginsDidChange()
                        
                        if scrollWidth < self.firstButton.frame.size.width {
                            scrollWidth = self.firstButton.frame.size.width
                        }
                        scrollHeight = scrollHeight + self.firstButton.frame.size.height
                    } else {
                        self.firstButton.isHidden = true
                    }
                    
                    
                    if let cevapB = gelenGuncelSoru.option_b {
                        self.secondButton.isHidden = false
                        self.secondButton.setTitle(cevapB, for: .normal)
                        self.secondButton.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                        self.secondButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.secondButton.layoutMarginsDidChange()
                        
                        if scrollWidth < self.secondButton.frame.size.width {
                            scrollWidth = self.secondButton.frame.size.width
                        }
                        scrollHeight = scrollHeight + self.secondButton.frame.size.height
                    } else {
                        self.secondButton.isHidden = true
                    }
                    
                    
                    if let cevapC = gelenGuncelSoru.option_c {
                        self.thirdButton.isHidden = false
                        self.thirdButton.setTitle(cevapC, for: .normal)
                        self.thirdButton.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                        self.thirdButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.thirdButton.layoutMarginsDidChange()
                        
                        if scrollWidth < self.thirdButton.frame.size.width {
                            scrollWidth = self.thirdButton.frame.size.width
                        }
                        scrollHeight = scrollHeight + self.thirdButton.frame.size.height
                    } else {
                        self.thirdButton.isHidden = true
                    }
                    
                    if let cevapD = gelenGuncelSoru.option_d {
                        self.fourthButton.isHidden = false
                        self.fourthButton.setTitle(cevapD, for: .normal)
                        self.fourthButton.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                        self.fourthButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.fourthButton.layoutMarginsDidChange()
                        
                        if scrollWidth < self.fourthButton.frame.size.width {
                            scrollWidth = self.fourthButton.frame.size.width
                        }
                        scrollHeight = scrollHeight + self.fourthButton.frame.size.height
                    } else {
                        self.fourthButton.isHidden = true
                    }
                    
                    if let cevapE = gelenGuncelSoru.option_e {
                        self.fifthButton.isHidden = false
                        self.fifthButton.setTitle(cevapE, for: .normal)
                        self.fifthButton.layer.borderColor = UIColor(red: 5/255, green: 1, blue: 1, alpha: 1).cgColor
                        self.fifthButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.fifthButton.layoutMarginsDidChange()
                        
                        if scrollWidth < self.fifthButton.frame.size.width {
                            scrollWidth = self.fifthButton.frame.size.width
                        }
                        scrollHeight = scrollHeight + self.fifthButton.frame.size.height
                    } else {
                        self.fifthButton.isHidden = true
                    }
                    
                    // ScrollView Ayarla
                    
                    scrollHeight = scrollHeight + CGFloat(50)
                    self.scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
                    
                    
                    self.resultText.isHidden = false
                    self.resultDetails.isHidden = false
                    self.questionText.text = gelenGuncelSoru.question
                    self.timer?.invalidate()
                    // Timer Initialization
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sayacAyari), userInfo: nil, repeats: true)
                } else {
                    // Sonuç sayfasına yönlendirebilirsin
                    
                    if let quizId = self.quizId {
                        
                        let soruSayisi = self.allQuestionsList.count - 1
                        
                        let cevapToplam = self.correctAnswers + self.wrongAnswers
                        
                        // Sonuç Sayılarının Kontrolü
                        self.notAnswered = soruSayisi - cevapToplam
                        
                        let sonuc = [
                            "correct" : self.correctAnswers,
                            "wrong" : self.wrongAnswers,
                            "unanswered" : self.notAnswered
                        ] as [String : Any]
                        print("SONUC LİSTESİ")
                        print(sonuc)
                        self.firestore?.collection("QuizList").document(quizId).collection("Results").document(self.currentUserId!).setData(sonuc, completion: { error in
                            self.timer?.invalidate()
                            self.performSegue(withIdentifier: "ResultSegue", sender: self)
                        })
                    } else {
                        self.performSegue(withIdentifier: "ResultSegue", sender: self)
                    }
                    
                }
            }
             
        }
        
        // Tıklanma Olayları - Seçenek İşaretleme
        @objc func butonaTiklandi(_ algilama : UIButton? ){
            canAnswer = true
            
            var durum = 0
            if let tiklanan = algilama {
                print(tiklanan)
                let givenAnswer = tiklanan.currentTitle
                if let guncelSoru = guncelSoru {
                    let cevap = guncelSoru.answer
                    
                    if cevap == givenAnswer {
                        // Doğru Cevap
                        tiklanan.layer.backgroundColor = UIColor.green.cgColor
                        
                        resultText.text = "Doğru Cevap"
                        resultText.textColor = UIColor.green
                        durum = 1
                        resultDetails.text = "Doğru Cevap : \(String(describing: cevap!))"
                        resultDetails.textColor = UIColor.green
                        resultText.isHidden = false
                        resultDetails.isHidden = false
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        var mevcutScrollHeight = self.scrollView.contentSize.height
                        mevcutScrollHeight = mevcutScrollHeight + resultText.frame.size.height
                        mevcutScrollHeight = mevcutScrollHeight + resultDetails.frame.size.height + CGFloat(50)
                        
                        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: mevcutScrollHeight)
                        
                    } else {
                        AudioServicesPlayAlertSound(1105)
                        if canAnswer {
                            // Yanlış Cevap
                            durum = 2
                            tiklanan.layer.backgroundColor = UIColor.red.cgColor
                            
                            
                            resultText.text = "Yanlış Cevap"
                            resultText.textColor = UIColor.red
                            resultDetails.text = "Doğru Cevap : \(String(describing: cevap!))"
                            resultDetails.textColor = UIColor.red
                            resultText.isHidden = false
                            resultDetails.isHidden = false
                            
                            var mevcutScrollHeight = self.scrollView.contentSize.height
                            mevcutScrollHeight = mevcutScrollHeight + resultText.frame.size.height
                            mevcutScrollHeight = mevcutScrollHeight + resultDetails.frame.size.height + CGFloat(50)
                            
                            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: mevcutScrollHeight)
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
            
            DispatchQueue.main.async {
                self.butonlariPasiflestir()
                
            }
            switch durum {
            
                
            case 1:
                self.correctAnswers = self.cevaplandi(sayi: self.correctAnswers)
            case 2:
                self.wrongAnswers = self.cevaplandi(sayi: self.wrongAnswers)
            default:
                print("CEVAPSIZ")
            }
            print("DOĞRU SAYISI \(self.correctAnswers)")
            print("Yanlış SAYISI \(self.wrongAnswers)")
            print("Cevapsız SAYISI \(self.notAnswered)")
            
             
        }
        
        @objc func paylasmaOlayi(){
            self.ekranGoruntusuPaylasma()
        }
        
        
        
        func cevaplandi(sayi : Int) -> Int {
            let donen = sayi + 1
            return donen
        }
    
    
    
    

}
