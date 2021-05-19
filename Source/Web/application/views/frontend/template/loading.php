<? $shopTitle = "---";
if ($this->session->shopName != EMPTY_STRING) {
	$shopTitle = $this->session->shopName;
}
if ($this->session->branch != EMPTY_STRING) {
	$shopTitle .= " " . $this->session->branch;
}
?>

<div class="loading-div"></div>

<div class="loading-failed">
	<div id="failed-reason">Cannot connect <?= $shopTitle ?></div>
	<input type="button" value="Try Again" style="margin-top: 20px; font-size: 18px" onclick="waitingToGetResponse();" />
</div>
