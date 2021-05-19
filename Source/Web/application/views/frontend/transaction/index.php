<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Transaction </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <div class="content-move">
                            <div class="move-left" onclick="clickPrevButton()">
								<img src="<?=SERVER_ADDRESS ?>/include/img/arrow_prev.png" class="img-responsive" >
                            </div>
                            <div class="move-right" onclick="clickNextButton()">
								<img src="<?=SERVER_ADDRESS ?>/include/img/arrow_next.png" class="img-responsive" >
                            </div>
                        </div>
                        <div>
                            <hr>
                        </div>

                        <div class="page-content-box">
                            <div class="transaction-content col-md-6 content-left">
                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Date</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="date">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Shift</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="shift">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Opened time</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="openTime">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Opened by</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="openUser">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Closed time</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="closeTime">---</label>
                                </div>

								<div class="col-md-5 info-item-margin">
									<label class=" item-left">Closed by</label>
								</div>
								<div class="col-md-5 info-item-margin">
									<label class="item-right" id="closeUser">---</label>
								</div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Gross sales</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="grossSale">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Cash received</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="cashReceive">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Cash count</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="cashCount">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Bank deposit</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="bankDeposit">---</label>
                                </div>
                            </div>

                            <div class="transaction-content col-md-6 content-right content-body-overflow" id="transactionList">
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

<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
<script type="text/javascript">
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/transaction/waitingToGetResponse';
	var transactionID = "";

	$(document).ready(function(){
		waitingToGetResponse();
	});

	function getAnotherUniqueID(isPrev) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		if (isPrev)
			postdata['isPrev'] = 1;
		else
			postdata['isPrev'] = 2;
		postdata['transactionID'] = transactionID;

		sendAjax('/transaction/getAnotherUniqueID', postdata, function (data) {
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
		getAnotherUniqueID(true);
	}

	function clickNextButton() {
		getAnotherUniqueID(false);

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
		var logData = JSON.parse(data);

		// set data on shop information
		var transactionShift = JSON.parse(logData["transactionShift"])[0];
		$("#date").text(g_indicateEmptyString);
		$("#shift").text(g_indicateEmptyString);
		$("#openTime").text(g_indicateEmptyString);
		$("#openUser").text(g_indicateEmptyString);
		$("#closeTime").text(g_indicateEmptyString);
		$("#closeUser").text(g_indicateEmptyString);
		$("#cashReceive").text(g_indicateEmptyString);
		$("#grossSale").text(g_indicateEmptyString);
		$("#cashCount").text(g_indicateEmptyString);
		$("#bankDeposit").text(g_indicateEmptyString);
		if (transactionShift !== undefined) {
			transactionID = transactionShift[0];

			var openDatetime = transactionShift[2].split(" ");
			var closeDatetime = transactionShift[4].split(" ");
			$("#date").text(openDatetime[0]);
			$("#shift").text(transactionShift[1]);
			$("#openTime").text(openDatetime[1]);
			$("#openUser").text(transactionShift[3]);
			if (transactionShift[4] !== "") {
				$("#closeTime").text(closeDatetime[1]);
				$("#closeUser").text(transactionShift[5]);
			}
			if (transactionShift[6].trim() !== "")
				$("#cashReceive").text(transactionShift[6]);
			if (transactionShift[7].trim() !== "")
				$("#grossSale").text(transactionShift[7]);
			if (transactionShift[8].trim() !== "")
				$("#cashCount").text(transactionShift[8]);
			if (transactionShift[9].trim() !== "")
				$("#bankDeposit").text(transactionShift[9]);
		}

		var transactionList = JSON.parse(logData["transactionList"]);
		$("#transactionList").empty();
		if (transactionList !== undefined) {
			if (transactionList.length > 0) {
				for (var i = 0; i < transactionList.length; i++) {
					var isPaid = false;
					var imgFileName = "";
					var parentClassName = "";
					var childClassName = "";
					if (transactionList[i][3] === "PAID") {
						parentClassName = "item-container";
						childClassName = "list-content-item";
					} else {
						parentClassName = "item-container-red";
						childClassName = "list-content-item-red";
					}

					$("#transactionList").append("<div class=\""+parentClassName+"\">\n" +
						"     <div class=\""+childClassName+"\" id=\"item" + i + "\">\n" +
						"         <div class=\"col-md-2\">\n" +
						"             <img src=\"<?=SERVER_ADDRESS ?>/include/img/admin.png\" class=\"img-responsive item-image-round\" >\n" +
						"         </div>\n" +
						"         <div class=\"col-md-10\">\n" +
						"             <label class=\"col-md-3 bold\">User name</label>\n" +
						"             <label class=\"col-md-3\">" + transactionList[i][2] + "</label>\n" +
						"             <label class=\"col-md-3 bold\">Operation ID</label>\n" +
						"             <label class=\"col-md-3\">" + transactionList[i][0] + "</label>\n" +
						"             <label class=\"col-md-3 info-item-margin bold\">Amount</label>\n" +
						"             <label class=\"col-md-3 info-item-margin\">" + transactionList[i][1] + "</label>\n" +
						"         </div>\n" +
						"     </div>\n" +
						" </div>");

				}
			}
		}
	}

</script>
<? } ?>
