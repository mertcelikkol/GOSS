//
//  DocumentsTableViewCell.swift
//  QuizVersion2
//
//  Created by Macbook on 1.08.2022.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var dokumanAdText: UILabel!
    @IBOutlet weak var dokumanAciklamaText: UILabel!
    @IBOutlet weak var dokumanIcon: UIImageView!
    // Parametrelerin Tanımlanması
    var documentId : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
