<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Customer profile and account </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <div class="content-move">
							<div class="move-left">
								<img class="move-left back-button" src="<?= SERVER_ADDRESS?>/include/img/back_icon.png" onclick="pageMove('/customer/index')">
								<div class="move-left" onclick="clickPrevButton()" style="margin-top: 6px;">
									<img src="<?=SERVER_ADDRESS ?>/include/img/arrow_prev.png" class="img-responsive" >
								</div>
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
                                    <label class="">Customer information</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Name</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="name">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Address</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="address">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Mobile</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="mobile">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Email</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="email">---</label>
                                </div>

                                <div class="col-md-5 info-item-margin">
                                    <label class=" item-left">Balance</label>
                                </div>
                                <div class="col-md-5 info-item-margin">
                                    <label class="item-right" id="balance">---</label>
                                </div>
                            </div>

                            <div class="transaction-content col-md-6 content-right">
                                <div class="item-content-tile">
                                    <label class="">Transaction</label>
                                </div>
								<div class="content-body-overflow" id="transactionList">
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
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var clientId = "<?= $clientId ?>";
	var requestURL = '/customer/waitingToGetResponse';

	$(document).ready(function(){
		waitingToGetResponse();
	});

	function getAnotherUniqueID(isPrev) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['currentClientID'] = clientId;
		if (isPrev)
			postdata['isPrev'] = 1;
		else
			postdata['isPrev'] = 2;

		sendAjax('/customer/getAnotherUniqueID', postdata, function (data) {
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
		var detail = JSON.parse(logData["detail"])[0];
		$("#name").text(g_indicateEmptyString);
		$("#address").text(g_indicateEmptyString);
		$("#mobile").text(g_indicateEmptyString);
		$("#email").text(g_indicateEmptyString);
		$("#balance").text(g_indicateEmptyString);
		if (detail !== undefined) {
			clientId = detail[0];
			$("#name").text(detail[1] + " " + detail[2]);
			if (detail[4] !== null && detail[4].trim() !== "")
				$("#address").text(detail[4]);
			if (detail[5] !== null && detail[5].trim() !== "")
				$("#mobile").text(detail[5]);
			if (detail[6] !== null && detail[6].trim() !== "")
				$("#email").text(detail[6]);
			if (detail[7] !== null && detail[7].trim() !== "")
				$("#balance").text(detail[7]);
		}

		var transactionList = JSON.parse(logData["transaction"]);
		$("#transactionList").empty();
		if (transactionList !== undefined) {
			if (transactionList.length > 0) {
				for (var i = 0; i < transactionList.length; i++) {
					var isPaid = false;
					var imgFileName = "";
					var parentClassName = "";
					var childClassName = "";
					if (transactionList[i][3] === null || transactionList[i][3] === "") {
						isPaid = true;
						imgFileName = "block_copy_icon.png";
						parentClassName = "item-container-red";
						childClassName = "list-content-item-red";
					} else {
						isPaid = false;
						imgFileName = "ok_copy_icon.png";
						parentClassName = "item-container";
						childClassName = "list-content-item";
					}

					$("#transactionList").append("<div class=\""+parentClassName+"\">\n" +
						"     <div class=\""+childClassName+"\" id=\"item" + i + "\">\n" +
						"         <div class=\"image-area col-md-2\">\n" +
						"             <img src=\"<?=SERVER_ADDRESS ?>/include/img/" + imgFileName + "\" class=\"img-responsive item-check-round\">\n" +
						"         </div>\n" +
						"         <div class=\"col-md-10\">\n" +
						"             <label class=\"col-md-3 bold\">Operation ID</label>\n" +
						"             <label class=\"col-md-3\">" + transactionList[i][1] + "</label>\n" +
						"             <label class=\"col-md-3 bold\">Amount</label>\n" +
						"             <label class=\"col-md-3\">" + transactionList[i][2] + "</label>\n" +
						"             <label class=\"col-md-3 info-item-margin bold\">Date & Time</label>\n" +
						"             <label class=\"col-md-6 info-item-margin\">" + transactionList[i][0] + "</label>\n" +
						"         </div>\n" +
						"     </div>\n" +
						" </div>");
				}
			}
		}
	}
</script>
