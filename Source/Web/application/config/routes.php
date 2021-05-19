<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
| -------------------------------------------------------------------------
| URI ROUTING
| -------------------------------------------------------------------------
| This file lets you re-map URI requests to specific controller functions.
|
| Typically there is a one-to-one relationship between a URL string
| and its corresponding controller class/method. The segments in a
| URL normally follow this pattern:
|
|	example.com/class/method/id/
|
| In some instances, however, you may want to remap this relationship
| so that a different class/function is called than the one
| corresponding to the URL.
|
| Please see the user guide for complete details:
|
|	https://codeigniter.com/user_guide/general/routing.html
|
| -------------------------------------------------------------------------
| RESERVED ROUTES
| -------------------------------------------------------------------------
|
| There are three reserved routes:
|
|	$route['default_controller'] = 'welcome';
|
| This route indicates which controller class should be loaded if the
| URI contains no data. In the above example, the "welcome" class
| would be loaded.
|
|	$route['404_override'] = 'errors/page_missing';
|
| This route will tell the Router which controller/method to use if those
| provided in the URL cannot be matched to a valid route.
|
|	$route['translate_uri_dashes'] = FALSE;
|
| This is not exactly a route, but allows you to automatically route
| controller and method names that contain dashes. '-' isn't a valid
| class or method name character, so it requires translation.
| When you set this option to TRUE, it will replace ALL dashes in the
| controller and method URI segments.
|
| Examples:	my-controller/index	-> my_controller/index
|		my-controller/my-method	-> my_controller/my_method
*/
$route['default_controller'] = 'startpage';
$route['404_override'] = '';
$route['translate_uri_dashes'] = FALSE;

//backend
$route['adminlogin']  = 'backend/AdminLogin/index';
$route['adminlogin/(:any)']  = 'backend/AdminLogin/$1';
$route['shopowner']  = 'backend/ShopOwner/index';
$route['shopowner/(:any)']  = 'backend/ShopOwner/$1';

//frontend
$route['flogin']  = 'frontend/Login/index';
$route['flogin/(:any)']  = 'frontend/Login/$1';
$route['dashboard']  = 'frontend/Dashboard/index';
$route['dashboard/(:any)']  = 'frontend/Dashboard/$1';
$route['shop']  = 'frontend/Shop/index';
$route['shop/(:any)']  = 'frontend/Shop/$1';
$route['transaction']  = 'frontend/Transaction/index';
$route['transaction/(:any)']  = 'frontend/Transaction/$1';
$route['customer']  = 'frontend/Customer/index';
$route['customer/(:any)']  = 'frontend/Customer/$1';
$route['staff']  = 'frontend/Staff/index';
$route['staff/(:any)']  = 'frontend/Staff/$1';
$route['offer']  = 'frontend/Offer/index';
$route['offer/(:any)']  = 'frontend/Offer/$1';
$route['report']  = 'frontend/Report/index';
$route['report/(:any)']  = 'frontend/Report/$1';
$route['setting']  = 'frontend/Setting/index';
$route['setting/(:any)']  = 'frontend/Setting/$1';
$route['personal']  = 'frontend/Personal/index';
$route['personal/(:any)']  = 'frontend/Personal/$1';

//communication
$route['communication/(:any)']  = 'Communication/$1';


