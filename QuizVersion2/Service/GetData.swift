//
//  GetData.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
import Firebase
enum Mert {
    case Celikkol
    case Kral
    case Girisimci
}
enum Hata : Error {
    case internet
    case noData
    case unknown
}
class GetData {
    let kullanici : Kullanici
    let db : Firestore
    
    init(kullanici : Kullanici , database : Firestore) {
        self.kullanici = kullanici
        self.db = database
    }
    
    func getQuestions(quiz_id : String , completion : @escaping ([Question]?,Error?) -> () ) {
        
        db.collection("QuizList").document(quiz_id).collection("Questions").addSnapshotListener { querySnapshot, error in
            if error == nil {
                if let querySnapshot = querySnapshot {
                    var questionList = [Question]()
                    for eleman in querySnapshot.documents {
                        let bir = eleman.data()
                        let question = Question(answer: bir["answer"] as? String, option_a: bir["option_a"] as? String, option_b: bir["option_b"] as? String, option_c: bir["option_c"] as? String, option_d: bir["option_d"] as? String, option_e: bir["option_e"] as? String, question: bir["question"] as? String, timer: bir["timer"] as? Int ?? 60)
                        questionList.append(question)
                    }
                    completion(questionList, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
        
    }
    
    func question(index : Int , list : [Question]) -> Question? {
        if index < list.count {
            let selected = list[index]
            return selected
        } else {
            return nil
        }
    }
    
    func sonucGetir(quiz_id : String , completion : @escaping (Sonuc?,Error?) -> ()) {
        if let user_id = kullanici.uid {
            db.collection("QuizList").document(quiz_id).collection("Results").document(user_id).addSnapshotListener { snapshot, error in
                if error == nil {
                    completion(nil, error)
                }
                if let veri = snapshot {
                    
                    let sonuc = Sonuc(kullanici: self.kullanici, correct: veri.get("correct") as? String ?? "0", unanswered: veri.get("unanswered") as? String ?? "0", wrong: veri.get("wrong") as? String ?? "0")
                    
                    completion(sonuc, nil)
                }
            }
        }
        
    }
    
    func dokumanGetir(category_id : String , completion : @escaping ([Document]? , Error?) -> ()) {
        db.collection("Categories").document(category_id).collection("documents").addSnapshotListener { querySnapshot, error in
            
            if let querySnapshot = querySnapshot {
                var documentList = [Document]()
                for documan in querySnapshot.documents {
                    let dokuman = Document(id: documan.documentID, name: documan.get("name") as? String ?? "", description: documan.get("description") as? String ?? "", documentUrl: documan.get("documentUrl") as? String ?? "")
                    documentList.append(dokuman)
                }
                
                completion(documentList, nil)
                
            } else {
                if error == nil {
                    completion(nil, nil)
                } else {
                    completion(nil, error)
                }
                
            }
        }
    }
    
    func dokuman(index : Int , list : [Document]) -> Document? {
        if index < list.count {
            let dokuman = list[index]
            return dokuman
        } else {
            return nil
        }
    }
    
    func getQuizzes(category_id : String , completion : @escaping ([QuizListModel]?, Error?) -> ()) {
        db.collection("Categories").document(category_id).collection("quizzes").addSnapshotListener { querySnapshot, error in
            if error == nil {
                if let querySnapshot = querySnapshot {
                    var quizList = [QuizListModel]()
                    for quiz in querySnapshot.documents {
                        let birim = QuizListModel(quiz_id: quiz.documentID, name: quiz.get("name") as? String ?? "", desc: quiz.get("desc") as? String ?? "", image: quiz.get("image") as? String ?? "", level: quiz.get("level") as? String ?? "", visibility: quiz.get("visibility") as? String ?? "", questions: quiz.get("questions") as? Int ?? 0)
                        quizList.append(birim)
                    }
                    completion(quizList, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getQuizList(completion : @escaping ([QuizListModel]? , Hata?) -> () ){
        db.collection("QuizList").addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(nil, .internet)
            }
            
            if let querySnapshot = querySnapshot {
                var returnList = [QuizListModel]()
                for birim in querySnapshot.documents {
                    let eleman = QuizListModel(quiz_id: birim.documentID, name: birim.get("name") as? String ?? "", desc: birim.get("desc") as? String ?? "", image: birim.get("image") as? String ?? "", level: birim.get("level") as? String ?? "", visibility: birim.get("visibility") as? String ?? "", questions: birim.get("questions") as? Int ?? 0)
                    
                    returnList.append(eleman)
                    
                }
                completion(returnList, nil)
            } else {
                completion(nil, .noData)
            }
            
        }
    }
    
    func getCategories(completion : @escaping ([Category]? , Hata?) -> ()) {
        db.collection("Categories").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, .internet)
            }
            
            if let querySnapshot = querySnapshot {
                var returnList = [Category]()
                for birim in querySnapshot.documents {
                    let eleman = Category(category_id: birim.documentID, name: birim.get("name") as? String ?? "", description: birim.get("description") as? String ?? "", image: birim.get("image") as? String ?? "", level: birim.get("level") as? String ?? "", visibility: birim.get("visibility") as? String ?? "", quizzes: birim.get("quizzes") as? Int ?? 0)
                    
                    returnList.append(eleman)
                }
                
                completion(returnList, nil)
            } else {
                completion(nil, .noData)
            }
            
        }
    }
    
    func getMessages(completion : @escaping ([Message]? , Hata?) -> ()) {
        db.collection("Chat").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, .internet)
            }
            
            if let querySnapshot = querySnapshot {
                var returnList = [Message]()
                for birim in querySnapshot.documents {
                    let eleman = Message(id: birim.documentID, message: birim.get("message") as? String ?? "", userName: birim.get("userName") as? String ?? "", userUid: birim.get("userUid") as? String ?? "", documentUrl: birim.get("documentUrl") as? String ?? "", sendDate: birim.get("sendDate") as? Date, repliedMessage: birim.get("repliedMessage") as? String ?? "", repliedSender: birim.get("repliedSender") as? String ?? "", cevaplananMesaj: birim.get("cevaplananMesaj") as? String ?? "")
                    returnList.append(eleman)
                }
                completion(returnList, nil)
            } else {
                completion(nil, .noData)
            }
            
        }
    }
    
    
    
    func getTestFunc(durum : Int, completion : @escaping (Mert,Hata,String) -> () ){
        if durum == 1 {
            completion(.Kral, .noData, "Olmadı Kardes")
        } else {
            completion(.Celikkol, .internet, "Basarili Kardes")
        }
    }
    
}
