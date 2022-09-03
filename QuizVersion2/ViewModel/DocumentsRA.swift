//
//  DocumentsRA.swift
//  QuizVersion2
//
//  Created by Macbook on 26.07.2022.
//

import Foundation

struct DocumentRecyclerAdapter {
    
    var documentList : [Document]
    
    func numberOfRows()->Int {
        return documentList.count
    }
    
    func selectedItem(index : Int)->DocumentViewHolder {
        return DocumentViewHolder(document: documentList[index])
    }
    
}


struct DocumentViewHolder {
    var document : Document
    
    var id : String {
        return document.id
    }
    
    var name : String {
        return document.name
    }
    
    var description : String {
        return document.description
    }
    
    var documentUrl : String {
        return document.documentUrl
    }
}
