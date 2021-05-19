//
//  InventoryTableViewCell.swift
//  nSoft
//
//  Created by king on 2019/12/13.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class InventoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblInventoryName: UILabel!
    @IBOutlet weak var lblValue1: UILabel!
    @IBOutlet weak var lblValue2: UILabel!
    @IBOutlet weak var lblValue3: UILabel!
    @IBOutlet weak var lblValue4: UILabel!
    @IBOutlet weak var value1View: UIView!
    @IBOutlet weak var value2View: UIView!
    @IBOutlet weak var value3View: UIView!
    @IBOutlet weak var value4View: UIView!
    @IBOutlet weak var statusView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func set(model:DashInventoryModel) {
        lblInventoryName.text = model.name
        lblValue1.text = model.unit
        lblValue2.text = model.first
        lblValue3.text = model.second
        lblValue4.text = model.third
        value1View.layer.cornerRadius = 3.0
        value2View.layer.cornerRadius = 3.0
        value3View.layer.cornerRadius = 3.0
        value4View.layer.cornerRadius = 3.0
        if model.criticalStatus {
            statusView.backgroundColor = UIColor.init(red: 1, green: 204/255, blue: 203/255, alpha: 1)
        }  else {
            statusView.backgroundColor = UIColor.white
        }
    }
}
