<div class="tab-pane active" id="more">
	<div class="report-content">
		<div class="page-content-box col-md-8 col-md-offset-2">
			<div class="transaction-content col-md-12 content-middle">
				<div class="report-item-label info-item-margin" id="date-label">
					<label class=" item-left report-left">Date</label>
				</div>
				<div class="report-item" style="width: 25%">
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

			<table class="table table-striped table-bordered table-hover table-checkable order-column">
				<tbody>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Monthly Sales Report</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_MONTHLY_REPORT ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Item Sold Breakdown</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_ITEM_SOLD_BREAKDOWN ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Pay-Ins & Pay-Out</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_PAYINS_PAYOUT ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Financial Statement</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_FINANCIAL_STATEMENT ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Petty Cash Summary</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_PETTY_CASH ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Customer List</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_CUSTOMER_LIST ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Product & Item List</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_PRODUCT_ITEM_LIST ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Inventory Report</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_INVENTORY ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Top Sold Item</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_TOP_ITEMS ?>'); return false;"> @ Email </a></div></th>
				</tr>
				<tr>
					<th width="50%"><div style="padding-top: 7px;">Least Sold Item</div></th>
					<th width="50%"><div style="text-align: center;"><a class="btn sbold red-haze" onclick="sendEmailBySelectedCategory('<?= EMAIL_REPORTS_LEAST_ITEMS ?>'); return false;"> @ Email </a></div></th>
				</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>

<script type="text/javascript">
	var selectedCategory = "";
	var dateForSearch = g_indicateEmptyString;
	<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
	var requestUniqueID = "";
	var requestURL = '/report/waitingToGetResponse';

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
	}
	<? } ?>

	function sendEmailBySelectedCategory(category)
	{
		selectedCategory = category;
		sendEmailByCategory(selectedCategory, g_indicateEmptyString, dateForSearch);
	}

	function selectDateForSearch(value) {
		if (dateForSearch !== value) {
			dateForSearch = value;
		}
	}
</script>
