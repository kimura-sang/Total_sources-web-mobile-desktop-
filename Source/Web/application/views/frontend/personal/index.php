<div class="page-content-wrapper">
    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
		<div class="top-title-left">
			<h3 class="page-title"> Change Password </h3>
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
                                        <label class=" item-left">Old Password</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="password" name="oldPassword" id="oldPassword">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">New Password</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="password" name="newPassword" id="newPassword">
                                    </div>

                                    <div class="col-md-3 info-item-margin-25">
                                        <label class=" item-left">Confirm Password</label>
                                    </div>
                                    <div class="col-md-9 info-item-margin">
                                        <input class="form-control form-control-solid placeholder-no-fix offer-click" type="password" name="confirmPassword" id="confirmPassword">
                                    </div>
                                </div>
                            </div>
                            <div class="setting-bottom">
                                <div class="col-md-10" style="margin-bottom: 20px;">
                                    <hr style="border-top: 1px solid #606c6d;">
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn green btn-block offer-save-button" onclick="updatePassword(); return false;">Save</button>
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
	function updatePassword() {
		if (!isEmptyErrorNoticeWithAlert("oldPassword", g_emptyOldPasswordMsg) &&
			!isEmptyErrorNoticeWithAlert("newPassword", g_emptyNewPasswordMsg) &&
			!isEmptyErrorNoticeWithAlert("confirmPassword", g_emptyConfirmPasswordMsg)) {

			var postdata = {};
			postdata['oldPassword'] = hex_md5(document.getElementById("oldPassword").value);
			postdata['newPassword'] = hex_md5(document.getElementById("newPassword").value);
			postdata['confirmPassword'] = hex_md5(document.getElementById("confirmPassword").value);
			if (postdata['newPassword'] !== postdata['confirmPassword']){
				inCorrectPasswordWithAlert("confirmPassword", g_notSamePasswordMsg);
			} else {
				sendAjax('/personal/updatePassword', postdata, function (data) {
					if (data != null) {
						if (data == 0)
							showAlertDialog(g_emptyPasswordMsg, null, "nSofts");
						if (data == 1) {
							showAlertDialog(g_updatePasswordSuccessMsg, function() {
								pageMove('/personal/index');
							}, "nSofts");
						}
						if (data == 2)
							showAlertDialog(g_notSameCurrentPasswordMsg, null, "nSofts");
						if (data == 3)
							showAlertDialog(g_notSamePasswordMsg, null, "nSofts");
					}
				}, 'json');
			}
		}
	}
</script>
