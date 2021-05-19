function shopSelected(shopId, statusId, itemId, imageColorId, imageWhiteId, itemCount){
	var postdata = {};
	postdata['shopId'] = shopId;

	if (parseInt(statusId) === 1) {
		// set session data by shop id
		sendAjax('/shop/setSelectedShop', postdata, function (data) {
			if (data != null) {
				showShopTitle(data);
				showSelectedShop(itemId, imageColorId, imageWhiteId, itemCount);
			} else {
				showAlertDialog("Cannot select current shop!");
			}
		}, 'json');
	} else if (parseInt(statusId) === 2) {
		showAlertDialog("This shop is deactivated");
	} else if (parseInt(statusId) === 3) {
		showAlertDialog("This shop is expired");
	}
}

function showShopTitle(jsonData) {
	var shopName = g_indicateEmptyString;
	var branch = g_indicateEmptyString;
	var shopTitle = g_indicateEmptyString;
	if (jsonData['shopName'] !== g_indicateEmptyString)
		shopTitle = jsonData['shopName'];
	if (jsonData['branch'] !== g_indicateEmptyString)
		shopTitle += ' - ' + jsonData['branch'];
	$('#shopTitle').text(shopTitle);
}

function showSelectedShop(itemId, imageColorId, imageWhiteId, itemCount) {
	for (var i = 0; i < itemCount; i++){
		var tempId = "";
		var tempItem;
		tempId = "item".concat(i.toString());

		tempItem = document.getElementById(tempId);
		tempItem.className = "page-content-item";
		tempItem.getElementsByClassName("item-image-round-white")[0].style.visibility = 'hidden';
		tempItem.getElementsByClassName("item-image-round")[0].style.visibility = 'visible';
	}

	var selectedItem = document.getElementById(itemId);
	var selectedImage = document.getElementById(imageColorId);
	var selectedImageWhite = document.getElementById(imageWhiteId);
	selectedItem.className = "page-content-item-clicked";
	selectedImage.style.visibility = 'hidden';
	selectedImageWhite.style.visibility = 'visible';
}

function tryAddShop(shopName, machineId, branchName, url)
{
	var postdata = {};
	postdata['shopName'] = document.getElementById(shopName).value;
	postdata['machineId'] = document.getElementById(machineId).value;
	postdata['branchName'] = document.getElementById(branchName).value;

	if (postdata['shopName'] == "" || postdata['shopName'] == null){
		document.getElementById('error_div').className = "alert alert-danger";
		document.getElementById('error').innerHTML = g_emptyShopNameMsg;
	}
	else if (postdata['machineId'] == "" || postdata['machineId'] == null){
		document.getElementById('error_div').className = "alert alert-danger";
		document.getElementById('error').innerHTML = g_emptyMachineIdMsg;
	}
	else{
		sendAjax(url, postdata, function (data) {
			if (data != null) {
				if (data === 1) {
					showAlertDialog(g_addShopSuccessMsg, function () {
						pageMove('/shop');
					}, 'nSofts');
				}
				if (data === 2)
				{
					document.getElementById('error_div').className = "alert alert-danger";
					document.getElementById('error').innerHTML = g_addShopFailedMsg;
				}
				if (data === 0)
				{
					document.getElementById('error_div').className = "alert alert-danger";
					document.getElementById('error').innerHTML = g_machineDuplicatedErrorMsg;
				}
			}
		}, 'json');
	}
}

function hideErrorNotice()
{
	document.getElementById('error_div').className = "alert alert-danger display-hide";
}

function deleteShop(url){
	bootbox.dialog({
		message: "Do you want to delete this shop?",
		title: "nSofts",
		buttons: {
			success: {
				label: "Cancel",
				className: "btn dark btn-outline sbold",
				callback: function() {
				}
			},
			main: {
				label: "Delete",
				className: "btn red-mint btn-outline sbold",
				callback: function() {
					var postData = {};
					sendAjax(url, postData, function (data) {
						if (data != null) {
							if (data == 0)
							{
								showAlertDialog(g_deleteFailedMsg, null,'nSofts');
							}
							if (data == 1)
							{
								showAlertDialog(g_deleteSuccessMsg, function () {
									pageMove('/shop');
								}, 'nSofts');
							}
						}
					}, 'json');
				}
			}
		}
	});
}
