//
//  ChatRA.swift
//  QuizVersion2
//
//  Created by Macbook on 26.07.2022.
//

import Foundation

struct ChatRecyclerAdapter {
    var messageList : [Message]
    
    func numberOfRows() -> Int {
        return messageList.count
    }
    
    func selectedItem(index: Int)->ChatViewHolder {
        return ChatViewHolder(chat: messageList[index])
    }
    
}

struct ChatViewHolder {
    var chat : Message
    
    
    var id : String {
        return chat.id
    }
    
    var message : String {
        return chat.message
    }
    
    var userName : String {
        return chat.userName
    }
    
    var userUid : String {
        return chat.userUid
    }
    
    var documentUrl : String? {
        return chat.documentUrl
    }
    
    var sendDate : Date? {
        return chat.sendDate
    }
    
    var repliedMessage : String? {
        return chat.repliedMessage
    }
    
    var repliedSender : String? {
        return chat.repliedSender
    }
    
    var cevaplananMesaj : String? {
        return chat.cevaplananMesaj
    }
}
