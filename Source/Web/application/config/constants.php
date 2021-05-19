<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
|--------------------------------------------------------------------------
| Display Debug backtrace
|--------------------------------------------------------------------------
|
| If set to TRUE, a backtrace will be displayed along with php errors. If
| error_reporting is disabled, the backtrace will not display, regardless
| of this setting
|
*/
defined('SHOW_DEBUG_BACKTRACE') OR define('SHOW_DEBUG_BACKTRACE', TRUE);

/*
|--------------------------------------------------------------------------
| File and Directory Modes
|--------------------------------------------------------------------------
|
| These prefs are used when checking and setting modes when working
| with the file system.  The defaults are fine on servers with proper
| security, but you may wish (or even need) to change the values in
| certain environments (Apache running a separate process for each
| user, PHP under CGI with Apache suEXEC, etc.).  Octal values should
| always be used to set the mode correctly.
|
*/
defined('FILE_READ_MODE')  OR define('FILE_READ_MODE', 0644);
defined('FILE_WRITE_MODE') OR define('FILE_WRITE_MODE', 0666);
defined('DIR_READ_MODE')   OR define('DIR_READ_MODE', 0755);
defined('DIR_WRITE_MODE')  OR define('DIR_WRITE_MODE', 0755);

/*
|--------------------------------------------------------------------------
| File Stream Modes
|--------------------------------------------------------------------------
|
| These modes are used when working with fopen()/popen()
|
*/
defined('FOPEN_READ')                           OR define('FOPEN_READ', 'rb');
defined('FOPEN_READ_WRITE')                     OR define('FOPEN_READ_WRITE', 'r+b');
defined('FOPEN_WRITE_CREATE_DESTRUCTIVE')       OR define('FOPEN_WRITE_CREATE_DESTRUCTIVE', 'wb'); // truncates existing file data, use with care
defined('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE')  OR define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE', 'w+b'); // truncates existing file data, use with care
defined('FOPEN_WRITE_CREATE')                   OR define('FOPEN_WRITE_CREATE', 'ab');
defined('FOPEN_READ_WRITE_CREATE')              OR define('FOPEN_READ_WRITE_CREATE', 'a+b');
defined('FOPEN_WRITE_CREATE_STRICT')            OR define('FOPEN_WRITE_CREATE_STRICT', 'xb');
defined('FOPEN_READ_WRITE_CREATE_STRICT')       OR define('FOPEN_READ_WRITE_CREATE_STRICT', 'x+b');

/*
|--------------------------------------------------------------------------
| Exit Status Codes
|--------------------------------------------------------------------------
|
| Used to indicate the conditions under which the script is exit()ing.
| While there is no universal standard for error codes, there are some
| broad conventions.  Three such conventions are mentioned below, for
| those who wish to make use of them.  The CodeIgniter defaults were
| chosen for the least overlap with these conventions, while still
| leaving room for others to be defined in future versions and user
| applications.
|
| The three main conventions used for determining exit status codes
| are as follows:
|
|    Standard C/C++ Library (stdlibc):
|       http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
|       (This link also contains other GNU-specific conventions)
|    BSD sysexits.h:
|       http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
|    Bash scripting:
|       http://tldp.org/LDP/abs/html/exitcodes.html
|
*/
defined('EXIT_SUCCESS')        OR define('EXIT_SUCCESS', 0); // no errors
defined('EXIT_ERROR')          OR define('EXIT_ERROR', 1); // generic error
defined('EXIT_CONFIG')         OR define('EXIT_CONFIG', 3); // configuration error
defined('EXIT_UNKNOWN_FILE')   OR define('EXIT_UNKNOWN_FILE', 4); // file not found
defined('EXIT_UNKNOWN_CLASS')  OR define('EXIT_UNKNOWN_CLASS', 5); // unknown class
defined('EXIT_UNKNOWN_METHOD') OR define('EXIT_UNKNOWN_METHOD', 6); // unknown class member
defined('EXIT_USER_INPUT')     OR define('EXIT_USER_INPUT', 7); // invalid user input
defined('EXIT_DATABASE')       OR define('EXIT_DATABASE', 8); // database error
defined('EXIT__AUTO_MIN')      OR define('EXIT__AUTO_MIN', 9); // lowest automatically-assigned error code
defined('EXIT__AUTO_MAX')      OR define('EXIT__AUTO_MAX', 125); // highest automatically-assigned error code

define('SERVER_ADDRESS',    'http://'.$_SERVER['HTTP_HOST']);

define('UPLOAD_DIR',     SERVER_ADDRESS.'/uploads');

define('CSS_DIR',     SERVER_ADDRESS.'/include/css');
define('IMG_DIR',     SERVER_ADDRESS.'/include/img');
define('JS_DIR',      SERVER_ADDRESS.'/include/js');
define('ASSETS_DIR',  SERVER_ADDRESS.'/include/assets');
define('PLUGIN_DIR',  SERVER_ADDRESS.'/include/plugins');



// -------------------------
// ---- Email Constants ----
// -------------------------
define('SYSTEM_MAIL',   'app.nsofts@gmail.com');
define('SMTP_SERVER',   'ssl://smtp.gmail.com');
//define('SMTP_PASSWORD', 'p@$$w0rd23');
define('SMTP_PASSWORD', 'enzfjehxouzrmxbs');
define('EMAIL_TITLE', 	'nSofts Management System');
define('EMAIL_RANDOM_PASSWORD', 'Your new password is ');



// -----------------------------
// ---- Define Query Values ----
// -----------------------------
define('DASHBOARD_GET', 100);
define('DASHBOARD_GET_ONLY_INVENTORY', 101);
define('MY_SHOPS_GET_AMOUNT', 110);
define('TRANSACTIONS_GET', 120);
define('TRANSACTIONS_GET_PREV', 121);
define('TRANSACTIONS_GET_NEXT', 122);
define('CUSTOMERS_GET_TOP20', 130);
define('CUSTOMERS_GET_SEARCH_ALL', 134);
define('CUSTOMERS_GET_SEARCH', 135);
define('CUSTOMERS_SELECTED_DETAIL', 131);
define('CUSTOMERS_PREV_DETAIL', 132);
define('CUSTOMERS_NEXT_DETAIL', 133);
define('STAFF_GET', 140);
define('STAFF_SELECTED_DETAIL', 141);
define('STAFF_PREV_DETAIL', 142);
define('STAFF_NEXT_DETAIL', 143);
define('OFFERS_GET', 150);
define('OFFERS_GET_DETAIL', 151);
define('OFFERS_SAVE_DETAIL', 152);
define('OFFERS_REPLENISH_GET_CATEGORY', 153);
define('OFFERS_REPLENISH_GET_CATEGORY_DETAIL', 154);
define('OFFERS_REPLENISH_SAVE', 155);
define('REPORTS_SALES', 160);
define('REPORTS_ITEM_SOLD', 161);
define('REPORTS_CONSOLIDATE', 162);
define('REPORTS_MORE', 163);
define('NOTICE_GET', 170);
define('NOTICE_VIEWED', 171);
define('NOTICE_HIDDEN', 172);
define('NOTICE_ACTED', 173);
define('EMAIL_STAFF_PROFILE', 241);
define('EMAIL_REPORTS_SALES', 260);
define('EMAIL_REPORTS_ITEM_SOLD', 261);
define('EMAIL_REPORTS_CONSOLIDATE', 262);
define('EMAIL_REPORTS_CUSTOMER_LIST', 263);
define('EMAIL_REPORTS_PRODUCT_ITEM_LIST', 264);
define('EMAIL_REPORTS_INVENTORY', 265);
define('EMAIL_REPORTS_TOP_ITEMS', 266);
define('EMAIL_REPORTS_LEAST_ITEMS', 267);
define('EMAIL_REPORTS_MONTHLY_REPORT', 268);
define('EMAIL_REPORTS_ITEM_SOLD_BREAKDOWN', 269);
define('EMAIL_REPORTS_PAYINS_PAYOUT', 2610);
define('EMAIL_REPORTS_FINANCIAL_STATEMENT', 2611);
define('EMAIL_REPORTS_PETTY_CASH', 2612);



// ----------------------------
// ---- Status value in DB ----
// ----------------------------
define('STATUS_ACTIVATED', 1);
define('STATUS_DEACTIVATED', 2);
define('STATUS_EXPIRED', 3);
define('DATA_REQUESTED', 4);
define('DATA_RESPONSED', 5);



// ---------------------
// ---- OWNER LEVEL ----
// ---------------------
define('OWNER_SHOP', 0);
define('OWNER_MANAGER', 1);
define('OWNER_SUPERVISOR', 2);
define('OWNER_STAFF', 3);
define('STR_OWNER_SHOP', 'Owner');
define('STR_OWNER_MANAGER', 'Manager');
define('STR_OWNER_SUPERVISOR', 'Supervisor');
define('STR_OWNER_STAFF', 'Staff');



// -------------------------
// ---- Const in coding ----
// -------------------------
define('EMPTY_STRING', '---');

define('CUSTOMER_PREMIUM', 1);
define('CUSTOMER_REGULAR', 2);
define('OFFER_AVAILABLE', 1);
define('OFFER_DISABLE', 2);

define('STR_REPORT_SALES', 'salesReport');
define('STR_REPORT_ITEM_SOLD', 'itemSold');
define('STR_REPORT_CONSOLIDATE', 'consolidate');
define('STR_REPORT_MORE', 'more');

define('STR_REPORT_HOURLY', 'Hourly');
define('STR_REPORT_DAILY', 	'Daily');
define('STR_REPORT_WEEKLY', 'Weekly');
define('STR_REPORT_MONTHLY', 'Monthly');
define('STR_REPORT_YEARLY', 'Yearly');

define('UUID_CHANGED', 1000);

