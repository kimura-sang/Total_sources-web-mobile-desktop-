//
//  CustomerNoticeTableViewCell.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import UIKit

protocol CustomerNoticeTableViewCellDelegate {
    func hideNotice(noticeNo:String)
    func activeNotice(noticeNo:String)
}

class CustomerNoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblNoticeNo: UILabel!
    @IBOutlet weak var lblNoticeTitle: UILabel!
    @IBOutlet weak var lblNoticeContent: UILabel!
    @IBOutlet weak var reqeustView: UIView!
    var delegate:CustomerNoticeTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func tryHideMessage(_ sender: Any) {
        delegate?.hideNotice(noticeNo: lblNoticeNo.text!)
    }
    @IBAction func tryDisagreeRequest(_ sender: Any) {
        delegate?.activeNotice(noticeNo: lblNoticeNo.text! + "_0")
    }
    @IBAction func tryAgreeRequest(_ sender: Any) {
        delegate?.activeNotice(noticeNo: lblNoticeNo.text! + "_1")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func set(model:NoticeModel) {
        reqeustView.isHidden = true
        btnHide.isHidden = false
        btnYes.layer.cornerRadius = 7.0
        btnNo.layer.cornerRadius = 7.0
        btnHide.layer.cornerRadius = 7.0
        lblNoticeNo.text = model.no
        lblNoticeTitle.text = model.title
        if model.content.count > 30 {
            lblNoticeContent.text = model.content.prefix(30) + "..."
        } else {
            lblNoticeContent.text = model.content
        }
        if model.viewStatus != "True" {
            lblNoticeTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
        } else {
            lblNoticeTitle.font = UIFont.systemFont(ofSize: 16.0, weight: .thin)
        }
        if model.type == __NOTICE_REQUEST {
            imgLogo.image = UIImage(named: "icon_notice_question")
            if model.actionStatus != "True" {
                reqeustView.isHidden = false
                btnHide.isHidden = true
            } else {
                reqeustView.isHidden = true
                btnHide.isHidden = false
            }
        } else if model.type == __NOTICE_NOTICE {
            imgLogo.image = UIImage(named: "icon_notice_bell")
        } else if model.type == __NOTICE_MESSAGE {
            imgLogo.image = UIImage(named: "icon_notice_post")
        } else if model.type == __NOTICE_WARNING {
            imgLogo.image = UIImage(named: "icon_notice_remark")
        }
    }

}
