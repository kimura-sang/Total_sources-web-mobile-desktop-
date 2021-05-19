<?php

class CommunicationModel extends BaseModel
{
	public function __construct()
	{
		parent::__construct();
	}

	public function getOnlyRequestedData($machineID) {
		$sql = "select * from data_log 
				where status_id = ".DATA_REQUESTED." and machine_id = '$machineID'";
		$result = $this->db->query($sql);

		return $result->result_array();
	}

	public function cleanMachineLogs($machineID) {
		$sql = "delete from data_log 
				where machine_id = '$machineID'";
		$result = $this->db->query($sql);

//		return $result->result_array();
	}

    function getUser($email, $password){
        $sql = "select u.*
                    from account as u
                    where u.email = '".$email."'
                    and u.password = '".$password."'
                    and u.owner_level = 0";
        $result = $this->db->query($sql);
        return $result->result_array();
    }

    function getSocialUser($email, $sdkType){
	    $sql = "";
        $facebookSql = "select u.*
                    from account as u
                    where u.facebook_id = '".$email."'
                    and u.owner_level = 0";
        $googleSql = "select u.*
                    from account as u
                    where u.google_id = '".$email."'
                    and u.owner_level = 0";
        if ($sdkType == 1){
            $sql = $facebookSql;
        }
        else{
            $sql = $googleSql;
        }
        $result = $this->db->query($sql);
        return $result->result_array();
    }

    function getDashboardData($uniqueId){
        $sql = "select d.`response_data`
                from data_log as d
                where d.`unique_id` = '".$uniqueId."'
                and d.`status_id` = 5
                order by `received_time` DESC";
        $result = $this->db->query($sql);
        return $result->result_array();
    }

    function getOfferData($uniqueId){
        $sql = "select d.`response_data`
                from data_log as d
                where d.`unique_id` = '".$uniqueId."'
                and d.`status_id` = 5
                order by `received_time` DESC";
        $result = $this->db->query($sql);
        return $result->result_array();
    }

    /**
     * @param $requestUniqueID
     * @param $userType	// 1: premium, 2: regular
     * @param $searchKey
     * @return
     */
    public function getCustomerList($requestUniqueID, $userType, $searchKey)
    {
        $result = [];
		$tempList = $this->getCustomerListRow($requestUniqueID)->response_data;
		if (!empty($tempList)){
			$responseData = json_decode($tempList);
			if ($userType == CUSTOMER_PREMIUM) {
				$result = $this->getAnalysisData(json_decode($responseData->premium), $searchKey);
			} else if ($userType == CUSTOMER_REGULAR) {
				$result = $this->getAnalysisData(json_decode($responseData->regular), $searchKey);
			}
		}

        return $result;
    }
//
//	public function getCustomerList($requestUniqueID, $userType)
//	{
//		$result = [];
//		$responseData = json_decode($this->getUniqueListRow($requestUniqueID)->response_data);
//		if ($userType == CUSTOMER_PREMIUM) {
//			$result = json_decode($responseData->premium);
//		} else if ($userType == CUSTOMER_REGULAR) {
//			$result = json_decode($responseData->regular);
//		}
//
//		return $result;
//	}

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

    public function getCustomerListRow($requestUniqueID)
    {
        $sql = "select response_data from data_log where unique_id = '$requestUniqueID'";
        $result = $this->db->query($sql);

        return $result->row();
    }

    public function updateShopAmount($amount, $machineID)
	{
		$this->db->where('machine_id', $machineID);
		$this->db->update('shop', ['amount' => $amount, 'online_status' => 1]);
	}

	function getShopList($ownerId)
	{
		$sql = "select s.*, IF(amount=-1, '".EMPTY_STRING."', amount) as realAmount 
                    from shop_management as sm
                    inner join shop as s on sm.shop_id = s.id
                    where sm.account_id = $ownerId ";

		$result = $this->db->query($sql);
		return $result->result_array();
	}

	function getShopRegisterList($accountId, $shopId)
	{
		$sql = "select *
				from shop_management
				where account_id = '$accountId'
				and shop_id = '$shopId'";
		$result = $this->db->query($sql);
		return $result->result_array();
	}

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

	public function getTempItemReplenish($ownerId, $machineID) {
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

    public function getShopBranches($accountID)
    {
        $sql = "select s.* from shop as s
				inner join shop_management as sm on sm.shop_id = s.id
				where sm.account_id = '$accountID'";

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

