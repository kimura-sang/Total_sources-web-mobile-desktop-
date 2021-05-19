<?php

class OfferModel extends BaseModel
{
	public function __construct()
	{
		parent::__construct();
		date_default_timezone_set('Asia/Shanghai');
	}

	/**
	 * @param $requestUniqueID
	 * @param $isAvailable // 1: available, 2: disable
	 * @param $category
	 * @param $searchKey
	 * @return mixed
	 */
	public function getOfferList($requestUniqueID, $isAvailable, $category, $searchKey)
	{
		$result = [];
		$responseData = json_decode($this->getUniqueListRow($requestUniqueID)->response_data);
		if ($isAvailable == OFFER_AVAILABLE) {
			$result = $this->getAnalysisData(json_decode($responseData->available), $category, $searchKey);
		} else if ($isAvailable == OFFER_DISABLE) {
			$result = $this->getAnalysisData(json_decode($responseData->disable), $category, $searchKey);
		}

		return $result;
	}

	public function getAnalysisData($dataList, $category, $searchKey)
	{
		$result = [];
		if ($searchKey == null || $searchKey == "") {
			if (count($dataList) > 0) {
				for ($i = 0; $i < count($dataList); $i++) {
					if ($category == "") {
						$result = $dataList;
					} else {
						if (strpos($dataList[$i][1], $category) > -1) {
							array_push($result, $dataList[$i]);
						}
					}
				}
			}
		} else {
			if (count($dataList) > 0) {
				for ($i = 0; $i < count($dataList); $i++) {
					if ($category == "") {
						if (strpos($dataList[$i][2], $searchKey) > -1) {
							array_push($result, $dataList[$i]);
						}
					} else {
						if (strpos($dataList[$i][1], $category) > -1 && strpos($dataList[$i][2], $searchKey) > -1) {
							array_push($result, $dataList[$i]);
						}
					}
				}
			}
		}

		return $result;
	}

	public function getTempItemReplenish($ownerId, $machineID, $searchValue) {
		if ($searchValue != null && $searchValue != "")
			$this->db->where('item_code', $searchValue);
		$this->db->where('account_id', $ownerId);
		$this->db->where('machine_id', $machineID);

		$result = $this->db->get('replenish_temp');
		return $result->result_array();
	}

	public function getTempItemReplenishForWindowsService($ownerId, $machineID) {
		$sql = "select id, item_code, quantity, unit, expired_date 
				from replenish_temp 
				where account_id=$ownerId and machine_id='$machineID'";
		$result = $this->db->query($sql);
		return $result->result_array();
	}
}
