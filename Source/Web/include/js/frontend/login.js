function tryLogin(email, password, url)
{
	if (!isEmptyErrorNotice(email, g_emptyEmailMsg) && !isEmptyErrorNotice(password, g_emptyPasswordMsg)) {
		if (!isIncludeSpaceCharacter(email, g_notInputSpace) && isValidInputValues(email) && !isIncludeSpaceCharacter(password, g_notInputSpace)) {
			var postdata = {};
			postdata['email'] = document.getElementById(email).value;
			postdata['password'] = hex_md5(document.getElementById(password).value);

			sendAjax(url, postdata, function (data) {
				if (data != null) {
					if (data === 1) {
						document.getElementById('error_div').className = "alert alert-danger display-hide";
						pageMove('/dashboard/index');
					}
					if (data === 2) {
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_notInputSpace;
					}
					if (data === 3) {
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_loginErrorMsg;
					}
					if (data === 4) {
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_accountDeactivated;
					}
					if (data === 5) {
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_accountExpiredDate;
					}
				}
			}, 'json');
		}
	}
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
