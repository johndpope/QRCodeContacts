//
//  imageCell.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/22/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //center the image
        self.imageView?.center = CGPoint(x:self.contentView.bounds.width/2.0,y:self.contentView.bounds.height/2.0)
        //round the corners of the image
        let radiusOfCircularMask = (self.imageView?.frame.width)!/2.0
        self.imageView?.layer.cornerRadius = radiusOfCircularMask
        self.imageView?.layer.masksToBounds = true
    }
}
