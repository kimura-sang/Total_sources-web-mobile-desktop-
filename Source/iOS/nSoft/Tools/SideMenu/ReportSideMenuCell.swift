//
//  ReportSideMenuCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class ReportSideMenuCell: UITableViewCell {

    @IBOutlet weak var imgMenu: UIImageView!
       @IBOutlet weak var lblMenu: UILabel!
       
       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
           if selected {
               contentView.backgroundColor = UIColor(red: 59/255, green: 47/255, blue: 44/255, alpha: 1)
               contentView.tintColor = UIColor.white
               lblMenu.textColor = UIColor.white
               imgMenu.image = UIImage(named: reportMenuItems[selectedReportMenuIndex][1])
           } else {
               contentView.backgroundColor = UIColor.white
               lblMenu.textColor = UIColor(red: 59/255, green: 47/255, blue: 44/255, alpha: 1)
               //imgMenu.image = UIImage(named: reportMenuItems[selectedMenuIndex][0])
           }
       }
       
       func set(imageName:String, menuName:String){
           imgMenu.image = UIImage(named: imageName)
           lblMenu.text = menuName
       }

}
