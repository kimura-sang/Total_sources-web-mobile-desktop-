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
<div class="logo password-logo" >
	<img src="<?=SERVER_ADDRESS ?>/include/img/logo_image.png" style="height: 60px;" alt="" />

    <div class="logo-right">
        <label class="top-tip"> Already have an account?</label>
        <button class="top-button btn green-meadow btn-block uppercase " onclick="pageMove('/flogin/index')">SIGN IN</button>
    </div>
</div>
<div class="content">

    <form class="login-form content-form " action="" method="post" id="mainFrm">
        <div class="alert alert-danger display-hide" style="background-color: white; border-color: #c5bec5; border-radius: 5px !important;" id="error_div">
            <button class="close" data-close="alert"></button>
            <span id="error" style="color: #544c4c;"> Enter any username and password. </span>
        </div>
        <div class="form-title">
            <img src="<?=SERVER_ADDRESS ?>/include/img/key.png" style="height: 70px;" align="middle">
        </div>
        <div class="form-title">
            <span class="form-title">Reset your password </span>
        </div>
        <div class="form-group" style="margin-top: 25px;">
            <label class="control-label visible-ie8 visible-ie9">New password</label>
            <label class="login-tip">New password</label>
            <div>
                <input class="form-control form-control-solid placeholder-no-fix" type="password" autocomplete="off" placeholder="" name="password" id="pwd" onkeypress="hideErrorNotice();"</input>
                <span toggle="#new-pwd" class="fa fa-fw fa-eye field-icon toggle-password"></span>
            </div>
        </div>
        <div class="form-group" style="margin-top: 25px;">
            <label class="control-label visible-ie8 visible-ie9">Confirm password</label>
            <label class="login-tip">Confirm password</label>
            <div>
                <input class="form-control form-control-solid placeholder-no-fix" type="password" autocomplete="off" placeholder="" name="password" id="confirmPwd" onkeypress="hideErrorNotice();"</input>
                <span toggle="#confirm-pwd" class="fa fa-fw fa-eye field-icon toggle-password"></span>
            </div>
        </div>
        <div class="form-actions">
            <button type="submit" class="btn green btn-block uppercase" onclick="savePassword('userId', 'pwd', '/flogin/tryLogin'); return false;">SAVE PASSWORD</button>
        </div>
    </form>

	<? $this->load->view('/frontend/template/dialogCommon'); ?>

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
<!--END PAGE LEVEL SCRIPTS -->
<script type="text/javascript">
	$(document).ready(function(){
		<? if (!empty($errorText)) { ?>
		showAlertDialog('<?= $errorText ?>', function () {
			pageMove('/flogin');
		}, 'nSofts');
		<? } ?>
	});

    function savePassword()
    {
		<? if (empty($errorText)) { ?>
        if (!isEmptyErrorNotice('pwd', g_emptyPasswordMsg) && !isEmptyErrorNotice('confirmPwd', g_emptyConfirmPasswordMsg)) {
			var postdata = {};
			postdata['userId'] = '<?= $userData['id'] ?>';
			postdata['tokenId'] = '<?= $tokenId ?>';
			postdata['password'] = hex_md5(document.getElementById('pwd').value);
			if (postdata['password'] !== hex_md5(document.getElementById('confirmPwd').value)){
				inCorrectPassword('pwd', g_notSamePasswordMsg);
			} else {
				sendAjax('/flogin/updatePassword', postdata, function (data) {
					if (data != null) {
						if (data == 0)
							showAlertDialog(g_notSelectOwnerIdMsg, null, 'nSofts');
						if (data == 1)
						{
							document.getElementById('error_div').className = "alert alert-danger display-hide";
							showAlertDialog(g_updatePasswordSuccessMsg, function () {
								pageMove('/flogin');
							}, 'nSofts');
						}
					}
				}, 'json');
			}
        }
		<? } ?>
    }

    function hideErrorNotice()
    {
        document.getElementById('error_div').className = "alert alert-danger display-hide";
    }

    function pageMove(url) {
        var obj = document.getElementById('mainFrm');
        obj.action = url;
        obj.submit();
    }

    $(".toggle-password").click(function() {
        $(this).toggleClass("fa-eye fa-eye-slash");
        var input = $($(this).attr("toggle"));
        if (input.attr("type") == "password") {
            input.attr("type", "text");
        } else {
            input.attr("type", "password");
        }
    });
</script>
</body>
<!-- END BODY -->
</html>
