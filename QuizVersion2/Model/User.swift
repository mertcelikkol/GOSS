//
//  User.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
enum MemberType {
    case standart
    case premium
    case gold
}
struct Kullanici {
    var uid : String?
    var userName : String?
    var mail : String?
    var password : String?
    var memberType : MemberType
    var subsriptionEndDate : Date? = nil
}
