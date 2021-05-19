<?php

class ReportModel extends BaseModel
{
	public function __construct()
	{
		parent::__construct();
		date_default_timezone_set('Asia/Shanghai');
	}

	public function getShopBranches($accountID)
	{
		$sql = "select s.* from shop as s
				inner join shop_management as sm on sm.shop_id = s.id
				where sm.account_id = $accountID";

		$result = $this->db->query($sql);
		return $result->result_array();
	}

	public function getBranchConsolidateData($uniqueID) {
		$sql = "select s.shop_name, s.branch, dl.response_data from data_log as dl
				inner join shop as s on s.machine_id = dl.machine_id
				where dl.unique_id = '$uniqueID'";

		$result = $this->db->query($sql);
		return $result->result_array();
	}
}
