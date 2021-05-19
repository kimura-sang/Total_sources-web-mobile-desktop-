//
//  SideMenu.swift
//  nSoft
//
//  Created by HJH on 2019/12/10.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

class SideMenuView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInitialization() {
        let view = Bundle.main.loadNibNamed("SideMenuView", owner: self, options: nil)!.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    @IBAction func goToShopPage(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        //self.present
        
    }
    
}
