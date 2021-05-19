<?php

class ShopModel extends BaseModel
{
    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set('Asia/Shanghai');
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

    function deleteShop($ownerId, $shopId){
        $sql = "delete sm.* 
                from shop_management as sm
                where sm.account_id = $ownerId
                and sm.shop_id = $shopId";

        $result = $this->db->query($sql);
        return $result;
    }

    function getSameShopData($machineId, $ownerId) {
		$sql = "select s.* from shop as s
				inner join shop_management as sm on sm.shop_id = s.id
				where s.machine_id='$machineId' and sm.account_id=$ownerId";

		$result = $this->db->query($sql);
		return $result;
	}

	function getRegisteredShopList($shopId) {
		$sql = "select *
				from shop_management
				where shop_id = '$shopId'";

		$result = $this->db->query($sql);
		return $result;
	}
}
