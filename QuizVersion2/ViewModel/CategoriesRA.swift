//
//  CategoriesRA.swift
//  QuizVersion2
//
//  Created by Macbook on 26.07.2022.
//

import Foundation

struct CategoryRecyclerAdapter {
    var categoryList : [Category]
    
    func numberOfRows()->Int {
        return categoryList.count
    }
    
    func selectedItem(index : Int)->CategoryViewHolder{
        return CategoryViewHolder(category: categoryList[index])
    }
    
}

struct CategoryViewHolder {
    let category : Category
    
    var category_id : String {
        return category.category_id
    }
    
    var name : String {
        return category.name
    }
    
    var description : String {
        return category.description
    }
    
    var image : String {
        return category.image
    }
    
    var level : String {
        return category.level
    }
    
    var visibility : String {
        return category.visibility
    }
    
    var quizzes : Int {
        return category.quizzes
    }
    
}
