//
//  QuizListModel.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
struct QuizListModel : Hashable,Decodable {
    var quiz_id : String
    var name : String
    var desc : String
    var image : String
    var level : String
    var visibility : String
    var questions : Int
}
