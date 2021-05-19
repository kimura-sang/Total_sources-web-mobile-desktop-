<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> Staff </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <table class="table table-striped table-bordered table-hover table-checkable order-column" id="data-table" >
                            <thead>
                            <tr>
                                <th> No</th>
                                <th> Owner name </th>
                                <th> Role </th>
                                <th> In/Out time</th>
                                <th> Actions </th>
                            </tr>
                            </thead>
                        </table>
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
	var requestURL = '/staff/waitingToGetResponseWithoutData';

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

		initDataTable();
	}

	function initDataTable() {
		var postdata = {};
		postdata['requestUniqueID'] = requestUniqueID;	// premium

		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/staff/getList",
					'data': postdata
				}
			}
		);
	}
</script>
<? } ?>
