//
//  QRDisplayViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 1/8/19.
//  Copyright © 2019 Jerry Wang. All rights reserved.
//

import UIKit

class QRDisplayViewController: UIViewController{
    @IBOutlet weak var QRCodeImage: UIImageView!
    var qrCode: UIImage!
    
    override func viewDidLoad() {
        QRCodeImage.image = qrCode
    }
}
