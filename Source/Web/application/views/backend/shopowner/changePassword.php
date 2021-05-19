<div class="page-content-wrapper">
    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div>
            <h3 class="page-title"> Shop owner> Change password
				<img class="move-left back-button" src="<?= SERVER_ADDRESS?>/include/img/back_icon.png" onclick="pageMove('/shopowner/index')">
			</h3>
        </div>
        <hr>

        <div class="row" style="display: block">

            <div class="edit-margin" style="width: 20%">

            </div>
            <div class="edit-content">
                <div class="col-md-6 col-md-offset-3">
                    <div class="tab-content">
                        <div id="tab_1-1" class="tab-pane active">
                            <form role="form" action="#">
                                <div class="alert alert-danger display-hide" style="background-color: white; border-color: #c5bec5; border-radius: 5px !important;" id="error_div">
                                    <button class="close" data-close="alert"></button>
                                    <span id="error" style="color: #544c4c;"> Enter correct password. </span>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Old password</label>
                                    <input type="password" placeholder="" class="form-control" id="oldPassword" onkeypress="hideErrorNotice();"/>
                                    <span toggle="#oldPassword" class="fa fa-fw fa-eye field-icon toggle-password"></span>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">New password</label>
                                    <input type="password" placeholder="" class="form-control" id="newPassword" onkeypress="hideErrorNotice();"/>
                                    <span toggle="#newPassword" class="fa fa-fw fa-eye field-icon toggle-password"></span>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Confirm password</label>
                                    <input type="password" placeholder="" class="form-control" id="confirmPassword" onkeypress="hideErrorNotice();"/>
                                    <span toggle="#confirmPassword" class="fa fa-fw fa-eye field-icon toggle-password"></span>
                                </div>
                                <hr>
                                <div class="col text-center margin-top-30">
                                    <a href="javascript:;" class="btn btn-circle green-meadow" style="width: 400px; border-radius: 5px !important;" onclick="updatePassword('oldPassword', 'newPassword', 'confirmPassword','/shopowner/updatePassword')">Save</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="edit-margin" style="width: 20%;">
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
        $('#dataTables-example').dataTable();
    });

    $(".toggle-password").click(function() {
        $(this).toggleClass("fa-eye fa-eye-slash");
        var input = $($(this).attr("toggle"));
        if (input.attr("type") == "password") {
            input.attr("type", "text");
        } else {
            input.attr("type", "password");
        }
    });

    function updatePassword(oldPassword, newPassword, confirmPassword, url)
    {
        if (!isEmptyErrorNotice(oldPassword, g_emptyOldPasswordMsg) && !isEmptyErrorNotice(newPassword, g_emptyNewPasswordMsg) &&
            !isEmptyErrorNotice(confirmPassword, g_emptyConfirmPasswordMsg)) {
            if (!isIncludeSpaceCharacter(oldPassword, g_notInputSpace) && !isIncludeSpaceCharacter(newPassword, g_notInputSpace) &&
                !isIncludeSpaceCharacter(confirmPassword, g_notInputSpace)) {
                var postdata = {};
                postdata['oldPassword'] = hex_md5(document.getElementById(oldPassword).value);
                postdata['newPassword'] = hex_md5(document.getElementById(newPassword).value);
                postdata['confirmPassword'] = hex_md5(document.getElementById(confirmPassword).value);
                if (postdata['newPassword'] != postdata['confirmPassword']){
                    inCorrectPassword(newPassword, g_correctPasswordMsg);
                }
                else{
                    sendAjax(url, postdata, function (data) {
                        if (data != null) {
                            if (data == 0)
                            {
                                alert("This current password incorrect");
                            }
                            if (data == 1)
                            {
                                alert("Password successfully updated!")
								pageMove('/shopowner/index');
                            }
                            if (data == 2)
                            {
                                alert("Password update failed!");
                            }
                        }
                    }, 'json');
                }
            }
        }
    }

    function hideErrorNotice()
    {
        document.getElementById('error_div').className = "alert alert-danger display-hide";
    }
</script>
