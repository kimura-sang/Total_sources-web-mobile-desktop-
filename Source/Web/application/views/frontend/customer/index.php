<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Customers</h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="profile">
                    <div class="portlet light bordered">
                        <div class="tabbable-line tabbable-full-width">
                            <ul class="nav nav-tabs">
                                <li class="active">
                                    <a href="#premium" data-toggle="tab" onclick="initPremiumTable()"> Premium </a>
                                </li>
                                <li>
                                    <a href="#regular" data-toggle="tab" onclick="initRegularTable()"> Regular </a>
                                </li>
                            </ul>

                            <div class="tab-content" style="padding: 0;">
                                <!--tab customer sale-->
                                <div class="tab-pane active">
									<div class="portlet light ">
										<div class="portlet-body">
											<div style="position: absolute; float: right; padding-right:113px; width: 100%; z-index: 10;">
												<div id="data-table_filter" class="dataTables_filter" style="float: right;">
													<label>Search Key:
														<input type="search" class="form-control input-sm input-small input-inline" id="searchKey" placeholder="" aria-controls="data-table">
													</label>
													<a class="btn blue" onclick="searchCustomers(); return false;"> Search
														<i class="fa fa-search"></i>
													</a>
												</div>
											</div>
											<table class="table table-striped table-bordered table-hover table-checkable order-column" id="data-table" >
												<thead>
												<tr>
													<th> No</th>
													<th> Customer name </th>
													<th> Order date</th>
													<th> Amount</th>
													<th> Actions</th>
												</tr>
												</thead>
											</table>
										</div>
									</div>
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

<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
<script type="text/javascript">
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/customer/waitingToGetResponseWithoutData';
	var searchType = 0;

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

		if (searchType === 0)
			initPremiumTable();
		else
			initRegularTable();
	}

	function initPremiumTable() {
		searchType = 0;

		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;	// premium

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"searching": false,
				"ajax": {
					'url': "/customer/getPremium",
					'data': postdata
				}
			}
		);
	}

	function initRegularTable() {
		searchType = 1;

		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;	// premium

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"searching": false,
				"ajax": {
					'url': "/customer/getRegular",
					'data': postdata
				}
			}
		);
	}

	function searchCustomers() {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['searchKey'] = $('#searchKey').val();

		sendAjax('/customer/getAnotherUniqueIDBySearchKey', postdata, function (data) {
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
<? } ?>

