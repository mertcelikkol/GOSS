//
//  Document.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
struct Document : Hashable, Decodable {
    var id : String
    var name : String
    var description : String
    var documentUrl : String
}
