function tryLogin(email, password, url)
{
	if (!isEmptyErrorNotice(email, g_emptyEmailMsg) && !isEmptyErrorNotice(password, g_emptyPasswordMsg) && isValidInputValues(email)) {
		if (!isIncludeSpaceCharacter(email, g_notInputSpace) && !isIncludeSpaceCharacter(password, g_notInputSpace)) {
			var postdata = {};
			postdata['email'] = document.getElementById(email).value;
			postdata['password'] = hex_md5(document.getElementById(password).value);

			sendAjax(url, postdata, function (data) {
				if (data != null) {
					if (data == 0)
					{
						//showAlertDialog(g_notInputSpace);
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_notInputSpace;
					}
					if (data == 1)
					{
						document.getElementById('error_div').className = "alert alert-danger display-hide";
						pageMove('/shopowner');
					}
					if (data == 2)
					{
						//showAlertDialog(g_loginErrorMsg);
						document.getElementById('error_div').className = "alert alert-danger";
						document.getElementById('error').innerHTML = g_loginErrorMsg;
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
