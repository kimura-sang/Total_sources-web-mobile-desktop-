<div class="modal fade" id="progressModal" tabindex="-1" role="basic" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true"></button>
                <h4 class="modal-title">Prompt</h4>
            </div>
            <div class="modal-body">
                <label class="progress" id="progressDiv" style="margin-top: 10px; width: 80%;">
                    <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;" id="progress"></div>
                </label>

                <div style="text-align: center;">
                    <label style="width: 272px; font-size: 14px; margin-top: 10px;" >File is uploading...</label>
                </div>
            </div>
<!--            <div class="modal-footer">-->
<!--                <button type="button" class="btn dark btn-outline" data-dismiss="modal">Close</button>-->
<!--                <button type="button" class="btn green">Save changes</button>-->
<!--            </div>-->
        </div>
    </div>
</div>

<div class="modal fade" id="alertModal" tabindex="0" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" style="margin-top: 200px; overflow-y: hidden">
	<div class="modal-dialog" style="width: 400px; ">
		<div class="modal-content" style=" border-radius: 5px;">
			<div class="modal-header">
				<h4 id="alertTitle">Alert</h4>
			</div>
			<div class="modal-body" style="text-align: center;">
				<div style="text-align: center; padding: 20px;">
					<label style="width: 272px; font-size: 14px; margin-top: 10px;" id="alertText" readonly></label>
				</div>
			</div>
			<div class="modal-footer" style="text-align: center">
				<button class="btn green btn-block offer-save-button alertButton" data-dismiss="modal" id="alertOKButton">OK</button>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
    function commonShowDialog(dialogId) {
        $('#' + dialogId).modal();
        // addScrollForWindows();
    }
</script>



