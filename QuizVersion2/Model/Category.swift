//
//  Category.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation

struct Category : Decodable, Hashable {
    var category_id : String
    var name : String
    var description : String
    var image : String
    var level : String
    var visibility : String
    var quizzes : Int
}
