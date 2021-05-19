Array.prototype.contain = function(val)
{
	for (var i = 0; i < this.length; i++)
	{
		if (this[i] == val)
		{
			return true;
		}
	}
	return false;
};

function pageMove(url)
{
    var formObj = document.getElementById("form");

    formObj.action = url;
    formObj.submit();
}

function isIncludeSpaceCharacter(objName, msg)
{
    var regexp = /[ ]/i;
    var obj = document.getElementById(objName);

    if(regexp.test( obj.value))
    {
        document.getElementById('error_div').className = "alert alert-danger";
        document.getElementById('error').innerHTML = msg;
        document.getElementById(objName).focus();
        // showAlertDialog(msg, function () {
        //     document.getElementById(objName).focus();
        // });

        return true;
    }
    else
    {
        return false;
    }
}

function inCorrectPassword(objName, msg){
	var obj = document.getElementById(objName);
	document.getElementById('error_div').className = "alert alert-danger";
	document.getElementById('error').innerHTML = msg;
	obj.focus();
}

function inCorrectPasswordWithAlert(objName, msg){
	showAlertDialog(msg, null, "nSofts");
	var obj = document.getElementById(objName);
	obj.focus();
}

function isEmptyErrorNotice(objName, msg)
{
	if(!objName)
		return false;

	var obj = document.getElementById(objName);

	if(!obj || obj.value === "")
	{
		document.getElementById('error_div').className = "alert alert-danger";
		document.getElementById('error').innerHTML = msg;
		document.getElementById(objName).focus();

		return true;
	}
	else
	{
		return false;
	}
}

function isEmptyErrorNoticeWithAlert(objName, msg)
{
	if(!objName)
		return false;

	var obj = document.getElementById(objName);

	if(!obj || obj.value === "")
	{
		showAlertDialog(msg, null, "nSofts");
		document.getElementById(objName).focus();

		return true;
	}
	else
	{
		return false;
	}
}

function isValidInputValues(objName)
{
	if (emailCheck(objName) !== 0)
	{
		document.getElementById('error_div').className = "alert alert-danger";
		document.getElementById('error').innerHTML = g_incorrectEmail;
		document.getElementById(objName).focus();

		return false;
	}

	return true;
}

function emailCheck (emailId) {
	var obj = document.getElementById(emailId).value;

	if (obj.indexOf('@') > 0 && obj.indexOf('.') > 0)
		return 0;
	else
		return 1;

	//return email_test(obj.value);
}

function showWarningMessage(inputName)
{
    $('#' + inputName + 'Warning').attr('hidden', false);
}

function hideWarningMessage(inputName)
{
    $('#' + inputName + 'Warning').attr('hidden', true);
}

function showEmptyNotice(objectIds) {
    if (!objectIds)
        return false;

    var flag = 0;
    var content;

    for (var i = objectIds.length - 1; i >= 0; i--)
    {
        if (objectIds[i] == 'editor')
            content = CKEDITOR.instances.editor.getData();
        else
            content = document.getElementById(objectIds[i]).value;

        if (content == '' || content == '-1')
        {
            showWarningMessage(objectIds[i]);

            if (objectIds[i] != 'startdate' && objectIds[i] != 'enddate')
                document.getElementById(objectIds[i]).focus();

            flag = 1;
        }
    }

    return flag === 1;
}

function onlyNumber(input, n) {
	input.value = input.value.replace(/[^0-9\.]/ig, '');
	var dotIdx = input.value.indexOf('.'), dotLeft, dotRight;

	if (dotIdx >= 0) {
		dotLeft = input.value.substring(0, dotIdx);
		dotRight = input.value.substring(dotIdx + 1);

		if (dotRight.indexOf('.') >= 0) {
			dotRight = dotRight.substring(0, dotRight.indexOf('.'));
		}

		if (dotRight.length > n) {
			dotRight = dotRight.substring(0, n);
		}
		input.value = dotLeft + '.' + dotRight;
	}
}

function showAlertDialog(content, callback, title)
{
    if (title == null)
        title = "Alert";

    $('#alertModal').modal('show');

    document.getElementById('alertText').innerHTML = content;
    document.getElementById('alertTitle').innerHTML = title;

    $("#alertOKButton").click(function () {
        $('#alertModal').modal('hide');

        if (callback)
            callback();
    });
}

function showConfirmDialog(content, callback, title)
{
    if (title == null)
        title = "Alert";

    $('#confirmModal').modal('show');

    document.getElementById('confirmText').innerHTML = content;
    document.getElementById('confirmTitle').innerHTML = title;

    $("#confirmButton").click(function () {
        $('#confirmModal').modal('hide');

        if (callback)
            callback();
    });
}

function createNewPage(filePath) {
    window.open(filePath, '_blank');
    window.focus();
}

function addScrollForWindows() {
    $('html, body').css('padding', 0);
    $('body').css('padding', 0);
    $(document.body).css({
        "overflow-x":"auto",
        "overflow-y":"scroll"
    });
}

/**
 * Function : get response data from web server
 * Creator  : billy
 * Date     : 20191114
 */
function getResponseData() {
	var postdata = {};
	postdata['requestUniqueID'] = requestUniqueID;

	sendAjax(requestURL, postdata, function (data) {
		if (data != null) {
			var code = data['code'];
			if (code === 1)
			{
				showData(data['data']);
			}
			else if (code === 2 || code === 3)
			{
				showLoadingFailedWithContent("Empty data");
			}
			else if (code === 4)
			{
				showLoadingFailedWithContent("Cannot connect Windows Service!");
			}
			else if (code === uuid_changed)
			{
				showLoadingDiv(false);
				showLoadingFailed(false);
				showMainContent(true);

				showAlertDialog("Another user logged in by this email!", function () {
					pageMove('/flogin/signOut');
				}, "nSofts");
			}
		}
	}, 'json');
}


// --------------------------
// ---- For loading page ----
// --------------------------
function showLoadingFailedWithContent(content) {
	showLoadingDiv(false);
	showLoadingFailed(true);
	$('#failed-reason').val(content);
}

function showLoadingDiv(isShow) {
	if (isShow) {
		$('.loading-div').css('display', 'block');
	} else {
		$('.loading-div').css('display', 'none');
	}
}

function showLoadingFailed(isShow) {
	if (isShow) {
		$('.loading-failed').css('display', 'block');
	} else {
		$('.loading-failed').css('display', 'none');
	}
}

function showMainContent(isShow) {
	if (isShow) {
		$('#main-content').css('display', 'block');
	} else {
		$('#main-content').css('display', 'none');
	}
}
