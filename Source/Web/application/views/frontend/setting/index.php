
<div class="page-content-wrapper">
    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
		<div class="top-title-left">
			<h3 class="page-title"> Settings </h3>
		</div>
		<? $this->load->view('/frontend/template/shopName'); ?>

        <div class="row">
            <div class="col-md-12">
                <div class="portlet light bordered">
                    <div class="portlet-body">

                        <div class="page-content-box">
                            <div class="setting-content">
                                <div class="col-md-10">
                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Expense type</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off"  placeholder="Food, Drinking, Water, Electricity, Grocery, Office supply, Transportation" name="expiredDate" id="expiredDate">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Pay-ins type</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="For change, Manager money, Cashier money" name="payIn" id="payIn">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Pay-outs type</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="Food, Drinking, Water, Electricity, Grocery, Office supply, Transportation" name="payOut" id="payOut">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Pull out type</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="Expired,Wasted, Others" name="pullOut" id="pullOut">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Email recipient</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="contactus.nsofts@gmail.com" name="email" id="email">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Petty cash amount</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="5000" name="cashAmount" id="cashAmount">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Re-credit timer</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="text" autocomplete="off" placeholder="0" name="creditTimer" id="creditTimer">
                                    </div>

                                </div>
                            </div>
                            <div class="setting-bottom">
                                <div class="" style="margin-top: 20px; margin-bottom: 20px;">
                                    <hr style="border-top: 1px solid #606c6d;">
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn green btn-block offer-save-button" onclick="">Save</button>
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
