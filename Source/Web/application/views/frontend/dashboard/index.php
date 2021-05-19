<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content my-content">
        <div class="title-area">
            <div class="top-title-left">
                <h3 class="page-title"> Dashboard </h3>
            </div>
			<? $this->load->view('/frontend/template/shopName'); ?>
        </div>

        <div class="main-content" id="main-content">

            <div class="main-part-content">
				<div class="col-md-12">
					<div class="portlet light">
						<div class="page-content-box">
							<div class="transaction-content">
								<div>
									<div class="dashboard-subtitle">
										<label class="">Shop information</label>
									</div>
									<hr class="dashboard-line">
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Operation date</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="current-date">---</label>
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Shift</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="current-shift">---</label>
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Opened time</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="opened-time">---</label>
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Opened by</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="opened-by">---</label>
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Drawer amount</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="drawer-amount">---</label>
								</div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">No</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="no">---</label>
								</div>

							</div>

						</div>
					</div>
				</div>
            </div>

            <div class="main-part-content">
				<div class="col-md-12">
					<div class="portlet light ">
						<div>
							<div class="dashboard-subtitle">
								<label class=""> Machine status</label>
							</div>
							<hr class="dashboard-line">
						</div>

						<div class="portlet-body portlet-body-overflow">
							<table class="table table-striped table-bordered table-hover table-checkable order-column" >
								<thead>
									<tr>
										<th> Machine</th>
										<th class="thead-style"> Status</th>
										<th class="thead-style"> Remaining time </th>
									</tr>
								</thead>
								<tbody id="machine-body">
								</tbody>
							</table>
						</div>
					</div>
				</div>
            </div>

            <div class="main-part-content">
				<div class="col-md-12">
					<div class="portlet light ">
						<div>
							<div class="dashboard-subtitle">
								<label class="">Inventory</label>
							</div>
							<hr class="dashboard-line">
						</div>

						<div class="margin-top-10 top-search-select" style="float: left;">
							<select class="bs-select form-control" id="category-list" style="width: 150px;" onchange="selectCategory(this.value);">
							</select>
						</div>

						<div class="portlet-body portlet-body-overflow" style="height: 250px;">
							<table class="table table-striped table-bordered table-hover table-checkable order-column" style="width: 800px; overflow-x: auto">
								<thead>
									<tr>
										<th style='text-align: center; width: 200px;'> Code</th>
										<th style='text-align: center'> Unit</th>
										<th style='text-align: center'> Available</th>
										<th style='text-align: center'> Usage</th>
										<th style='text-align: center'> Storage </th>
										<th style='text-align: center'> Status </th>
									</tr>
								</thead>
								<tbody id="inventory-body">
								</tbody>
							</table>
						</div>
					</div>
				</div>
            </div>

            <div class="main-part-content">
				<div class="col-md-12">
					<div class="portlet light ">
						<div>
							<div class="dashboard-subtitle">
								<label class="">Staff</label>
							</div>
							<hr class="dashboard-line">
						</div>

						<div class="portlet-body portlet-body-overflow">
							<table class="table table-striped table-bordered table-hover table-checkable order-column" >
								<thead>
									<tr>
										<th style="max-width: 100px; min-width: 100px;"> Username</th>
										<th style='text-align: center'> Role </th>
										<th style="text-align: center"> In / out time</th>
									</tr>
								</thead>
								<tbody id="staff-body">
								</tbody>
							</table>
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

	.my-content {
		min-height: 1000px !important;
	}
</style>

<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
<script type="text/javascript">
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/dashboard/waitingToGetResponse';
	var searchCategory = "";
	var isFirstLoad = true;
	var isStartTimer = false;
	var machineData;

	$(document).ready(function(){
		waitingToGetResponse();
	});


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

		if (isFirstLoad) {
			isFirstLoad = false;
			showAllData(data);
		} else {
			showOnlyInventory(data);
		}
	}

	function initCategoryList(categoryList) {
		for (var i = 0; i < categoryList.length; i++) {
			$('#category-list').append("<option value='" + categoryList[i] + "'>" + categoryList[i] +"</option>");
		}
	}

	function selectCategory(category) {
		searchCategory = category;

		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['searchCategory'] = searchCategory;

		sendAjax('/dashboard/getOnlyInventory', postdata, function (data) {
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

	function showAllData(data) {
		var logData = JSON.parse(data);

		// set category data
		$('#category-list').empty();
		var category = JSON.parse(logData["category"]);
		if (category !== undefined) {
			initCategoryList(category);
		}

		// set data on shop information
		var dashboard1 = JSON.parse(logData["dashboard1"])[0];
		if (dashboard1 !== undefined) {
			var datetime = dashboard1[1].split(" ");
			$("#current-date").text(datetime[0]);
			$("#current-shift").text(dashboard1[0]);
			$("#opened-time").text(datetime[1]);
			$("#opened-by").text(dashboard1[2]);
			$("#drawer-amount").text(dashboard1[3]);
			$("#no").text(dashboard1[4]);
		}

		// set data on machine status
		var dashboard2 = JSON.parse(logData["dashboard2"]);
		if (dashboard2 !== undefined) {
			if (dashboard2.length > 0) {
				machineData = dashboard2;
				showMachineStatus();
			}
		}

		// set data on inventory
		var dashboard3 = JSON.parse(logData["dashboard3"]);
		if (dashboard3 !== undefined) {
			if (dashboard3.length > 0) {
				for (i = 0; i < dashboard3.length; i++) {
					var status = "True";
					if (parseInt(dashboard3[i][4]) !== 0) {
						if (parseInt(dashboard3[i][2]) - parseInt(dashboard3[i][3]) < parseInt(dashboard3[i][4]))
							status = "False";
					}

					$("#inventory-body").append("<tr class=\"odd gradeX\">\n" +
						"<td style='text-align: center'>" + dashboard3[i][0] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][1] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][2] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][3] + "</td>\n" +
						"<td style='text-align: center'>" + (parseInt(dashboard3[i][2]) - parseInt(dashboard3[i][3])) + "</td>\n" +
						"<td style='text-align: center'>" + status + "</td>\n" +
						"</tr>");
				}
			}
		}

		// set data on staff
		var dashboard4 = JSON.parse(logData["dashboard4"]);
		if (dashboard4 !== undefined) {
			if (dashboard4.length > 0) {
				for (i = 0; i < dashboard4.length; i++) {
					var showText = "";
					if (dashboard4[i][4] === "") {
						showText = g_indicateEmptyString;
					} else {
						showText = dashboard4[i][4].replace(/\//g, '-');
					}
					showText += " / ";
					if (dashboard4[i][5] === "") {
						showText += g_indicateEmptyString;
					} else {
						showText += dashboard4[i][5].replace(/\//g, '-');
					}

					$("#staff-body").append("<tr class=\"odd gradeX\">\n" +
						"<td>" + dashboard4[i][0] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard4[i][1] + "</td>\n" +
						"<td style='text-align: center'>" + showText + "</td>\n" +
						"</tr>");
				}
			}
		}
	}

	function getCorrectTimeFormat(date) {
		var splitArray = date.split(' ');
		var returnDate = "";
		if (splitArray.length > 1) {
			var dateArray = splitArray[0].split('/');
			returnDate = dateArray[2]+'/'+dateArray[1]+'/'+dateArray[0]+' '+splitArray[1];

			if (splitArray.length === 3)
				returnDate = returnDate+' ' + splitArray[2];
		}

		return returnDate;
	}

	function showMachineStatus() {
		$("#machine-body").empty();
		var dashboard2 = machineData;
		for (var i = 0; i < dashboard2.length; i++) {
			var available = str_available;
			var duration = g_indicateEmptyString;
			var currentSecond = parseInt(new Date().getTime()/1000);
			if (dashboard2[i][2] === str_onUse) {
				// var date = dashboard2[i][5].substring(0,19);
				var date = getCorrectTimeFormat(dashboard2[i][5].replace(/-/g,'/'));
				var startSecond = parseInt(new Date(date).getTime()/1000);

				var durationSecond = parseInt(dashboard2[i][4]) * 60 - (currentSecond - startSecond);
				if (durationSecond > 0) {
					available = str_onUse;
					duration = (parseInt(durationSecond / 60) + 1) + " min";
				}
			}

			$("#machine-body").append("<tr class=\"odd gradeX\">\n" +
				"<td>" + dashboard2[i][1] + "</td>\n" +
				"<td style='text-align: center'>" + available + "</td>\n" +
				"<td style='text-align: center'>" + duration + "</td>\n" +
				"</tr>");
		}

		if (!isStartTimer) {
			isStartTimer = true;
			setInterval("showMachineStatus()", 5000);
		}
	}

	function showOnlyInventory(data) {
		$("#inventory-body").empty();

		var logData = JSON.parse(data);
		var dashboard3 = JSON.parse(logData["dashboard3"]);
		if (dashboard3 !== undefined) {
			if (dashboard3.length > 0) {
				for (i = 0; i < dashboard3.length; i++) {
					var status = "True";
					if (parseInt(dashboard3[i][4]) !== 0) {
						if (parseInt(dashboard3[i][2]) - parseInt(dashboard3[i][3]) < parseInt(dashboard3[i][4]))
							status = "False";
					}

					$("#inventory-body").append("<tr class=\"odd gradeX\">\n" +
						"<td style='text-align: center'>" + dashboard3[i][0] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][1] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][2] + "</td>\n" +
						"<td style='text-align: center'>" + dashboard3[i][3] + "</td>\n" +
						"<td style='text-align: center'>" + (parseInt(dashboard3[i][2]) - parseInt(dashboard3[i][3])) + "</td>\n" +
						"<td style='text-align: center'>" + status + "</td>\n" +
						"</tr>");
				}
			}
		}
	}
</script>
<? } ?>
