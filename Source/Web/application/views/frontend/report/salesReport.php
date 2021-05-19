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
					<div id="report-chat" style="height:500px; display: none;"></div>
					<div id="horizontal-chat" class="chart" style="display: none;"> </div>
				</div>
			</div>
			<div class="col-md-12" style="overflow: auto;">
				<div id="analysis-part"></div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
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
		sendEmailByCategory('<?= EMAIL_REPORTS_SALES ?>', searchType, dateForSearch);
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
		switch (type) {
			case str_hourly:
			case str_daily:
			case str_weekly:
			case str_monthly:
				searchType = type;
				$('#date-label').css('display', 'block');
				$('#date-and-month-container').css('display', 'table');
				break;
			case str_yearly:
				searchType = str_yearly;
				$('#date-label').css('display', 'none');
				$('#date-and-month-container').css('display', 'none');
				break;
		}

		requestNewUniqueID(dateForSearch);
	}

	function requestNewUniqueID(newDate) {
		sendingEmail = false;

		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['sqlNo'] = '<?= REPORTS_SALES?>';
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

	function initGraph() {
		$('#report-chat').empty();
		$('#horizontal-chat').empty();
		$('#analysis-part').empty();

		$('#report-chat').css('display', 'none');
		$('#horizontal-chat').css('display', 'none');
	}

	function showGraph(data) {
		initGraph();

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
		$('#report-chat').css('display', 'block');

		var hourArray = [];
		var timeX = "time";
		var timeArray = [];
		var weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!hourArray.contain(parseInt(results[i][2]))) {
					hourArray.push(parseInt(results[i][2]));
					timeArray[parseInt(results[i][2])] = [];
					for (var j = 0; j < weekdays.length; j++)
						timeArray[parseInt(results[i][2])][weekdays[j]] = 0;
				}

				switch (results[i][1]) {
					case weekdays[0]:
						timeArray[parseInt(results[i][2])][weekdays[0]] += parseFloat(results[i][3]);
						break;
					case weekdays[1]:
						timeArray[parseInt(results[i][2])][weekdays[1]] += parseFloat(results[i][3]);
						break;
					case weekdays[2]:
						timeArray[parseInt(results[i][2])][weekdays[2]] += parseFloat(results[i][3]);
						break;
					case weekdays[3]:
						timeArray[parseInt(results[i][2])][weekdays[3]] += parseFloat(results[i][3]);
						break;
					case weekdays[4]:
						timeArray[parseInt(results[i][2])][weekdays[4]] += parseFloat(results[i][3]);
						break;
					case weekdays[5]:
						timeArray[parseInt(results[i][2])][weekdays[5]] += parseFloat(results[i][3]);
						break;
					case weekdays[6]:
						timeArray[parseInt(results[i][2])][weekdays[6]] += parseFloat(results[i][3]);
						break;
				}
			}

			for (var i = 0; i < hourArray.length; i++) {
				resultArray.push({
					time: hourArray[i].toString(),
					Monday: 	timeArray[hourArray[i]][weekdays[0]],
					Tuesday: 	timeArray[hourArray[i]][weekdays[1]],
					Wednesday: 	timeArray[hourArray[i]][weekdays[2]],
					Thursday: 	timeArray[hourArray[i]][weekdays[3]],
					Friday: 	timeArray[hourArray[i]][weekdays[4]],
					Saturday: 	timeArray[hourArray[i]][weekdays[5]],
					Sunday: 	timeArray[hourArray[i]][weekdays[6]]
				});
			}

			new Morris.Line({
				element: 'report-chat',
				data: resultArray,
				xkey: timeX,
				ykeys: weekdays,
				labels: weekdays,
				parseTime: false
			});


			// show data in table
			var appendStr = "";
			appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
			appendStr += "<thead>" +
				"	<th style=\"max-width:120px;\">&nbsp;</th>";
			for (var i = 0; i < hourArray.length; i++) {
				appendStr += "<th>"+hourArray[i]+"</th>";
			}
			appendStr += "</thead>" +
				"	<tbody>";
			for (var j = 0; j < weekdays.length; j++) {
				appendStr += "<tr>";
				appendStr += "<th style=\"max-width:120px;\">"+weekdays[j]+"</th>";
				for (var i = 0; i < hourArray.length; i++) {
					var intValue = 0;
					intValue = timeArray[hourArray[i]][weekdays[j]];
					if (intValue === undefined)
						intValue = 0;

					appendStr += "<td>"+intValue+"</td>";
				}
				appendStr += "</tr>";
			}
			appendStr += "</tbody>";
			appendStr += "</table>";
			$('#analysis-part').append(appendStr);
		}
	}

	function showDailyGraph(data) {
		$('#report-chat').css('display', 'block');

		var dateStart = 1;
		var dateEnd = 31;
		var dateX = "date";
		var dateArray = [];
		var months = [];
		var resultArray = [];

		for (var i = dateStart; i <= dateEnd; i++) {
			dateArray[i] = [];
		}

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				if (!months.contain(results[i][1]))
					months.push(results[i][1]);

				if (dateArray[parseInt(results[i][2])][results[i][1]] === undefined)
					dateArray[parseInt(results[i][2])][results[i][1]] = 0;

				dateArray[parseInt(results[i][2])][results[i][1]] += parseFloat(results[i][5]);
			}

			for (var i = dateStart; i <= dateEnd; i++) {
				var temp = {};
				temp[dateX] = i.toString()
				for (var j = 0; j < months.length; j++) {
					if (dateArray[i][months[j]] === undefined)
						temp[months[j]] = 0;
					else
						temp[months[j]] = parseInt(dateArray[i][months[j]]);
				}

				resultArray.push(temp);
			}

			new Morris.Line({
				element: 'report-chat',
				data: resultArray,
				xkey: dateX,
				ykeys: months,
				labels: months,
				parseTime: false
			});

			// show data in table
			var appendStr = "";
			appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
			appendStr += "<thead>" +
				"	<th style=\"max-width:120px;\">&nbsp;</th>";
			for (var i = dateStart; i <= dateEnd; i++) {
				appendStr += "<th>"+i+"</th>";
			}
			appendStr += "</thead>" +
				"	<tbody>";
			for (var j = 0; j < months.length; j++) {
				appendStr += "<tr>";
				appendStr += "<th style=\"max-width:120px;\">"+months[j]+"</th>";
				for (var i = dateStart; i <= dateEnd; i++) {
					var intValue = 0;
					intValue = dateArray[i][months[j]];
					if (intValue === undefined)
						intValue = 0;

					appendStr += "<td>"+intValue+"</td>";
				}
				appendStr += "</tr>";
			}
			appendStr += "</tbody>";
			appendStr += "</table>";
			$('#analysis-part').append(appendStr);
		}
	}

	function showWeeklyGraph(data) {
		$('#report-chat').css('display', 'block');

		var weekX = "week";
		var amount = "Amount";
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				var temp = {};
				temp[weekX] = results[i][0];
				temp[amount] = parseInt(results[i][1]);
				resultArray.push(temp);
			}

			new Morris.Line({
				element: 'report-chat',
				data: resultArray,
				xkey: weekX,
				ykeys: [amount],
				labels: [amount],
				parseTime: false
			});

			// show data in table
			var appendStr = "";
			var appendSubStr = "";
			appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
			appendStr += "<thead>" +
				"	<th style=\"max-width:100px;\">&nbsp;</th>";
			for (var i = 0; i < results.length; i++) {
				appendStr += "<th>"+results[i][0]+"</th>";

				var intValue = 0;
				intValue =  parseInt(results[i][1]);
				if (intValue === undefined)
					intValue = 0;
				appendSubStr += "<td>"+intValue+"</td>";
			}
			appendStr += "</thead>" + "<tbody><tr><td>Amount</td>" + appendSubStr + "</tr></tbody>";
			appendStr += "</table>";
			$('#analysis-part').append(appendStr);
		}
	}

	function showMonthlyGraph(data) {
		$('#report-chat').css('display', 'block');

		var year = 0;
		var monthX = "month";
		var amount = "Amount";
		var resultArray = [];

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				var temp = {};
				temp[monthX] = results[i][1];
				temp[amount] = parseInt(results[i][3]);
				resultArray.push(temp);
			}

			new Morris.Line({
				element: 'report-chat',
				data: resultArray,
				xkey: monthX,
				ykeys: [amount],
				labels: [amount],
				parseTime: false
			});

			// show data in table
			var appendStr = "";
			var appendSubStr = "";
			appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
			appendStr += "<thead>" +
				"	<th style=\"max-width:100px;\">&nbsp;</th>";
			for (var i = 0; i < results.length; i++) {
				appendStr += "<th>"+results[i][1]+"</th>";

				var intValue = 0;
				intValue = parseInt(results[i][3]);
				if (intValue === undefined)
					intValue = 0;
				appendSubStr += "<td>"+intValue+"</td>";
			}
			appendStr += "</thead>" + "<tbody><tr><td>Amount</td>" + appendSubStr + "</tr></tbody>";
			appendStr += "</table>";
			$('#analysis-part').append(appendStr);
		}
	}

	function showYearlyGraph(data) {
		$('#horizontal-chat').css('display', 'block');

		var resultArray = [];
		var sum = 0;

		var logData = JSON.parse(data);
		var results = JSON.parse(logData["result"]);
		if (results.length > 0) {
			for (var i = 0; i < results.length; i++) {
				var temp = {};
				temp["year"] = results[i][0];
				temp["amount"] = results[i][1];

				resultArray.push(temp);

				sum += parseInt(results[i][1]);
			}

			initChartSample4(resultArray);

			// show data in table
			var appendStr = "";
			appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
			appendStr += "<thead>" +
				"	<th style=\"max-width:120px;\">Year</th>" +
				"	<th style=\"max-width:120px;\">Amount</th>";
			appendStr += "</thead>" +
				"	<tbody>";
			for (var i = 0; i < results.length; i++) {
				appendStr += "<tr>";
				appendStr += "<td>" + results[i][0] + "</td>";
				appendStr += "<td>" + results[i][1] + "</td>";
				appendStr += "</tr>";
			}
			appendStr += "<tr>";
			appendStr += "<th>Total</th>";
			appendStr += "<th>" + sum + "</th>";
			appendStr += "</tr>";
			appendStr += "</tbody>";
			appendStr += "</table>";
			$('#analysis-part').append(appendStr);
		}
	}

	function initChartSample4(data) {
		var chart = AmCharts.makeChart("horizontal-chat", {
			"type": "serial",
			"theme": "light",
			"handDrawn": false,
			"handDrawScatter": 3,
			"legend": {
				"useGraphSettings": true,
				"markerSize": 12,
				"valueWidth": 0,
				"verticalGap": 0
			},
			"dataProvider": data,
			"valueAxes": [{
				"minorGridAlpha": 0.08,
				"minorGridEnabled": true,
				"position": "top",
				"axisAlpha": 0
			}],
			"startDuration": 1,
			"graphs": [{
				"balloonText": "<span style='font-size:13px;'>[[title]] in [[category]]:<b>[[value]]</b></span>",
				"title": "Amount",
				"type": "column",
				"fillAlphas": 0.8,
				"valueField": "amount"
			}],
			"rotate": true,
			"categoryField": "year",
			"categoryAxis": {
				"gridPosition": "start"
			},
			"title": false
		});

		$('#horizontal').closest('.portlet').find('.fullscreen').click(function() {
			chart.invalidateSize();
		});
	}

</script>
