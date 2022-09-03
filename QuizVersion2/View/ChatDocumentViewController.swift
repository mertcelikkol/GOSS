//
//  ChatDocumentViewController.swift
//  QuizVersion2
//
//  Created by Macbook on 3.08.2022.
//

import UIKit
import SDWebImage
import PDFKit

class ChatDocumentViewController: UIViewController {
    
    // Elemanların Tanımlanması
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    // Parametrelerin Tanımlanması
    var pdfView = PDFView()
    var dispayLink : String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            gunduzMod()
            navigationController?.navigationBar.backItem?.title = "Geri"
            if let dispayLink = dispayLink {
                if dispayLink.contains("pdf") {
                    let document = PDFDocument(url: URL(string: dispayLink)!)
                    
                    pdfView.document = document
                    pdfView.frame = displayView.frame
                    
                    
                    displayView.addSubview(pdfView)
                } else {
                    let image = UIImageView()
                    image.frame = displayView.frame
                    image.sd_setImage(with: URL(string: dispayLink), completed: nil)
                    image.contentMode = .scaleAspectFit
                    displayView.addSubview(image)
                }
            }
            
            // Do any additional setup after loading the view.
        
        backButton.addTarget(self, action: #selector(geriGit), for: .allTouchEvents)
        
        }
    
    
    @objc func geriGit(){
        self.dismiss(animated: true, completion: nil)
    }

}
