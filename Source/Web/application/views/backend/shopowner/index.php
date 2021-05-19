<div class="page-content-wrapper">
	<? $this->load->view('/backend/template/loading'); ?>

	<div class="page-content" id="main-content">
		<h3 class="page-title"> Show owner </h3>

		<div class="row">
			<div class="col-md-12">
				<div class="portlet light bordered">

					<div class="portlet-body">
						<div class="table-toolbar" style="margin-bottom: 0;">
							<div class="row">
								<div class="col-md-6">
									<div class="btn-group">
										<button id="sample_editable_1_new" class="btn sbold red-haze" style="display: block;position: fixed;top: 90px;right: 30px;" onclick="pageMove('/shopowner/add')"> Add New
											<i class="fa fa-plus"></i>
										</button>
									</div>
								</div>
							</div>
						</div>
						<table class="table table-striped table-bordered table-hover table-checkable order-column" id="data-table">
							<thead>
							<tr>
								<th>No</th>
								<th> Client name </th>
								<th> Email </th>
								<th> Expired Date </th>
								<th> Activation </th>
								<th> Owner level </th>
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

<script type="text/javascript">
	$(document).ready(function () {
		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/shopowner/getOwnerList"
				}
			}
		);
	});

	function updatePassword(ownerId) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['ownerId'] = ownerId;
		if (ownerId === undefined || parseInt(ownerId) < 1) {
			showLoadingDiv(false);
			showLoadingFailed(false);
			showMainContent(true);

			showAlertDialog(g_notSelectOwnerIdMsg, null, "nSofts");
		}
		else{
			sendAjax('/shopowner/sendRandomPassword', postdata, function (data) {
				if (data != null) {
					showLoadingDiv(false);
					showLoadingFailed(false);
					showMainContent(true);

					if (data === 0)
						showAlertDialog(g_notSelectOwnerIdMsg, null, "nSofts");
					if (data === 1)
						showAlertDialog(g_sendRandomPasswordMsg, null, "nSofts");;
					if (data === 2)
						showAlertDialog(g_sendEmailFailedMsg, null, "nSofts");
				}
			}, 'json', false, true);
		}
	}

	function deleteShop(ownerId){
		var url = '/shopowner/deleteOwner?ownerId=' + ownerId;
		bootbox.dialog({
			message: "Do you want to delete this owner?",
			title: "nSofts",
			buttons: {
				success: {
					label: "Cancel",
					className: "btn dark btn-outline sbold",
					callback: function() {
					}
				},
				main: {
					label: "Delete",
					className: "btn red-mint btn-outline sbold",
					callback: function() {
						var postData = {};
						sendAjax(url, postData, function (data) {
							if (data != null) {
								if (data == 1)
									pageMove('/shopowner');
								if (data == 2)
									alert("Delete owner failed!");
							}
						}, 'json');
					}
				}
			}
		});
	}
</script>
