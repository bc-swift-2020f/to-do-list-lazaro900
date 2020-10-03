//
//  ListTableViewCell.swift
//  ToDo List
//
//  Created by Lazaro Alvelaez on 10/3/20.
//

import UIKit

protocol listTableViewCellDelegate: class{
    func checkBoxToggle(sender: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    
    weak var delegate: listTableViewCellDelegate?

    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func checkToggled(_ sender: UIButton) {
        delegate?.checkBoxToggle(sender: self)
    }
}
