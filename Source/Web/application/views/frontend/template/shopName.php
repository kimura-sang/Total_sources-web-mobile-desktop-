<? $shopTitle = "---";
if ($this->session->shopName != EMPTY_STRING) {
	$shopTitle = $this->session->shopName;
}
if ($this->session->branch != EMPTY_STRING) {
	$shopTitle .= " - " . $this->session->branch;
}
?>

<div class="top-title-right">
	<h4 id="shopTitle"> <?= $shopTitle ?> &nbsp;&nbsp;&nbsp; </h4>
</div>
