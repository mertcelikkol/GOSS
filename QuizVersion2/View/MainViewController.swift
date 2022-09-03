//
//  MainViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 30.07.2022.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    //Elemanların Tanımlanması
    
    
    // Parametrelerin Tanımlanması
    var kullanici : Kullanici? = ViewController.kullanici

    override func viewDidLoad() {
        super.viewDidLoad()
        print("BAKALIM 2")
        gunduzMod()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpMemberType()
    }
    
    func setUpMemberType(){
        print("FONKSİYON ÇAĞRILIYOR MU ACABA")
        var memberType = "standart"
        let database = Database.database()
        let reference = database.reference()
        if let kullanici = kullanici {
            let currentDate = Date()
            if let endDate = kullanici.subsriptionEndDate {
                let difference = endDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970
                if difference > 0 {
                    if kullanici.memberType == .premium {
                        memberType = "premium"
                    } else if kullanici.memberType == .gold {
                        memberType = "gold"
                    }
                } else {
                    if kullanici.memberType == .premium {
                        memberType = "premium"
                    } else if kullanici.memberType == .gold {
                        memberType = "gold"
                    }
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainToLogin", sender: nil)
            }
            
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainToLogin", sender: nil)
            }
        }
    }
    
}
