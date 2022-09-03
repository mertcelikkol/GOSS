//
//  MeMessageTableViewCell.swift
//  QuizVersion2
//
//  Created by Macbook on 8.08.2022.
//

import UIKit

class MeMessageTableViewCell: UITableViewCell {

    // Elemanları Tanımlanması
    
    @IBOutlet weak var verticalStack: UIStackView!
    
    @IBOutlet weak var documentButton: UIButton!
    
    var messageId : String?
    var documnetUrl : String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
