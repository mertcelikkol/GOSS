//
//  QuizListAdapter.swift
//  QuizVersion2
//
//  Created by Macbook on 26.07.2022.
//

import Foundation

struct QuizListAdapter {
    var quizList : [QuizListModel]
    
    func numberOfRows() -> Int {
        return quizList.count
    }
    
    func selectedItem(index : Int) -> QuizViewHolder {
        return QuizViewHolder(quiz: quizList[index])
    }
}

struct QuizViewHolder {
    var quiz : QuizListModel
    
    var quiz_id : String {
        return quiz.quiz_id
    }
    
    var name : String {
        return quiz.name
    }
    
    var desc : String {
        return quiz.desc
    }
    
    var image : String {
        return quiz.image
    }
    
    var level : String {
        return quiz.level
    }
    
    var visibility : String {
        return quiz.visibility
    }
    
    var questions : Int {
        return quiz.questions
    }
}
