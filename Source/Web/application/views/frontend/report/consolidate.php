<div class="tab-pane active" id="sales-report">
	<div class="report-content">
		<div class="page-content-box">
			<div class="transaction-content col-md-12 content-middle">
				<div class="report-item-label info-item-margin">
					<label class=" item-left report-left">Type</label>
				</div>
				<div class="report-item">
					<div class="form-group input-group" style="width: 100%">
						<select class="form-control input-round-box" onchange="selectType(this.value); return false;">
							<option value="Hourly">Hourly</option>
							<option value="Daily">Daily</option>
							<option value="Weekly">Weekly</option>
							<option value="Monthly">Monthly</option>
							<option value="Yearly">Yearly</option>
						</select>
					</div>
				</div>

				<div class="report-item-label info-item-margin">
					<label class=" item-left report-left">Date</label>
				</div>
				<div class="report-item">
					<div class="form-group input-group date date-picker" data-date-format="yyyy-mm-dd" id="date-and-month-container">
						<input type="text" class="form-control input-round-box" id="date-and-month" readonly onchange="selectDateForSearch(this.value);">
						<span class="input-group-btn">
							<button class="btn default button-calendar" style="margin-left: 5px;" type="button">
								<i class="fa fa-calendar"></i>
							</button>
						</span>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="report-content">
		<div class="report-graph ">
			<div class="col-md-12">
				<div class="portlet light bordered">
					<div id="report-chat" style="height:500px;"></div>
				</div>
			</div>
			<div class="col-md-12" style="overflow: auto;">
				<div id="analysis-part"></div>
			</div>
		</div>
	</div>
</div>

<script src="<?=ASSETS_DIR ?>/global/plugins/echarts/echarts.js" type="text/javascript"></script>

<script type="text/javascript">
	var barChartData;
	jQuery(document).ready(function() {
		require.config({
			paths: {
				echarts: '<?=ASSETS_DIR ?>/global/plugins/echarts/'
			}
		});

		require(
			[
				'echarts',
				'echarts/chart/bar'
			],
			function(ec) {
				barChartData = ec;
			}
		);
	});

	<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
	var requestUniqueIDs = '<?= $requestUniqueIDs ?>';
	var sendingEmail = false;

	$(document).ready(function () {
		waitingToGetResponse();
	});

	function waitingToGetResponse() {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);
		setTimeout(getConsolidateResult, 7000);
	}

	function getConsolidateResult() {
		var postdata = {};
		postdata['requestUniqueIDs'] = requestUniqueIDs;

		sendAjax('/report/getConsolidateResult', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
				{
					if (data['data'] !== undefined)
						showData(data['data']);
					else {
						showLoadingDiv(false);
						showLoadingFailed(false);
						showMainContent(true);
					}
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

	function showData(data) {
		showLoadingDiv(false);
		showLoadingFailed(false);
		showMainContent(true);

		if (!sendingEmail)
			showGraph(data);
	}
	<? } ?>

	function sendEmail() {
		<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
		sendingEmail = true;
		sendConsolidateEmailByCategory(searchType, dateForSearch);
		<? } else { ?>
		showAlertDialog(g_selectShop);
		<? } ?>
	}

	var dateForSearch = "";
	var searchType = str_hourly;

	function selectDateForSearch(value) {
		if (dateForSearch !== value) {
			dateForSearch = value;
			requestNewUniqueID(value);
		}
	}

	function selectType(type) {
		searchType = type;
		requestNewUniqueID(dateForSearch);
	}

	function requestNewUniqueID(newDate) {
		sendingEmail = false;

		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['searchType'] = searchType;
		postdata['newDate'] = newDate;

		sendAjax('/report/requestNewConsolidateUniqueID', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
				{
					requestUniqueIDs = data['data']['requestUniqueIDs'];
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

	function showGraph(data) {
		$('#report-chat').empty();
		$('#analysis-part').empty();

		switch (searchType) {
			case str_hourly:
				showHourlyGraph(data);
				break;
			case str_daily:
				showDailyGraph(data);
				break;
			case str_weekly:
				showWeeklyGraph(data);
				break;
			case str_monthly:
				showMonthlyGraph(data);
				break;
			case str_yearly:
				showYearlyGraph(data);
				break;
		}
	}

	function showHourlyGraph(results) {
		var timeArray = [];
		var branchArray = [];
		var amountArray = [];
		var resultArray = [];

		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!branchArray.contain(results[i]["branch"]))
					branchArray.push(results[i]["shopName"] + " - " +results[i]["branch"]);
				for (var j = 0; j < results[i]["data"].length; j++) {
					if (!timeArray.contain(parseInt(results[i]["data"][j][2])))
						timeArray.push(parseInt(results[i]["data"][j][2]));
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				if (amountArray[branchArray[i]] === undefined)
					amountArray[branchArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[branchArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				for (var j = 0; j < results[i]["data"].length; j++) {
					var timeIndex = timeArray.findIndex(function(time) {
						return time === parseInt(results[i]["data"][j][2]);
					});
					amountArray[results[i]["shopName"] + " - " +results[i]["branch"]][timeIndex] = parseInt(results[i]["data"][j][3]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				var temp = {};
				temp['name'] = branchArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[branchArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, branchArray, resultArray);
		}
	}

	function showDailyGraph(results) {
		var timeArray = [];
		var branchArray = [];
		var amountArray = [];
		var resultArray = [];

		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!branchArray.contain(results[i]["branch"]))
					branchArray.push(results[i]["shopName"] + " - " +results[i]["branch"]);
				for (var j = 0; j < results[i]["data"].length; j++) {
					if (!timeArray.contain(parseInt(results[i]["data"][j][2])))
						timeArray.push(parseInt(results[i]["data"][j][2]));
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				if (amountArray[branchArray[i]] === undefined)
					amountArray[branchArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[branchArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				for (var j = 0; j < results[i]["data"].length; j++) {
					var timeIndex = timeArray.findIndex(function(time) {
						return time === parseInt(results[i]["data"][j][2]);
					});
					amountArray[results[i]["shopName"] + " - " +results[i]["branch"]][timeIndex] = parseInt(results[i]["data"][j][3]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				var temp = {};
				temp['name'] = branchArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[branchArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, branchArray, resultArray);
		}
	}

	function showWeeklyGraph(results) {
		var timeArray = [];
		var branchArray = [];
		var amountArray = [];
		var resultArray = [];

		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!branchArray.contain(results[i]["branch"]))
					branchArray.push(results[i]["shopName"] + " - " +results[i]["branch"]);
				for (var j = 0; j < results[i]["data"].length; j++) {
					if (!timeArray.contain(parseInt(results[i]["data"][j][3])))
						timeArray.push(parseInt(results[i]["data"][j][3]));
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				if (amountArray[branchArray[i]] === undefined)
					amountArray[branchArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[branchArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				for (var j = 0; j < results[i]["data"].length; j++) {
					var timeIndex = timeArray.findIndex(function(time) {
						return time === parseInt(results[i]["data"][j][3]);
					});
					amountArray[results[i]["shopName"] + " - " +results[i]["branch"]][timeIndex] = parseInt(results[i]["data"][j][4]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				var temp = {};
				temp['name'] = branchArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[branchArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, branchArray, resultArray);
		}
	}

	function showMonthlyGraph(results) {
		var timeArray = [];
		var branchArray = [];
		var amountArray = [];
		var resultArray = [];

		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!branchArray.contain(results[i]["branch"]))
					branchArray.push(results[i]["shopName"] + " - " +results[i]["branch"]);
				for (var j = 0; j < results[i]["data"].length; j++) {
					if (!timeArray.contain(results[i]["data"][j][1]))
						timeArray.push(results[i]["data"][j][1]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				if (amountArray[branchArray[i]] === undefined)
					amountArray[branchArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[branchArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				for (var j = 0; j < results[i]["data"].length; j++) {
					var timeIndex = timeArray.findIndex(function(time) {
						return time === results[i]["data"][j][1];
					});
					amountArray[results[i]["shopName"] + " - " +results[i]["branch"]][timeIndex] = parseInt(results[i]["data"][j][3]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				var temp = {};
				temp['name'] = branchArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[branchArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, branchArray, resultArray);
		}
	}

	function showYearlyGraph(results) {
		var timeArray = [];
		var branchArray = [];
		var amountArray = [];
		var resultArray = [];

		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!branchArray.contain(results[i]["branch"]))
					branchArray.push(results[i]["shopName"] + " - " +results[i]["branch"]);
				for (var j = 0; j < results[i]["data"].length; j++) {
					if (!timeArray.contain(parseInt(results[i]["data"][j][0])))
						timeArray.push(parseInt(results[i]["data"][j][0]));
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				if (amountArray[branchArray[i]] === undefined)
					amountArray[branchArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[branchArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				for (var j = 0; j < results[i]["data"].length; j++) {
					var timeIndex = timeArray.findIndex(function(time) {
						return time === parseInt(results[i]["data"][j][0]);
					});
					amountArray[results[i]["shopName"] + " - " +results[i]["branch"]][timeIndex] = parseInt(results[i]["data"][j][1]);
				}
			}

			for (var i = 0; i < branchArray.length; i++) {
				var temp = {};
				temp['name'] = branchArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[branchArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, branchArray, resultArray);
		}
	}

	function showBarChartGraph(timeArray, branchArray, resultArray) {
		var myChart = barChartData.init(document.getElementById('report-chat'));
		myChart.setOption({
			tooltip: {
				trigger: 'axis'
			},
			legend: {
				data: branchArray
			},
			calculable: true,
			xAxis: [{
				type: 'category',
				data: timeArray
			}],
			yAxis: [{
				type: 'value',
				splitArea: {
					show: true
				}
			}],
			series: resultArray
		});
	}

	function sendConsolidateEmailByCategory(searchTyp, searchDate) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['searchType'] = searchTyp;
		postdata['searchDate'] = searchDate;

		sendAjax('/report/sendConsolidateEmailByCategory', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
				{
					setTimeout(showData, 4000);
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
