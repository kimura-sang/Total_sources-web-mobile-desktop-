<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Staff profile and attendance </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <div class="content-move">
							<div class="move-left">
								<img class="move-left back-button" src="<?= SERVER_ADDRESS?>/include/img/back_icon.png" onclick="pageMove('/staff/index')">
								<div class="move-left" onclick="clickPrevButton()" style="margin-top: 6px;">
									<img src="<?=SERVER_ADDRESS ?>/include/img/arrow_prev.png" class="img-responsive" >
								</div>
							</div>

							<div class="page-content-box-date" style="margin-left: 40%;">
								<div class="report-item-label info-item-margin">
									<label class=" item-left report-left">Date</label>
								</div>
								<div class="report-item" style="margin-top: 5px; width: 23%;">
									<div class="input-group date date-picker" data-date-format="yyyy-mm-dd" id="date-and-month-container">
										<input type="text" class="form-control input-round-box" id="date-and-month" readonly onchange="selectDateForSearch(this.value);">
										<span class="input-group-btn">
											<button class="btn default button-calendar" style="margin-left: 5px;" type="button">
												<i class="fa fa-calendar"></i>
											</button>
										</span>
									</div>
								</div>
							</div>

							<div class="move-right" style="margin-top: 6px; margin-left: 20px;">
								<a class="btn sbold red-haze add-button" onclick="sendEmail(); return false;"> @ Email </a>
							</div>

							<div class="move-right" onclick="clickNextButton()" style="margin-top: 6px;">
								<img src="<?=SERVER_ADDRESS ?>/include/img/arrow_next.png" class="img-responsive" >
							</div>
                        </div>
                        <div>
                            <hr>
                        </div>

                        <div class="page-content-box">
                            <div class="transaction-content col-md-6 content-left">
                                <div class="item-content-tile">
                                    <label class="">Staff information</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Name</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="name">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left"></label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right"></label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Email</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="email">---</label>
                                </div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left"></label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right"></label>
								</div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Role</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="role">Staff</label>
                                </div>
                            </div>

                            <div class="transaction-content col-md-6 content-right">
                                <div class="item-content-tile">
                                    <label class="">Attendance</label>
                                </div>
								<div class="content-body-overflow" id="attendanceList">
								</div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    table.dataTable.no-footer {
        border-bottom: none;
    }
</style>

<script type="text/javascript">
	var listUniqueID = "<?= $listUniqueID ?>";
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var userName = "<?= $userName ?>";
	var requestURL = '/staff/waitingToGetResponse';
	var dateArray = [];
	var inTimeArray = [];
	var outTimeArray = [];
	var dateForSearch = g_indicateEmptyString;
	var sendingEmail = false;

	$(document).ready(function(){
		waitingToGetResponse();
	});

	function selectDateForSearch(value) {
		if (dateForSearch !== value) {
			dateForSearch = value;
			getAnotherUniqueID(3);
		}
	}

	function getAnotherUniqueID(userValue) {
		sendingEmail = false;

		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['currentUserName'] = userName;
		postdata['listUniqueID'] = listUniqueID;
		postdata['dateForSearch'] = dateForSearch;
		postdata['userValue'] = userValue;

		sendAjax('/staff/getAnotherUniqueID', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
				{
					requestUniqueID = data['data']['uniqueId'];
					waitingToGetResponse();
				}
				else if (code === 2)
				{
					showLoadingFailedWithContent("Connection Failed!");
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

	function clickPrevButton() {
		getAnotherUniqueID(1);
	}

	function clickNextButton() {
		getAnotherUniqueID(2);

	}

	function waitingToGetResponse() {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);
		setTimeout(getResponseData, 50);
	}

	function showData(data) {
		showLoadingDiv(false);
		showLoadingFailed(false);
		showMainContent(true);

		if (!sendingEmail)
			showProfileData(data);
	}

	function showProfileData(data) {
		var logData = JSON.parse(data);

		// set data on shop information
		var detail = JSON.parse(logData["profile"])[0];
		$("#name").text(g_indicateEmptyString);
		$("#email").text(g_indicateEmptyString);
		$("#role").text(g_indicateEmptyString);
		if (detail !== undefined) {
			userName = detail[0];
			$("#name").text(detail[0]);
			if (detail[4] !== null && detail[4].trim() !== "")
				$("#email").text(detail[4]);
			if (detail[1] !== null && detail[1].trim() !== "")
				$("#role").text(detail[1]);
		}

		var attendanceList = JSON.parse(logData["profile"]);
		$("#attendanceList").empty();
		if (attendanceList !== undefined) {
			if (attendanceList.length > 0) {
				dateArray = [];
				inTimeArray = [];
				outTimeArray = [];

				for (var i = 0; i < attendanceList.length; i++) {
					var splitArray = attendanceList[i][6].split(' ');
					var showText = splitArray[0].replace(/\//g, '-');
					dateArray.push(showText);

					if (attendanceList[i][7] === null || attendanceList[i][7] === '')
						inTimeArray[showText] = g_indicateEmptyString;
					else {
						inTimeArray[showText] = attendanceList[i][7].replace(/\//g, '-');
					}

					if (attendanceList[i][8] === null || attendanceList[i][8] === '')
						outTimeArray[showText] = g_indicateEmptyString;
					else {
						outTimeArray[showText] = attendanceList[i][8].replace(/\//g, '-');
					}
				}

				if (dateArray.length > 0) {
					var appendStr = "";
					appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
					appendStr += "<thead>" +
						"	<th style=\"max-width:120px; text-align: center;\">Date</th>" +
						"	<th style=\"max-width:120px; text-align: center;\">Time-In</th>" +
						"	<th style=\"max-width:120px; text-align: center;\">Time-out</th>";
					appendStr += "</thead>" +
						"	<tbody>";

					for (var i = 0; i < dateArray.length; i++) {
						appendStr += "<tr>";
						appendStr += "<td style=\"max-width:120px; text-align: center;\">" + dateArray[i] + "</td>";
						appendStr += "<td style=\"max-width:120px; text-align: center;\">" + inTimeArray[dateArray[i]] + "</td>";
						appendStr += "<td style=\"max-width:120px; text-align: center;\">" + outTimeArray[dateArray[i]] + "</td>";
						appendStr += "</tr>";
					}

					appendStr += "</tbody>";
					appendStr += "</table>";
					$('#attendanceList').append(appendStr);
				}
			}
		}
	}

	function sendEmail() {
		<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
		sendingEmail = true;
		sendEmailByCategory('<?= EMAIL_STAFF_PROFILE ?>', dateForSearch);
		<? } else { ?>
		showAlertDialog(g_selectShop);
		<? } ?>
	}

	function sendEmailByCategory(categoryId, searchDate) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['sqlNo'] = categoryId;
		postdata['currentUserName'] = userName;
		postdata['searchDate'] = searchDate;

		sendAjax('/staff/sendEmailByCategory', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
				{
					requestUniqueID = data['data']['uniqueId'];
					waitingToGetResponse();
				}
				else if (code === 2)
				{
					showLoadingFailedWithContent("Connection Failed!");
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
</script>
