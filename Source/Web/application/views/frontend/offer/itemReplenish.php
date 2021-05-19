<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Item replenish </h3>
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
                            <div class="move-right">
                                <a id="" class="btn sbold red-haze add-button" onclick="showAddReplenishDialog(); return false;"> Add New
                                    <i class="fa fa-plus"></i>
                                </a>
                            </div>
                        </div>
                        <div>
                            <hr>
                        </div>

                        <div class="page-content-box">
                            <table class="table table-striped table-bordered table-hover table-checkable order-column" id="data-table">
                                <thead>
                                <tr>
                                    <th> No</th>
                                    <th> Item name </th>
									<th> Quantity </th>
                                    <th> Unit </th>
                                    <th> Expired date</th>
                                    <th> Actions </th>
                                </tr>
                                </thead>
                            </table>
                        </div>
                    </div>

                    <div class="middle-content">
                        <div class="" style="margin-top: 20px; margin-bottom: 20px;">
                            <hr style="border-top: 1px solid #606c6d;">
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn green btn-block offer-save-button" onclick="saveAllItemReplenishToRealDB(); return false;">Save</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="replenishDialog" tabindex="0" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" style="margin-top: 120px; overflow-y: hidden">
	<div class="modal-dialog" style="width: 450px; ">
		<div class="modal-content" style=" border-radius: 5px;">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">×</button>
				<h4 id="loginDialogTitle">Add new replenish</h4>
			</div>
			<div class="modal-body" style="text-align: center; padding: 0px;">
				<div class="alert alert-danger" style="background-color: white; display: none;" id="error_div">
					<span id="error" style="color: #e73d4a;">  </span>
				</div>
				<div class=" dialog-content">
					<div class="form-group dialog-item">
						<label class="control-label col-md-4 margin-top-10 item-title ">Item category</label>
						<div class="col-md-8 margin-top-10">
							<select class="bs-select form-control input-round-box" id="offer-item-category" onchange="selectNewCategory(this.value); return false;">
							</select>
						</div>
					</div>
					<div class="form-group dialog-item">
						<label class="control-label col-md-4 margin-top-10 item-title ">Item replenish</label>
						<div class="col-md-8 margin-top-10">
							<select class="bs-select form-control input-round-box" id="offer-item-replenish" onchange="selectItemReplenish(this.value); return false;">
							</select>
						</div>
					</div>
					<div class="form-group dialog-item">
						<label class="control-label col-md-4 margin-top-10 item-title ">Quantity</label>
						<div class="col-md-8 margin-top-10">
							<input class="bs-select form-control input-round-box" type="text" id="offer-quantity" onkeyup="onlyNumber(this,0);" />
						</div>
					</div>
					<div class="form-group dialog-item">
						<label class="control-label col-md-4 margin-top-10 item-title ">Unit</label>
						<div class="col-md-8 margin-top-10">
							<input class="bs-select form-control input-round-box" type="text" id="offer-unit" readonly />
						</div>
					</div>
					<div class="form-group dialog-item">
						<label class="control-label col-md-4 margin-top-10 item-title ">Expire date</label>
						<div class="col-md-8 margin-top-10">
							<div class="input-group date date-picker" data-date-format="yyyy-mm-dd" data-date-start-date="+0d">
								<input type="text" class="form-control input-round-box" readonly id="offer-expired-date" />
								<span class="input-group-btn">
                                    <button class="btn default button-calendar" type="button" style="margin-left: 5px;">
                                        <i class="fa fa-calendar"></i>
                                    </button>
                                </span>
							</div>
						</div>
					</div>
					<input type="hidden" id="offer-item-code" value="" />
				</div>
				<hr style="margin: 0" />
				<div class="dialog-footer">
					<div class="button-container" >
						<button class="btn blue btn-outline dialog-button" onclick="addNewItemReplenish(); return false;">Add</button>
					</div>`
					<div class="button-container" style="margin-right: 30px;">
						<button class="btn dark btn-outline dialog-button" data-dismiss="modal" >Cancel</button>
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
	<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/offer/waitingToGetResponse';
	var isFirstLoad = true;
	var itemReplenishArray = [];
	var itemCodeArray = [];

	$(document).ready(function() {
		waitingToGetResponse();
		initReplenishTable();
	});

	function initReplenishTable() {
		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;	// premium

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/offer/getTempItemReplenish",
					'data': postdata
				}
			}
		);
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

		if (isFirstLoad) {
			isFirstLoad = false;
			showItemCategories('#offer-item-category', data);
		} else {
			showItemCategories('#offer-item-replenish', data);
		}
	}

	function showItemCategories(tagId, data) {
		$(tagId).empty();

		var logData = JSON.parse(data);
		var options = JSON.parse(logData["options"]);
		if (options.length > 0) {
			for (var i = 0; i < options.length; i++) {
				$(tagId).append("<option value='" + options[i][0] + "'>" + options[i][0] +"</option>");

				if (tagId === '#offer-item-replenish') {
					itemReplenishArray[options[i][0]] = options[i][1];
					itemCodeArray[options[i][0]] = options[i][2];
				}
			}

			if (tagId === '#offer-item-category')
				selectNewCategory(options[0][0]);

			if (tagId === '#offer-item-replenish') {
				$('.modal-content').css('display', 'block');
				selectItemReplenish(options[0][0]);
			}
		}
	}

	function selectNewCategory(itemCategory) {
		$('.modal-content').css('display', 'none');

		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['itemCategory'] = itemCategory;

		sendAjax('/offer/getItemReplenishFromWindowsService', postdata, function (data) {
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

	function selectItemReplenish(item) {
		$('#offer-unit').val(itemReplenishArray[item]);
		$('#offer-item-code').val(itemCodeArray[item]);
	}

	function showDlgError(content) {
		$('#error_div').css('display', 'block');
		$('#error').text(content);
		setTimeout(hideDlgError, 2000);
	}

	function hideDlgError() {
		$('#error_div').css('display', 'none');
	}

	function addNewItemReplenish() {
		if ($('#offer-quantity').val() === '') {
			showDlgError("Please select offer quantity");
			return false;
		}

		$('#replenishDialog').modal('hide');

		var postdata = {};
		postdata['itemCode'] = $('#offer-item-code').val();
		postdata['itemName'] = $('#offer-item-replenish').val();
		postdata['quantity'] = $('#offer-quantity').val();
		postdata['unit'] = $('#offer-unit').val();
		postdata['expiredDate'] = $('#offer-expired-date').val();

		sendAjax('/offer/addNewItemReplenish', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
					initReplenishTable();
				else if (code === 2)
					showAlertDialog("Cannot add item replenish to the temp database");
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

	function deleteTempReplenish(itemId) {
		var postdata = {};
		postdata['itemId'] = itemId

		sendAjax('/offer/deleteTempReplenish', postdata, function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
					initReplenishTable();
				else if (code === 2)
					showAlertDialog("Cannot delete item replenish");
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

	function saveAllItemReplenishToRealDB() {
		sendAjax('/offer/saveItemReplenishToWindowsService', [], function (data) {
			if (data != null) {
				var code = data['code'];
				if (code === 1)
					initReplenishTable();
				else if (code === 2)
					showAlertDialog("Please add new item replenish first!");
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
	<? } ?>

	function showAddReplenishDialog() {
		<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
		$('#offer-quantity').val('');
		$('#offer-expired-date').val('');
		commonShowDialog('replenishDialog');
		<? } else { ?>
		showAlertDialog(g_selectShop);
		<? } ?>
	}
</script>
