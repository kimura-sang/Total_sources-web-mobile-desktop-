//
//  HttpRequest.swift
//  Wifi Socket
//
//  Created by king on 2019/6/3.
//  Copyright © 2019 king. All rights reserved.
//

import Foundation
import Alamofire

typealias FuncBlock = (_ result: Any?, _ error: Error?) -> Void

class HttpRequest {
    
    var myBlock: FuncBlock? = nil
    
    // ------------------------------
    // --- Http Request functions ---
    // ------------------------------
    func requestWithRequestTypeWithResult(requestType: HTTPMethod, withUrl: String, withHeader: [String: String], withContent: [String: Any]?) {
        Alamofire.request(withUrl, method: requestType, parameters: withContent, encoding: JSONEncoding.default, headers: withHeader).responseJSON{response in
            let result = response.result
            let err = response.error
            switch (result) {
            case .success(_):
                if (self.myBlock != nil) {
                    self.myBlock!(result.value, err)
                }
                break
            case .failure(_):
                print("Error message:\(err!)")
                if (self.myBlock != nil) {
                    self.myBlock!(nil, err)
                }
            }
        }
    }
    
    func requestWithRequestTypeWithResultWithString(requestType: HTTPMethod, withUrl: String, withHeader: [String: String], withContent: [String: Any]?) {
        Alamofire.request(withUrl, method: requestType, parameters: withContent, encoding: URLEncoding.default, headers: withHeader).responseString{response in
            let result = response.result
            let err = response.error
            switch (result) {
            case .success(_):
                if (self.myBlock != nil) {
                    self.myBlock!(result.value, err)
                }
                break
            case .failure(_):
                print("Error message:\(err!)")
                if (self.myBlock != nil) {
                    self.myBlock!(nil, err)
                }
            }
        }
    }
    
    func requestWithRequestType(requestType: HTTPMethod, withUrl: String, withHeader: [String: String], withContent: [String: Any]?) {
        Alamofire.request(withUrl, method: requestType, parameters: withContent, encoding: JSONEncoding.default, headers: withHeader).response{response in
            let code = response.response?.statusCode
            let err = response.error
            if code == 200 {
                if (self.myBlock != nil) {
                    self.myBlock!(["result": "success"], nil)
                }
            } else {
                print("Error message:\(err!)")
                if (self.myBlock != nil) {
                    self.myBlock!(nil, err)
                }
            }
        }
    }
    // ------------------------------
    
    static func tryLogin(email: String, password: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_LOGIN + "?email=" + email + "&password=" + password
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func trySocalLogin(email: String, photoUrl:String, sdkType: Int, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_LOGIN + "?email=" + email + "&photo_url=" + photoUrl + "&type=" + String(sdkType)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getShopList(userId: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_SHOP_LIST + "?user_id=" + userId
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func updateShopLog(userId: String, userEmail:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_SHOP_LIST + "?user_id=" + userId + "&email=" + userEmail
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getDashboardData(UDID: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_DASHBOARD_DATA + "?unique_id=" + UDID
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getCustomerData(UDID: String, searchType:String, customerType:String,  didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_GET_CUSTOMER_DATA + "?unique_id=" + UDID + "&search_value=" + searchType + "&customer_type=" + customerType
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    static func getCustomerProfileData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_CUSTOMER_PROFILE_DATA + "?unique_id=" + UDID
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getStaffData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_STAFF_DATA + "?unique_id=" + UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getStaffProfileData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_STAFF_PROFILE_DATA + "?unique_id=" + UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getOfferData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_OFFER_DATA + "?unique_id=" + UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getOfferDetailData(UDID: String, didFuncLoad: @escaping FuncBlock)
       {
           let url: String = __SERVER_URL + __URL_GET_OFFER_DETAIL_DATA + "?unique_id=" + UDID
           //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
           let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
           let httpRequest = HttpRequest()
           httpRequest.myBlock = didFuncLoad
           httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
       }
    
    
    static func getItemOptions(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_ITEM_OPTIONS + "?unique_id=" + UDID
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getTempReplenishList(accountId: String, machineId:String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_TEMP_REPLENISHLIST + "?account_id=" + accountId + "&machine_id=" + machineId
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getOfferWithCategory(UDID: String, status:Int, categoryName:String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_OFFER_WITH_CATEGORY + "?unique_id=" + UDID + "&category=" + categoryName.replacingOccurrences(of: " ", with: "%20") + "&type=" + String(status)
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getReportData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_REPORT_DATA + "?unique_id=" + UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func getNoticeData(UDID: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_NOTICE_DATA + "?unique_id=" + UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
//    static func getConsolidateResult(UDIDs: String, didFuncLoad: @escaping FuncBlock)
//    {
//        let url: String = __SERVER_URL + __URL_GET_CONSOLIDATE_RESULT + "?requestUniqueIDs=" + UDIDs.replacingOccurrences(of: "\\", with: "")
//        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
//        let httpRequest = HttpRequest()
//        httpRequest.myBlock = didFuncLoad
//        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
//    }
    
    static func getConsolidateResult(UDIDs: String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_GET_CONSOLIDATE_RESULT
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["requestUniqueIDs"] = UDIDs
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    
    static func deleteSelectedItem(userId:String, machineId:String, itemId:String, didFuncLoad: @escaping FuncBlock)
    {
        let url: String = __SERVER_URL + __URL_DELETE_ITEM_REPLENISH + "?account_id=" + userId + "&machine_id=" + machineId + "&item_id=" + itemId
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.get, withUrl: url, withHeader: header, withContent: nil)
    }
    
    static func changePassword(userId: String, password: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_CHANGE_PASSWORD
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["userId"] = userId
        content["password"] = password
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func sendEmailForChangePassword(email: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_SEND_EMAIL
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["email"] = email
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func sendEmailForSDKBinding(userId:String, email: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POS_SEND_EMAIL_FOR_SDK
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["email"] = email
        content["userId"] = userId
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func sendVCodeForChangePassword(userId:String, code: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_SEND_VCODE
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["userId"] = userId
        content["code"] = code
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func sendVerificationCodeForBinding(userId:String, code: String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_SEND_VCODE_FOR_BINDING
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["userId"] = userId
        content["code"] = code
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func addNewShop(shopName: String, machineID: String, branch: String, userId:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_ADD_SHOP
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["shop_name"] = shopName
        content["machine_id"] = machineID
        content["branch"] = branch
        content["user_id"] = userId
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func addNewItem(userId: String, machineId: String, code: String, name:String, qty:String, unit:String, expiredDate:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_NEW_ITEM_REPLENISH
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["account_id"] = userId
        content["machine_id"] = machineId
        content["item_code"] = code
        content["item_name"] = name
        content["quantity"] = qty
        content["unit"] = unit
        if expiredDate != __EMPTY_STRING {
            content["expired_date"] = expiredDate
        }
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func saveItemReplenish(machineId: String, userEmail: String, sqlNo: String, statusId:String, userId:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POS_ADD_ITEM_REPLENISH
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["machine_id"] = machineId
        content["request_by"] = userEmail
        content["sql_no"] = sqlNo
        content["status_id"] = statusId
        content["user_id"] = userId
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func requestUDID(machineId:String, userID:String, uniqueID:String, requestBy: String, sqlNo: Int, statusID: Int, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REQUEST_UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["machine_id"] = MACHINE_ID
        content["request_by"] = requestBy
        content["sql_no"] = sqlNo
        content["status_id"] = statusID
        content["user_id"] = userID
        content["unique_id"] = uniqueID
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func requestUDIDWithSearchKey(machineId:String, userID:String, uniqueID:String, requestBy: String, sqlNo: Int, statusID: Int, searchKey:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REQUEST_UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["machine_id"] = machineId
        content["request_by"] = requestBy
        content["sql_no"] = sqlNo
        content["status_id"] = statusID
        content["search_key"] = searchKey
        content["user_id"] = userID
        content["unique_id"] = uniqueID
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    static func requestEmailUDID(machineIds:String, userID:String, uniqueID:String, requestBy: String, sqlNo: Int, statusID: Int, searchKey:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REQUEST_EMAIL_UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["user_id"] = userID
        content["unique_id"] = uniqueID
        content["machine_id"] = machineIds
        content["request_by"] = requestBy
        content["sql_no"] = sqlNo
        content["status_id"] = statusID
        content["search_key"] = searchKey
        
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    static func requestUDIDWithKeyOrNot(machineId:String, userID:String, uniqueID:String, requestBy: String, sqlNo: Int, statusID: Int, searchKey:String, status:Bool, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REQUEST_UDID
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["machine_id"] = machineId
        content["request_by"] = requestBy
        content["sql_no"] = sqlNo
        content["status_id"] = statusID
        content["user_id"] = userID
        content["unique_id"] = uniqueID
        if status {
            content["search_key"] = searchKey
        }
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func requestWithUDIDs(machineId:String, userID:String, uniqueID:String, requestBy: String, sqlNo: Int, statusID: Int, searchKey:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REQUEST_UDIDS
        url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["machine_id"] = machineId
        content["request_by"] = requestBy
        content["sql_no"] = sqlNo
        content["status_id"] = statusID
        content["search_key"] = searchKey
        content["user_id"] = userID
        content["unique_id"] = uniqueID
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func tryRegister(firstName:String, lastName:String, email:String, password:String, didFuncLoad: @escaping FuncBlock) {
        let url: String = __SERVER_URL + __URL_POST_REGISTER
        //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var content: Dictionary = [String: Any]()
        content["first_name"] = firstName
        content["last_name"] = lastName
        content["email"] = email
        content["password"] = password
        
        let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
        let httpRequest = HttpRequest()
        httpRequest.myBlock = didFuncLoad
        httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
    }
    
    static func tryRegisterWithSocial(firstName:String, lastName:String, email:String, photoUrl:String,  sdkId:String, type:Int,  didFuncLoad: @escaping FuncBlock) {
          let url: String = __SERVER_URL + __URL_POST_REGISTER_WITH_SOCIAL
          //url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
          var content: Dictionary = [String: Any]()
          content["first_name"] = firstName
          content["last_name"] = lastName
          content["email"] = email
         content["photo_url"] = photoUrl
          content["sdk_id"] = sdkId
          content["type"] = type
          
          let header: HTTPHeaders = [ "Content-Type" : "application/json" ]
          let httpRequest = HttpRequest()
          httpRequest.myBlock = didFuncLoad
          httpRequest.requestWithRequestTypeWithResult(requestType: HTTPMethod.post, withUrl: url, withHeader: header, withContent: content)
      }
}
