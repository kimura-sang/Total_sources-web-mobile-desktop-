//
//  NoticeModel.swift
//  nSoft
//
//  Created by TIGER on 2019/12/25.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation

class NoticeModel {
    var no:String
    var type:String
    var dateTime:String
    var title:String
    var content:String
    var viewStatus:String
    var actionStatus:String
    init(no:String, type:String, dateTime:String, title:String, content:String, viewStatus:String, actionStatus:String) {
        self.no = no
        self.type = type
        self.dateTime = dateTime
        self.title = title
        self.content = content
        self.viewStatus = viewStatus
        self.actionStatus = actionStatus
    }
}
