//
//  Message.swift
//  QuizVersion2
//
//  Created by Macbook on 21.07.2022.
//

import Foundation
struct Message : Hashable , Decodable {
    var id : String
    var message : String
    var userName : String
    var userUid : String
    var documentUrl : String?
    var sendDate : Date?
    var repliedMessage : String?
    var repliedSender : String?
    var cevaplananMesaj : String?
}
