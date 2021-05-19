<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Offer detail </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <div class="content-move">
                            <div class="move-left">
								<img class="move-left back-button" src="<?= SERVER_ADDRESS?>/include/img/back_icon.png" onclick="pageMove('/offer/index')">
                            </div>
                        </div>
                        <div>
                            <hr>
                        </div>

                        <div class="page-content-box">
							<div class="transaction-content col-md-6 content-left">
								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">Code</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-non-click" type="text" autocomplete="off" readonly name="code" id="code">
								</div>

								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">Category</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-non-click" type="text" autocomplete="off" readonly name="category" id="category">
								</div>

								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">Description</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-non-click" type="text" autocomplete="off" readonly name="name" id="name">
								</div>

								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">Price</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" name="price" id="price" onkeyup="onlyNumber(this,0);">
								</div>

								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">VATType</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-non-click" type="text" autocomplete="off" readonly name="vatType" id="vatType">
								</div>

								<div class="col-md-3 info-item-margin-25">
									<label class=" item-left">Preparation</label>
								</div>
								<div class="col-md-9 info-item-margin">
									<input class="form-control form-control-solid placeholder-no-fix offer-non-click" type="text" autocomplete="off" readonly name="preparation" id="preparation">
								</div>
							</div>


							<div class="col-md-1 info-item-margin-25" style="width: 85px;">
								<label class=" item-left">Content</label>
							</div>
							<div class="transaction-content col-md-6 content-right content-body-overflow" id="contentList" style="height: 275px; overflow-y: auto;">
							</div>

							<div class="middle-content">
                                <div class="col-md-10" style="margin-top: 20px; margin-bottom: 20px;">
                                    <hr style="border-top: 1px solid #606c6d;">
                                </div>
                                <div class="col-md-10 form-group">
                                    <button type="submit" class="btn green btn-block offer-save-button" onclick="saveOfferDetail(); return false;">Save</button>
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
	var requestURL = '/offer/waitingToGetResponse';
	var isSaving = false;

	$(document).ready(function(){
		isSaving = false;
		waitingToGetResponse();
	});

	function saveOfferDetail() {
		if ($("#price").val() === '') {
			showAlertDialog("Please input price", null, "nSofts");
		} else {
			isSaving = true;
			showMainContent(false);
			showLoadingDiv(true);
			showLoadingFailed(false);

			var postdata = {};
			postdata['code'] = "<?= $code ?>";
			postdata['price'] = $("#price").val();

			sendAjax('/offer/getAnotherUniqueID', postdata, function (data) {
				if (data != null) {
					var code = data['code'];
					if (code === 1) {
						requestUniqueID = data['data']['uniqueId'];
						waitingToGetResponse();
					} else if (code === 2) {
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

		return false;
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

		if (!isSaving) {
			$('#contentList').empty();
			var logData = JSON.parse(data);

			// set data on shop information
			var detail = JSON.parse(logData["detail"])[0];
			if (detail !== undefined) {
				if (detail[0] !== null && detail[0].trim() !== "")
					$("#code").val(detail[0]);
				if (detail[1] !== null && detail[1].trim() !== "")
					$("#category").val(detail[1]);
				if (detail[2] !== null && detail[2].trim() !== "")
					$("#name").val(detail[2]);
				if (detail[3] !== null && detail[3].trim() !== "")
					$("#price").val(detail[3]);
				if (detail[4] !== null && detail[4].trim() !== "")
					$("#vatType").val(detail[4]);
				if (detail[5] !== null && detail[5].trim() !== "")
					$("#preparation").val(detail[5]);
			}

			var content = JSON.parse(logData["content"]);
			if (content !== undefined) {
				// show data in table
				var appendStr = "";
				appendStr = "<table class=\"table table-striped table-bordered table-hover table-checkable order-column\">";
				appendStr += "<thead>" +
					"	<th style=\"max-width:120px;\">No</th>" +
					"	<th style=\"max-width:120px;\">Description</th>" +
					"	<th style=\"max-width:120px;\">Count</th>" +
					"	<th style=\"max-width:120px;\">Unit</th>";
				appendStr += "</thead>" +
					"	<tbody>";

				for (var i = 0; i < content.length; i++) {
					appendStr += "<tr>";
					appendStr += "<td style=\"max-width:120px;\">"+(i+1)+"</td>";
					appendStr += "<td style=\"max-width:120px;\">"+content[i][1]+"</td>";
					appendStr += "<td style=\"max-width:120px;\">"+content[i][2]+"</td>";
					appendStr += "<td style=\"max-width:120px;\">"+content[i][3]+"</td>";
					appendStr += "</tr>";
				}

				appendStr += "</tbody>";
				appendStr += "</table>";
				$('#contentList').append(appendStr);
			}
		} else {
			showAlertDialog("Successfully saved!", function () {
				pageMove('/offer/index');
			}, "nSofts");
		}
	}
</script>
