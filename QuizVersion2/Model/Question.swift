//
//  Question.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
struct Question : Hashable , Decodable {
    var answer : String?
    var option_a : String?
    var option_b : String?
    var option_c : String?
    var option_d : String?
    var option_e : String?
    var question : String?
    var timer : Int = 60
}
