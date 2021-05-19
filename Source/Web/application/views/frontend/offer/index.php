<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Offers </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="top-search-select">
                        <img src="<?SERVER_ADDRESS?>/upload/frontend/offer/setting_image.png" style="width: 30px; margin: 10px 10px 0px 10px; cursor: pointer" onclick="pageMove('/offer/itemReplenish')">
                    </div>
                    <div class="col-md-2 margin-top-10 top-search-select">
                        <select class="bs-select form-control" id="category-list" onchange="selectCategory(this.value);">
                        </select>
                    </div>

                    <div class="tabbable-line tabbable-full-width">
                        <ul class="nav nav-tabs">
                            <li class="active">
                                <a href="#available" data-toggle="tab" onclick="initAvailableTable()"> Available </a>
                            </li>
                            <li>
                                <a href="#disable" data-toggle="tab" onclick="initDisableTable()"> Disable </a>
                            </li>
                        </ul>

                        <div class="tab-content">
                            <!--tab available -->
                            <div class="tab-pane active">
								<div class="portlet light ">
									<div class="portlet-body">
										<table class="table table-striped table-bordered table-hover table-checkable order-column" id="data-table">
											<thead>
											<tr>
												<th> No</th>
												<th> Code </th>
												<th> Category</th>
												<th> Type</th>
												<th> Description</th>
												<th> Price</th>
												<th> Cost</th>
												<th> VATType</th>
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

<style>
    table.dataTable.no-footer {
        border-bottom: none;
    }
</style>

<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
<script type="text/javascript">
	var requestUniqueID = "<?= $requestUniqueID ?>";
	var requestURL = '/offer/waitingToGetResponseWithCategory';
	var isAvailable = true;
	var searchCategory = "";

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

		initCategoryList(data);
		searchCategory = "";
		initAvailableTable();
	}

	function initCategoryList(data) {
		$('#category-list').empty();
		var categoryList = JSON.parse(data);
		if (categoryList !== undefined) {
			$('#category-list').append("<option value='ALL'>ALL</option>");
			for (var i = 0; i < categoryList.length; i++) {
				$('#category-list').append("<option value='" + categoryList[i] + "'>" + categoryList[i] +"</option>");
			}
		}
	}

	function selectCategory(category) {
		searchCategory = category;
		if (category === "ALL") {
			searchCategory = "";
		}

		if (isAvailable) {
			initAvailableTable();
		} else {
			initDisableTable();
		}
	}

	function initAvailableTable() {
		isAvailable = true;

		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;
		postdata['category'] = searchCategory;

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/offer/getAvailableCategories",
					'data': postdata
				}
			}
		);
	}

	function initDisableTable() {
		isAvailable = false;

		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;
		postdata['category'] = searchCategory;

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/offer/getDisableCategories",
					'data': postdata
				}
			}
		);
	}

</script>
<? } ?>
