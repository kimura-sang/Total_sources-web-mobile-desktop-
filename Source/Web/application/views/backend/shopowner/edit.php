<div class="page-content-wrapper">
	<div class="page-content">
		<div>
			<h3 class="page-title"> Shop owner> Edit
				<img class="move-left back-button" src="<?= SERVER_ADDRESS?>/include/img/back_icon.png" onclick="pageMove('/shopowner/index')">
			</h3>
		</div>

		<div class="row">
			<div class="col-md-12">
				<div class="portlet light bordered">
					<div class="portlet-body ">
						<div class="col-md-6 edit-content">
							<div class="panel-body">
								<div class="form-group content-item">
									<label class="col-md-3 margin-top-10 item-title">First name</label>
									<div class="col-md-7 margin-top-10">
										<input type="text" class="form-control" name="first-name" id="firstName" value="<?=$ownerData['first_name']?>">
									</div>
								</div>
								<div class="form-group content-item">
									<label class="col-md-3 margin-top-10 item-title">Email</label>
									<div class="col-md-7 margin-top-10">
										<input type="email" class="form-control" name="email" id="email" value="<?=$ownerData['email']?>">
									</div>
								</div>
								<div class="form-group">
									<label class="col-md-3 margin-top-10 item-title">Owner level</label>
									<div class="col-md-7 margin-top-10">
                                        <?php
                                        $options = array(
                                            'Owner', 'Manager', 'Supervisor', 'Staff'
                                        );
                                        ?>
                                        <select name="Level" id="ownerLevel" class="bs-select form-control input-round-box" >
                                            <?php foreach($options as $key => $option) { ?>
                                                <option value="<?php echo $key; ?>" <?php echo (isset($ownerData['owner_level']) && $ownerData['owner_level'] == $key) ? "selected" : "" ?>><?php echo $option; ?></option>
                                            <?php } ?>
                                        </select>
									</div>
								</div>
							</div>
						</div>

						<div class="col-md-6 edit-content">
							<div class="panel-body">
								<div class="form-group content-item">
									<label class="col-md-3 margin-top-10 item-title" >Last name</label>
									<div class="col-md-7 margin-top-10">
										<input type="text" class="form-control" name="last-name" id="lastName" value="<?=$ownerData['last_name']?>">
									</div>
								</div>
								<div class="form-group content-item">
									<label class="col-md-3 margin-top-10 item-title">Expire date</label>
									<div class="col-md-7 margin-top-10">
										<input class="form-control input-round-box" type="date" id="expiredDate" value="<?=$ownerData['expired_date']?>" placeholder="">
									</div>
								</div>
								<div class="form-group">
									<label class="col-md-3 margin-top-10 item-title">Activation</label>
									<div class="col-md-7 margin-top-10">
										<?if($ownerData['status_id'] == 1) {?>
											<input type="checkbox" class="form-control large_checkbox checkbox-modify" id="activation" name="activation" value="This is check box" checked>
										<?} else {?>
											<input type="checkbox" class="form-control large_checkbox checkbox-modify" id="activation" name="activation" value="This is check box">
										<?}?>
									</div>
								</div>
							</div>
						</div>

						<div class="col-md-8 col-md-offset-2">
                            <div class="col text-center margin-top-30">
                                <a class="btn btn-circle green-meadow" style="width: 400px; border-radius: 5px !important; margin-bottom: 10px;"
                                   onclick="updateOwnerInformation('firstName', 'lastName', 'email', 'expiredDate', 'ownerLevel', 'activation','/shopowner/updateOwnerInformation')">Save</a>
                            </div>
							<hr>
						</div>

						<table class="table table-striped table-bordered table-hover table-checkable order-column margin-top-10" id="data-table">
							<thead>
							<tr>
								<th>No</th>
								<th> Shop name </th>
								<th> Branch </th>
								<th> Machine ID</th>
								<th> Expired Date </th>
								<th> Activation </th>
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
    var currentOwnerId = "<?= $ownerId ?>";
    $(document).ready(function () {
		$('#data-table').dataTable(
			{
				"processing": false,
				"serverSide": true,
				"bDestroy": true,
				"ajax": {
					'url': "/shopowner/getShopListByOwnerId"
				}
			}
		);
    });

    function updateOwnerInformation(firstName, lastName, email, expiredDate, ownerLevel, activation,  url)
    {
        var postdata = {};
        var checkBox;
        postdata['first_name'] = document.getElementById(firstName).value;
        postdata['last_name'] = document.getElementById(lastName).value;
        postdata['email'] = document.getElementById(email).value;
        postdata['expired_date'] = document.getElementById(expiredDate).value;
        postdata['owner_level'] = document.getElementById(ownerLevel).value;
        checkBox = document.getElementById(activation);
        if(checkBox.checked === true) {
            postdata['status_id'] = 1;
        }
        else {
            postdata['status_id'] = 2;
        }
        if (postdata['first_name'] == null || postdata['first_name'] === "" ) {
            alert("Please input first name");
        }
        else if (postdata['last_name'] == null || postdata['last_name'] === "" ) {
            alert("Please input last name");
        }
		else if (postdata['email'] == null || postdata['email'] === "" ) {
			alert("Please input email");
		}
		else if (emailCheck('email') !== 0) {
			alert(g_incorrectEmail);
		}
        else{
            sendAjax(url, postdata, function (data) {
                if (data != null) {
                    if (data == 0)
                    {
                        alert("Update failed!");
                    }
                    if (data == 1)
                    {
                        alert("Information successfully updated!");
                    }
                    if (data == 2) {
                        alert("Email already exist!");
                    }
                }
            }, 'json');
        }
    }

    function updateShopInformation(shopName, branch, machineId, expiredDate, statusId, url)
    {
        var postdata = {};
        var checkBox;
        postdata['shop_name'] = document.getElementById(shopName).value;
        postdata['branch'] = document.getElementById(branch).value;
        postdata['machine_id'] = document.getElementById(machineId).value;
        postdata['expired_date'] = document.getElementById(expiredDate).value;
        checkBox = document.getElementById(statusId);
        if(checkBox.checked == true)
            postdata['status_id'] = 1;
        else
            postdata['status_id'] = 2;

        if (postdata['shop_name'] == "")
            alert("Please input shop name!");
        else if(postdata['machine_id'] == "")
            alert("Please input machine id");
        else{
            sendAjax(url, postdata, function (data) {
                if (data != null) {
                    if (data == 0)
                        alert("Update failed!");
                    if (data == 1)
                        alert("Shop information successfully updated!")
                }
            }, 'json');
        }
    }

    function deleteShop(url) {
        bootbox.dialog({
            message: "Do you want to delete this shop?",
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
                                if (data == 0)
                                    alert("Delete shop failed!");
                                if (data == 1)
                                    pageMove('/shopowner/edit?ownerId=' + currentOwnerId);
                            }
                        }, 'json');
                    }
                }
            }
        });
    }

</script>
