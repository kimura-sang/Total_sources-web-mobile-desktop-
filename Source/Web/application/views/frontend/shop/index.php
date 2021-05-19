<div class="page-content-wrapper">
	<? $this->load->view('/frontend/template/loading'); ?>

    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div class="top-title-left">
            <h3 class="page-title"> My Shops </h3>
        </div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row" id="main-content">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">
                        <div class="page-content-header">
                            <a id="" class="btn sbold red-haze add-button" onclick="showAddShopDialog(); return false;"> Add New
                                <i class="fa fa-plus"></i>
                            </a>
                        </div>
                        <hr>
                        <div class="page-content-box" id="shopList">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- add new shop dialog -->
<div class="modal fade" id="addShopDialog" tabindex="0" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" style="margin-top: 120px; overflow-y: hidden">
	<div class="modal-dialog" style="width: 450px; ">
		<div class="modal-content" style=" border-radius: 5px;">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">×</button>
				<h4 id="loginDialogTitle">Add new shop</h4>
			</div>
			<div class="modal-body" style="text-align: center; padding: 0px;">
				<div class="alert alert-danger display-hide" style="background-color: white;" id="error_div">
					<span id="error" style="color: #e73d4a;"> Please enter email and password. </span>
				</div>
				<div class=" dialog-content">
					<div class="dialog-item">
						<label class="content-title-area">Shop name</label>
						<input class="content-input-area input-round-box" id="shopName" onkeypress="hideErrorNotice();">
					</div>
					<div class="dialog-item">
						<label class="content-title-area">Machine ID</label>
						<input class="content-input-area input-round-box" id="machineId" onkeypress="hideErrorNotice();">
					</div>
					<div class="dialog-item">
						<label class="content-title-area">Branch name</label>
						<input class="content-input-area input-round-box" id="branchName" onkeypress="hideErrorNotice();">
					</div>
				</div>
				<hr style="margin: 0" />
				<div class="dialog-footer">
					<div class="button-container" >
						<button class="btn blue btn-outline dialog-button"  onclick="tryAddShop('shopName', 'machineId', 'branchName', '/shop/addShop' ); return false;">Add</button>
					</div>
					<div class="button-container" style="margin-right: 30px;">
						<button class="btn dark btn-outline dialog-button"  data-dismiss="modal" >Cancel</button>
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
	var selectedShopIndex = '<?= $this->session->selectedShopIndex ?>';

	$(document).ready(function(){
		<? if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) { ?>
		waitingToGetResponse();
		<? } else { ?>
		getShopListData();
		<? } ?>
	});

	function waitingToGetResponse() {
		showMainContent(false);
		showLoadingDiv(true);
		showLoadingFailed(false);
		setTimeout(getShopListData, 6000);
	}

	function getShopListData() {
		sendAjax('/shop/getShopList', [], function (data) {
			showData(data);
		}, 'json');
	}

	function showData(shopList) {
		showLoadingDiv(false);
		showLoadingFailed(false);
		showMainContent(true);

		$('#shopList').empty();
		if (shopList != null) {
			if (shopList.length > 0) {
				for (var i = 0; i < shopList.length; i++) {
					$('#shopList').append("<div class=\"item-container\">\n" +
						"    <div class=\"page-content-item\" id=\"item" + i + "\" onclick=\"shopSelected('" + shopList[i]['id'] + "', '" + shopList[i]['status_id'] + "', 'item" + i + "', 'item-image-color" + i + "' , 'item-image-white" + i + "' ,'" + shopList.length + "');\">\n" +
						"        <div class=\"image-area col-md-2\">\n" +
						"            <img src=\"<?=SERVER_ADDRESS ?>/include/img/home_color_icon.png\" class=\"img-responsive item-image-round\" id=\"item-image-color" + i + "\" style=\"visibility: visible; position: absolute;\">\n" +
						"            <img src=\"<?=SERVER_ADDRESS ?>/include/img/home_white_icon.png\" class=\"img-responsive item-image-round-white\" id=\"item-image-white" + i + "\" style=\"visibility: hidden; position: absolute;\">\n" +
						"        </div>\n" +
						"        <div class=\"col-md-9\">\n" +
						"            <label class=\"col-md-3 bold\">Machine ID</label>\n" +
						"            <label class=\"col-md-9\">" + shopList[i]['machine_id'] + "</label>\n" +
						"            <label class=\"col-md-3 bold\">Shop name</label>\n" +
						"            <label class=\"col-md-9\">" + shopList[i]['shop_name'] + "</label>\n" +
						"            <label class=\"col-md-3 bold\">Branch</label>\n" +
						"            <label class=\"col-md-9\">" + shopList[i]['branch'] + "</label>\n" +
						"            <label class=\"col-md-3 bold\">Amount</label>\n" +
						"            <label class=\"col-md-9\">" + shopList[i]['realAmount'] + "</label>\n" +
						"            <label class=\"col-md-3 bold\">Status</label>\n" +
						"            <label class=\"col-md-9\">" + shopList[i]['status_text'] + "</label>\n" +
						"        </div>\n" +
						"        <div class=\"col-md-1\">\n" +
						"            <img src=\"<?=SERVER_ADDRESS ?>/include/img/delete_icon.png\" class=\"img-cancel\" id=\"cancelIcon" + i + "\" onclick=\"deleteShop('/shop/deleteShop?shopId=" + shopList[i]['id'] + "');\">\n" +
						"        </div>\n" +
						"    </div>\n" +
						"</div>");
				}

				for (i = 0; i < shopList.length; i++) {
					if (selectedShopIndex === shopList[i]['id']) {
						showSelectedShop("item" + i, "item-image-color" + i, "item-image-white" + i, shopList.length);
					}
				}
			}
		}
	}

	function showAddShopDialog() {
		hideErrorNotice();
		document.getElementById("shopName").innerHTML = "";
		document.getElementById("machineId").innerHTML = "";
		document.getElementById("branchName").innerHTML = "";

		commonShowDialog('addShopDialog');
	}
</script>
