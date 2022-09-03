//
//  CategoriesTableViewCell.swift
//  QuizVersion2
//
//  Created by Macbook on 1.08.2022.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var categoryImage: UIImageView!
    
    
    @IBOutlet weak var categoriTitle: UILabel!
    
    
    @IBOutlet weak var categoryDesription: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    
    
    @IBOutlet weak var dokumanButton: UIButton!
    
    
    @IBOutlet weak var quizButton: UIButton!
    
    var category_id : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
