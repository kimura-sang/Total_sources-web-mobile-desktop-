<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

	<!-- BEGIN CONTENT BODY -->
	<div class="page-content">
		<div class="top-title-left">
			<h3 class="page-title"> Reports </h3>
		</div>
		<? $this->load->view('/frontend/template/shopName'); ?>

		<div class="row" id="main-content">
			<div class="col-md-12">
				<div class="profile">
					<div class="portlet light bordered">
						<? if ($tab == STR_REPORT_SALES || $tab == STR_REPORT_ITEM_SOLD || $tab == STR_REPORT_CONSOLIDATE) { ?>
						<div>
							<a class="btn sbold red-haze add-button" onclick="sendEmail(); return false;"> @ Email </a>
						</div>
						<? } ?>
						<div class="tabbable-line tabbable-full-width">
							<ul class="nav nav-tabs">
								<li <? if ($tab == STR_REPORT_SALES) { ?> class="active" <? } ?>><a data-toggle="tab" onclick="selectTab('<?= STR_REPORT_SALES ?>'); return false;"> Sales Report </a></li>
								<li <? if ($tab == STR_REPORT_ITEM_SOLD) { ?> class="active" <? } ?>><a data-toggle="tab" onclick="selectTab('<?= STR_REPORT_ITEM_SOLD ?>'); return false;"> Item Sold </a></li>
								<li <? if ($tab == STR_REPORT_CONSOLIDATE) { ?> class="active" <? } ?>><a data-toggle="tab" onclick="selectTab('<?= STR_REPORT_CONSOLIDATE ?>'); return false;"> Shop Comparison </a></li>
								<li <? if ($tab == STR_REPORT_MORE) { ?> class="active" <? } ?>><a data-toggle="tab" onclick="selectTab('<?= STR_REPORT_MORE ?>'); return false;"> More </a></li>
							</ul>

							<div class="tab-content">
								<?php echo $tabContent; ?>
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
	function selectTab(tabName) {
		pageMove('/report/index?tab=' + tabName);
	}

	function sendEmailByCategory(categoryId, searchTyp, searchDate) {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);

		var postdata = {};
		postdata['sqlNo'] = categoryId;
		postdata['searchType'] = searchTyp;
		postdata['searchDate'] = searchDate;

		sendAjax('/report/sendEmailByCategory', postdata, function (data) {
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
