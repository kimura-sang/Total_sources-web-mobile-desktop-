<?php

class StaffModel extends BaseModel
{
	public function __construct()
	{
		parent::__construct();
		date_default_timezone_set('Asia/Shanghai');
	}

	/**
	 * @param $requestUniqueID
	 * @param $searchKey
	 * @return mixed
	 */
	public function getStaffList($requestUniqueID, $searchKey = "")
	{
		$result = [];
		$responseData = json_decode($this->getUniqueListRow($requestUniqueID)->response_data);
		$result = $this->getAnalysisData(json_decode($responseData->list), $searchKey);

		return $result;
	}

	public function getAnalysisData($dataList, $searchKey)
	{
		$result = [];
		if ($searchKey == null || $searchKey == "")
			$result = $dataList;
		else {
			if (count($dataList) > 0)
			{
				for ($i = 0; $i < count($dataList); $i++)
				{
					if (strpos($dataList[$i][1], $searchKey) > -1 || strpos($dataList[$i][2], $searchKey) > -1)
						array_push($result, $dataList[$i]);
				}
			}
		}

		return $result;
	}
}
