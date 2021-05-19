//
//  Globals.swift
//  nSoft
//
//  Created by HJH on 2019/12/9.
//  Copyright © 2019 Xing. All rights reserved.
//

import Foundation
import UIKit

let isTest = false
let sdkFacebook:Int = 1
let sdkGoogle:Int = 2

let QUANTITY_EMPTY = 1
let EXPIRED_DATE_EMPTY = 2

let defaultSettings = UserDefaults.standard

let profileBorderColor = UIColor.lightGray.cgColor
let topViewColor = UIColor.init(red: 0, green: 162/255, blue: 188/255, alpha: 1)
let placeHolderColor = UIColor.init(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)

let mainViewCornerRadius:CGFloat = 10.0
let menuItems = [["dash","dash_selected", "Dashboard", "DashboardViewController"],
             ["shop", "shop_selected", "My Shops", "MyShopViewController"],
             ["transaction","transaction_selected", "Transaction", "TransactionViewController"],
             ["customer", "customer_selected", "Customers", "CustomerViewController"],
             ["staff","staff_selected", "Staff", "StaffViewController"],
             ["offer","offer_selected", "Offers", "OfferViewController"],
             ["setting", "setting_selected", "Settings", "SettingViewController"],
             ["report", "report_selected","Reports", "ReportViewController"],
//             ["user_selected", "user","User Information", "UserInfoViewController"],
             ["logout", "logout_selected", "Logout", "LoginViewController"]]
let reportMenuItems = [["sales_reports_selected", "sales_reports", "Sales Report", "ReportViewController"],
                       ["item_solds", "item_solds_selected", "Item Sold", "ItemSoldViewController"],
                       ["consolidated", "consolidated_selected", "Shop Comparison", "ConsolidatedViewController"],
                       ["more", "more_selected", "More Reports", "MoreViewController"],
                       ["icon_report_back_blue", "icon_report_back_blue", "Go To Main Menu", "DashboardViewController"]]
var selectedMenuIndex = 0
var selectedReportMenuIndex = 0
var isClickMenu = false
var isClickMenuHeader = false
var isClickReportMenu = false
var isRegularStatus = false
var selectedCustomerID = ""
var selectedStaffID = ""
var dashUserCount = 0
var shopPageDisplayTime = 6000
var selectedShopIndex = 0
var SHOP_NAME:String = ""
var SHOP_BRANCH:String = ""
var MACHINE_ID:String = ""
var isReportPage = false
var isBackFromNoticeDetail = false
var isBackFromAddShop = false
var staffArrayList:[StaffModel] = []

// -- API --
//let __SERVER_URL = "http://192.168.1.100:10000"
let __SERVER_URL = "http://35.247.134.80"
let __URL_GET_LOGIN = "/communication/tryUserLogin"
let __URL_GET_SHOP_LIST = "/communication/getShopList"
let __URL_POST_ADD_SHOP = "/communication/addNewShop"
let __URL_POST_SEND_EMAIL = "/communication/sendEmailForForgotPassword"
let __URL_POST_SEND_VCODE = "/communication/sendVerificationCode"
let __URL_POST_SEND_VCODE_FOR_BINDING = "/communication/sendVerificationCodeForBinding"
let __URL_POS_SEND_EMAIL_FOR_SDK = "/communication/sendEmailForSDKBinding"

let __URL_GET_CUSTOMER = "/communication/getCustomerData"
let __URL_GET_DASHBOARD_DATA = "/communication/getDashboardData"
let __URL_POST_REQUEST_UDID = "/communication/requestUUID"
let __URL_POST_REQUEST_EMAIL_UDID = "/communication/requestEmailUUID"
let __URL_POST_REQUEST_UDIDS = "/communication/requestUUIDS"
let __URL_GET_CUSTOMER_DATA = "/communication/getCustomerData"
let __URL_GET_CUSTOMER_PROFILE_DATA = "/communication/getCustomerProfileData"
let __URL_GET_STAFF_DATA = "/communication/getStaffData"
let __URL_GET_STAFF_PROFILE_DATA = "/communication/getStaffProfileData"
let __URL_GET_OFFER_DATA = "/communication/getOfferData"
let __URL_GET_OFFER_WITH_CATEGORY = "/communication/getOfferCategory"
let __URL_GET_ITEM_OPTIONS = "/communication/getItemOptions"
let __URL_GET_TEMP_REPLENISHLIST = "/communication/getTempReplenishList"
let __URL_GET_OFFER_DETAIL_DATA = "/communication/getOfferDetailData"
let __URL_POST_REGISTER = "/communication/tryRegister"
let __URL_POST_REGISTER_WITH_SOCIAL = "/communication/trySocialRegister"
let __URL_GET_REPORT_DATA = "/communication/getReportData"
let __URL_POST_NEW_ITEM_REPLENISH = "/communication/addNewItemReplenish"
let __URL_DELETE_ITEM_REPLENISH = "/communication/deleteTempReplenishItem"
let __URL_POS_ADD_ITEM_REPLENISH = "/communication/itemReplenishSave"
let __URL_POST_CHANGE_PASSWORD = "/communication/changePassword"
let __URL_GET_NOTICE_DATA = "/communication/getNoticeData"
let __URL_GET_CONSOLIDATE_RESULT = "/communication/getConsolidateResult"
// ---------

let __NOTICE_MESSAGE = "MESSAGE";
let __NOTICE_NOTICE = "NOTICE";
let __NOTICE_REQUEST = "REQUEST";
let __NOTICE_WARNING = "WARNING";

let strStaffLogIn = "login";
let strStaffLogOut = "logout";
let strStaffNone = "none";

// -- CONSTS --
let __DASHBOARD_GET = 100;
let __DASHBOARD_GET_CATEGORY = 101
let __MY_SHOPS_GET_AMOUNT = 110;
let __MY_SHOPS_ADD = 111;
let __TRANSACTIONS_GET = 120;
let __TRANSACTIONS_GET_PREV = 121;
let __TRANSACTIONS_GET_NEXT = 122;
let __CUSTOMERS_GET_TOP20 = 130;
let __CUSTOMERS_GET_SEARCH_ALL = 134;
let __CUSTOMERS_GET_SEARCH = 135;
let __CUSTOMERS_SELECTED_DETAIL = 131;
let __CUSTOMERS_PREV_DETAIL = 132;
let __CUSTOMERS_NEXT_DETAIL = 133;
let __STAFFS_GET = 140;
let __STAFFS_SELECTED_DETAIL = 141;
let __STAFFS_PREV_DETAIL = 142;
let __STAFFS_NEXT_DETAIL = 143;
let __OFFERS_GET = 150;
let __OFFERS_GET_DETAIL = 151;
let __OFFERS_SAVE_DETAIL = 152;
let __OFFERS_REPLENISH_GET_CATEGORY = 153;
let __OFFERS_REPLENISH_GET_CATEGORY_DETAIL = 154;
let __OFFERS_REPLENISH_SAVE = 155;
let __REPORTS_SALES = 160;
let __REPORTS_ITEM_SOLD = 161;
let __REPORTS_CONSOLIDATE = 162;
let __REPORTS_MORE = 163;
let __NOTICE_GET = 170;
let __NOTICE_VIEWED = 171;
let __NOTICE_HIDDEN = 172;
let __NOTICE_ACTED = 173;
let __EMAIL_STAFF_PROFILE = 241;
let __EMAIL_REPORTS_SALES = 260;
let __EMAIL_REPORTS_ITEM_SOLD = 261;
let __EMAIL_REPORTS_CONSOLIDATE = 262;
let __EMAIL_REPORTS_CUSTOMER_LIST = 263;
let __EMAIL_REPORTS_PRODUCT_ITEM_LIST = 264;
let __EMAIL_REPORTS_INVENTORY = 265;
let __EMAIL_REPORTS_TOP_ITEMS = 266;
let __EMAIL_REPORTS_LEAST_ITEMS = 267;
let __EMAIL_REPORTS_MONTHLY_REPORT = 268;
let __EMAIL_REPORTS_ITEM_SOLD_BREAKDOWN = 269;
let __EMAIL_REPORTS_PAYINS_PAYOUT = 2610;
let __EMAIL_REPORTS_FINANCIAL_STATEMENT = 2611;
let __EMAIL_REPORTS_PETTY_CASH = 2612;

let __RESULT_SUCCESS = 201
let __RESULT_FAILED = 202
let __RESULT_EMAIL_PASSWORD_INCORRECT = 203
let __RESULT_ACCOUNT_DUPLICATED = 204
let __RESULT_EMAIL_DUPLICATED = 205
let __RESULT_SEARCH_EMPTY = 206
let __RESULT_EMPTY_SHOP = 207
let __RESULT_OVER_EXPIRED = 208
let __RESULT_MACHINE_ID_EXIST = 209
let __RESULT_INCORRECT_UDID = 211;
let __RESULT_EMPTY_DATA = 212;
let __RESULT_EMAIL_INCORRECT = 213;
let __RESULT_SEND_EMAIL_FAILED = 214;

let __RESULT_VERIFICATION_CODE_USED = 215;
let __RESULT_VERIFICATION_CODE_INCORRECT = 216;

let __CUSTOMER_PREMIUM = 1
let __CUSTOMER_REGULAR = 2

let __OFFER_AVAILABLE = 1
let __OFFER_DISABLE = 2

let __ACTIVATED = 1
let __DEACTIVATED = 2
let __EXPIRED = 3
let __DATA_REQUESTED = 4
let __DATA_RESPONSED = 5

let __SERVER_CONNECTION_COUNT = 9

let __DEFAULT_STRING = ""
let __EMPTY_STRING = "---"
// ------------

// -- USER INFO --
var userFacebookId = ""
var userGoogleId = ""
var userID:String = ""
var userName:String = ""
var userEmail:String = ""
var userGoogleID:String = ""
var userPassword:String = ""
var userUniqueID:String = ""
var userPhotoUrl:String = ""
var userExpiredDate = ""
var userOwnerLevel = 0
var userEmailBindingStatus = "0"
// ---------------

// -- OFFER CATEGORY INFO --
var currentOfferDescription = ""
var currentOfferCode = ""
var currentOfferCategory = ""
var currentOfferPrice = ""
// -----

// -- STAFF INFORMATION --
var currentStaffId = ""
var currentStaffPosition = 0
var currentStaffName = ""
var currentStaffAddress = ""
var currentStaffMobile = ""
var currentStaffEmail = ""
var currentStaffRole = ""
// ____

// region --notice information --
 var currentNoticeType = "";
 var currentNoticeTitle = "";
 var currentNoticeContent = "";
 var currentNoticeNo = "";
 var currentNoticeActionStatus = "";
 var currentNoticeViewStatus = "";
 // endregion
