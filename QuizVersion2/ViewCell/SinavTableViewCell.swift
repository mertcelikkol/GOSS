//
//  SinavTableViewCell.swift
//  QuizVersion2
//
//  Created by Macbook on 2.08.2022.
//

import UIKit

class SinavTableViewCell: UITableViewCell {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var quizImage: UIImageView!
    
    @IBOutlet weak var quizTitle: UILabel!
    
    @IBOutlet weak var quizDescription: UILabel!
    
    @IBOutlet weak var quizDifficulty: UILabel!
    
    @IBOutlet weak var sinaviGorButton: UIButton!
    
    // Parametrelerin Tanımlanması
    
    var quizId : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
