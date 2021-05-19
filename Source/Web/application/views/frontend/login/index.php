<!DOCTYPE html>
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en" xmlns="http://www.w3.org/1999/html"> <!--<![endif]-->

<head>
    <meta charset="utf-8" />
    <title>nSofts</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <meta content="" name="description" />
    <meta content="" name="author" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/select2/css/select2.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/plugins/select2/css/select2-bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/css/components.min.css" rel="stylesheet" id="style_components" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/global/css/plugins.min.css" rel="stylesheet" type="text/css" />
    <link href="<?=ASSETS_DIR ?>/pages/css/login-2.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="<?=CSS_DIR ?>/login.css" />
	<link href="<?=CSS_DIR ?>/custom.css" rel="stylesheet" type="text/css" />
    <link rel="shortcut icon" href="favicon.ico" />
</head>
<body class="login">
<div class="logo logo-center" >
	<img src="<?=SERVER_ADDRESS ?>/include/img/logo_image.png" style="height: 60px;" alt="" />
</div>
<div class="content">
    <form class="login-form " action="" method="post" id="mainFrm">
        <div class="alert alert-danger display-hide" style="background-color: white; border-color: #c5bec5; border-radius: 5px !important;" id="error_div">
            <button class="close" data-close="alert"></button>
            <span id="error" style="color: #544c4c;"> Please enter email and password. </span>
        </div>
        <div class="form-title">
            <img src="<?=SERVER_ADDRESS ?>/include/img/key.png" style="height: 70px;" align="middle">
        </div>
        <div class="form-title">
            <span class="form-title">Sign in to nSofts </span>
        </div>

        <div class="form-group">
            <label class="control-label visible-ie8 visible-ie9">Email</label>
            <label class="login-tip">Email</label>
            <input class="form-control form-control-solid placeholder-no-fix" type="text" autocomplete="off" placeholder="" name="email" id="email" onkeypress="hideErrorNotice();" />
        </div>
        <div class="form-group" style="margin-top: 25px;">
            <label class="control-label visible-ie8 visible-ie9">Password</label>
            <label class="login-tip">Password</label>
            <label class="login-tip forgot" onclick="pageMove('/flogin/forgotPassword')">Forgot password?</label>
            <div>
                <input class="form-control form-control-solid placeholder-no-fix" type="password" autocomplete="off" placeholder="" name="password" id="password" onkeypress="hideErrorNotice();" />
                <span toggle="#password" class="fa fa-fw fa-eye field-icon toggle-password"></span>
            </div>
        </div>
            <div class="form-actions">
            <button type="submit" class="btn green btn-block uppercase" onclick="tryLogin('email', 'password', '/flogin/tryLogin'); return false;">SIGN IN</button>
        </div>

        <div style="text-align: center">
            <label class="" onclick="pageMove('/flogin/signUp')"><u class="login-bottom-text">No Account? Create Account Now</u></label>
        </div>
    </form>
</div>

<script src="<?=ASSETS_DIR ?>/global/plugins/jquery.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/js.cookie.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/bootstrap-hover-dropdown/bootstrap-hover-dropdown.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/jquery.blockui.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/jquery-validation/js/jquery.validate.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/jquery-validation/js/additional-methods.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/plugins/select2/js/select2.full.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/global/scripts/app.min.js" type="text/javascript"></script>
<script src="<?=ASSETS_DIR ?>/pages/scripts/login.min.js" type="text/javascript"></script>

<script src="<?=JS_DIR ?>/common.js"></script>
<script src="<?=JS_DIR ?>/message.js"></script>
<script src="<?=JS_DIR?>/ajax.js"></script>
<script src="<?=JS_DIR?>/md5.js"></script>
<script src="<?=JS_DIR?>/frontend/login.js"></script>
<!--END PAGE LEVEL SCRIPTS -->
</body>
<!-- END BODY -->
</html>
