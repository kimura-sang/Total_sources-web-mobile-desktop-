<div class="page-content-wrapper">
    <!-- BEGIN CONTENT BODY -->
    <div class="page-content">
        <div>
            <h3 class="page-title"> Shop owner> Add new
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
                                    <span id="error" style="color: #544c4c;"> Enter First name</span>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">First name</label>
                                    <input type="text" placeholder="" class="form-control" id="firstName"/>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Last name</label>
                                    <input type="text" placeholder="" class="form-control" id="lastName"/>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Email</label>
                                    <input type="text" placeholder="" class="form-control" id="email"/>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Owner level</label>
                                    <select class="bs-select form-control input-round-box" id="ownerLevel">
                                        <option><?= STR_OWNER_SHOP ?></option>
                                        <option><?= STR_OWNER_MANAGER ?></option>
                                        <option><?= STR_OWNER_SUPERVISOR ?></option>
										<option><?= STR_OWNER_STAFF ?></option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Password</label>
                                    <input type="password" placeholder="" class="form-control" id="pwd"/>
                                    <span toggle="#pwd" class="fa fa-fw fa-eye field-icon toggle-password"></span>
                                </div>
                                <div class="form-group">
                                    <label class="control-label">Confirm password</label>
                                    <input type="password" placeholder="" class="form-control" id="confirm_pwd"/>
                                    <span toggle="#confirm_pwd" class="fa fa-fw fa-eye field-icon toggle-password"></span>
                                </div>
                                <hr>
                                <div class="col text-center margin-top-30">
                                    <a href="javascript:;" class="btn btn-circle green-meadow" style="width: 400px; border-radius: 5px !important;" onclick="addNewOwner('firstName', 'lastName', 'email', 'ownerLevel', 'pwd', 'confirm_pwd', '/shopowner/addNewOwner'); return false;">Save</a>
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

    function addNewOwner(firstName, lastName, email, ownerLevel, pwd, confirm_pwd, url)
    {
        if (!isEmptyErrorNotice(firstName, g_emptyUserFirstNameMsg) && !isEmptyErrorNotice(lastName, g_emptyUserSecondNameMsg) &&
            !isEmptyErrorNotice(email, g_emptyEmailMsg) && !isEmptyErrorNotice(pwd, g_emptyPasswordMsg) && !isEmptyErrorNotice(confirm_pwd, g_emptyConfirmPasswordMsg)) {
            if (!isIncludeSpaceCharacter(firstName, g_notInputSpace) && !isIncludeSpaceCharacter(lastName, g_notInputSpace) && !isIncludeSpaceCharacter(email, g_notInputSpace)
                && !isIncludeSpaceCharacter(pwd, g_notInputSpace) && !isIncludeSpaceCharacter(confirm_pwd, g_notInputSpace) ) {
                var postdata = {};
                postdata['first_name'] = document.getElementById(firstName).value;
                postdata['last_name'] = document.getElementById(lastName).value;
                postdata['email'] = document.getElementById(email).value;
                postdata['owner_level'] = document.getElementById(ownerLevel).value;
                postdata['password'] = hex_md5(document.getElementById(pwd).value);
                postdata['confirm_pwd'] = hex_md5(document.getElementById(confirm_pwd).value);
                if (postdata['password'] != postdata['confirm_pwd']){
                    inCorrectPassword(pwd, g_correctPasswordMsg);
                }
                else{
                    sendAjax(url, postdata, function (data) {
                        if (data != null) {
                            if (data == 0)
                            {
                                // document.getElementById('error_div').className = "alert alert-danger";
                                // document.getElementById('error').innerHTML = g_notInputSpace;
                                alert("This email already exist");
                            }
                            if (data == 1)
                            {
                                alert("Successfully added!");
                            }
                            if (data == 2)
                            {
                                //showAlertDialog(g_loginErrorMsg);
                                document.getElementById('error_div').className = "alert alert-danger";
                                document.getElementById('error').innerHTML = g_emptyInformation;
                            }
                        }
                    }, 'json');
                }
            }
        }
    }
</script>
