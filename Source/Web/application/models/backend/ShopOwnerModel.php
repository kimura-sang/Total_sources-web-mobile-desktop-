<?php

class ShopOwnerModel extends BaseModel
{
    public function __construct() {
        parent::__construct();
        date_default_timezone_set('Asia/Shanghai');
    }

	function getOwnerList($searchValue) {
		$sql = "select * from account
                where first_name like '%$searchValue%' or last_name like '%$searchValue%'";

		$result = $this->db->query($sql);
		return $result->result_array();
	}

    function getShopList($ownerId, $searchKey = "") {
        $sql = "select s.*
                from shop_management as sm
                inner join shop as s on sm.shop_id = s.id
                where sm.account_id = $ownerId ";

        if ($searchKey != "")
        	$sql .= " and (s.shop_name like '%$searchKey%' or s.branch like '%$searchKey%')";

        $result = $this->db->query($sql);
        return $result->result_array();
    }

    function deleteShop($ownerId, $shopId) {
        $sql = "delete sm.* 
                from shop_management as sm
                where sm.`account_id` = $ownerId
                and sm.`shop_id` = $shopId";

        $result = $this->db->query($sql);
        return $result;
    }

}
