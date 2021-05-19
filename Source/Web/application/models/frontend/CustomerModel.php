<?php

class CustomerModel extends BaseModel
{
	public function __construct()
	{
		parent::__construct();
		date_default_timezone_set('Asia/Shanghai');
	}

	/**
	 * @param $requestUniqueID
	 * @param $userType	// 1: premium, 2: regular
	 * @return mixed
	 */
	public function getCustomerList($requestUniqueID, $userType)
	{
		$result = [];
		$responseData = json_decode($this->getUniqueListRow($requestUniqueID)->response_data);
		if ($userType == CUSTOMER_PREMIUM) {
			$result = json_decode($responseData->premium);
		} else if ($userType == CUSTOMER_REGULAR) {
			$result = json_decode($responseData->regular);
		}

		return $result;
	}
}
