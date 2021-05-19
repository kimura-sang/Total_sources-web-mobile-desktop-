<div class="tab-pane active" id="item-sold">
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

				<div class="report-item-label info-item-margin" id="date-label">
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
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/report/waitingToGetResponse';
	var sendingEmail = false;

	$(document).ready(function () {
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

		if (!sendingEmail)
			showGraph(data);
	}
	<? } ?>

	function sendEmail() {
		<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
		sendingEmail = true;
		sendEmailByCategory('<?= EMAIL_REPORTS_ITEM_SOLD ?>', searchType, dateForSearch);
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
		postdata['sqlNo'] = '<?= REPORTS_ITEM_SOLD?>';
		postdata['searchType'] = searchType;
		postdata['newDate'] = newDate;

		sendAjax('/report/requestNewUniqueID', postdata, function (data) {
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

	function showGraph(data) {
		$('#report-chat').empty();

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

	function showHourlyGraph(data) {
		var timeArray = [];
		var preparationArray = [];
		var amountArray = [];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!timeArray.contain(results[i][2]))
					timeArray.push(results[i][2]);
				if (!preparationArray.contain(results[i][3]))
					preparationArray.push(results[i][3]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				if (amountArray[preparationArray[i]] === undefined)
					amountArray[preparationArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[preparationArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				var timeIndex = timeArray.findIndex(function(time) {
					return time === results[i][2];
				});
				amountArray[results[i][3]][timeIndex] = parseInt(results[i][4]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				var temp = {};
				temp['name'] = preparationArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[preparationArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, preparationArray, resultArray);
		}
	}

	function showDailyGraph(data) {
		var timeArray = [];
		var preparationArray = [];
		var amountArray = [];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!timeArray.contain(results[i][2]))
					timeArray.push(results[i][2]);
				if (!preparationArray.contain(results[i][3]))
					preparationArray.push(results[i][3]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				if (amountArray[preparationArray[i]] === undefined)
					amountArray[preparationArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[preparationArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				var timeIndex = timeArray.findIndex(function(time) {
					return time === results[i][2];
				});
				amountArray[results[i][3]][timeIndex] = parseInt(results[i][4]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				var temp = {};
				temp['name'] = preparationArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[preparationArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, preparationArray, resultArray);
		}
	}

	function showWeeklyGraph(data) {
		var timeArray = [];
		var preparationArray = [];
		var amountArray = [];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!timeArray.contain(results[i][0]))
					timeArray.push(results[i][0]);
				if (!preparationArray.contain(results[i][2]))
					preparationArray.push(results[i][2]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				if (amountArray[preparationArray[i]] === undefined)
					amountArray[preparationArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[preparationArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				var timeIndex = timeArray.findIndex(function(time) {
					return time === results[i][0];
				});
				amountArray[results[i][2]][timeIndex] = parseInt(results[i][3]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				var temp = {};
				temp['name'] = preparationArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[preparationArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, preparationArray, resultArray);
		}
	}

	function showMonthlyGraph(data) {
		var timeArray = [];
		var preparationArray = [];
		var amountArray = [];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!timeArray.contain(results[i][0]))
					timeArray.push(results[i][0]);
				if (!preparationArray.contain(results[i][1]))
					preparationArray.push(results[i][1]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				if (amountArray[preparationArray[i]] === undefined)
					amountArray[preparationArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[preparationArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				var timeIndex = timeArray.findIndex(function(time) {
					return time === results[i][0];
				});
				amountArray[results[i][1]][timeIndex] = parseInt(results[i][2]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				var temp = {};
				temp['name'] = preparationArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[preparationArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, preparationArray, resultArray);
		}
	}

	function showYearlyGraph(data) {
		var timeArray = [];
		var preparationArray = [];
		var amountArray = [];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!timeArray.contain(results[i][0]))
					timeArray.push(results[i][0]);
				if (!preparationArray.contain(results[i][1]))
					preparationArray.push(results[i][1]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				if (amountArray[preparationArray[i]] === undefined)
					amountArray[preparationArray[i]] = [];

				for (var j = 0; j < timeArray.length; j++)
					amountArray[preparationArray[i]][j] = 0;
			}

			for (var i = 0; i < results.length; i++) {
				var timeIndex = timeArray.findIndex(function(time) {
					return time === results[i][0];
				});
				amountArray[results[i][1]][timeIndex] = parseInt(results[i][2]);
			}

			for (var i = 0; i < preparationArray.length; i++) {
				var temp = {};
				temp['name'] = preparationArray[i];
				temp['type'] = 'bar';
				temp['data'] = amountArray[preparationArray[i]];

				resultArray.push(temp);
			}

			showBarChartGraph(timeArray, preparationArray, resultArray);
		}
	}

	function showBarChartGraph(timeArray, preparationArray, resultArray) {
		var myChart = barChartData.init(document.getElementById('report-chat'));
		myChart.setOption({
			tooltip: {
				trigger: 'axis'
			},
			legend: {
				data: preparationArray
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
</script>
