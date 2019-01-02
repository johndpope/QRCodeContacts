//
//  SingleEntryCell.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/22/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit

class SingleEntryCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.textField.isUserInteractionEnabled = true
        } else {
            self.textField.isUserInteractionEnabled = false 
        }
    }
}
