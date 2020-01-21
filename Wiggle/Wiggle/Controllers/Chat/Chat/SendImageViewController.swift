//
//  SendImageViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 18.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

protocol ImageMessageProtocol {
    func imageConfirmed(image: UIImage)
    func selectionCancelled()
}

class SendImageViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    var delegate:ImageMessageProtocol?
    var pickedImage: UIImage?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedImage.image = pickedImage
        if let name = name {
            nameLabel.text = name
        }
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let image = selectedImage.image {
            delegate?.imageConfirmed(image: image)
        }
    }
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.selectionCancelled()
    }
}
