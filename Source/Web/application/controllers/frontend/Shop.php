<?php


class Shop extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('frontend/ShopModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
    }

    public function index($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$this->productShopUniqueIDs();

		$this->data['content'] = $this->load->view('frontend/shop/index', $data, true);

		$this->userTemplate();
    }

	public function generateDataLogRowWithMachineID($sqlNo, $machineID)
	{
		$data = [];
		$data['machine_id'] = $machineID;
		$data['request_by'] = $this->session->email;
		$data['request_data'] = $this->generateRequestData($sqlNo, "");
		$data['status_id'] = DATA_REQUESTED;
		$data['unique_id'] = $this->generateRequestUUID();
		$data['requested_time'] = date("Y-m-d H:i:s");

		return $data;
	}

	public function productShopUniqueIDs()
	{
		$isExistSelectedShopId = -1;
		$ownerId = $_SESSION["ownerId"];
		$shopList = $this->ShopModel->getShopList($ownerId);
		if ($shopList != null && count($shopList) > 0) {
			for ($i = 0; $i < count($shopList); $i++) {
				if ((int)$shopList[$i]['status_id'] == STATUS_ACTIVATED) {
					$diffDate = $this->getDiffDateFromCurrentDate($shopList[$i]['expired_date']);
					if ($diffDate >= 0) {
						if ($shopList[$i]['id'] == $this->session->selectedShopIndex)
							$isExistSelectedShopId = $i;

						$requestData = $this->generateDataLogRowWithMachineID(MY_SHOPS_GET_AMOUNT, $shopList[$i]['machine_id']);
						$this->BaseModel->updateItemData('data_log', $requestData, 0);

						$this->ShopModel->updateItemData('shop', ['online_status' => 0], $shopList[$i]['id']);
					} else {
						$updateData = [];
						$updateData['status_id'] = STATUS_EXPIRED;
						$this->ShopModel->updateItemData('shop', $updateData, $shopList[$i]['id']);
					}
				}
			}

			if ($isExistSelectedShopId > -1)
				$this->setSessionWithSelectedShop($isExistSelectedShopId);
			else
				$this->setSessionWithSelectedShop(0);
		} else {
			$this->initUserSession();
		}
	}

	public function getShopList()
	{
		$shopList = $this->ShopModel->getShopList($_SESSION['ownerId']);
		if ($shopList != null && count($shopList) > 0) {
			for ($i = 0; $i < count($shopList); $i++) {
				if ($shopList[$i]['status_id'] == STATUS_ACTIVATED)
					$shopList[$i]['status_text'] = "Activated";
				else if ($shopList[$i]['status_id'] == STATUS_DEACTIVATED)
					$shopList[$i]['status_text'] = "Deactivated";
				else if ($shopList[$i]['status_id'] == STATUS_EXPIRED)
					$shopList[$i]['status_text'] = "Expired";
			}
		}
		echo json_encode($shopList);
	}

	public function setSelectedShop() {
    	$result = [];
		$shopId = $this->input->post('shopId');
		if (!empty($shopId) && (int)$shopId > 0) {
			$result = $this->setSessionWithSelectedShopId($shopId);
		}

		echo json_encode($result);
	}

	public function setSessionWithSelectedShop($isExistSelectedShopId) {
		$result = [];
		$ownerId = $_SESSION["ownerId"];
		$shopData = $this->ShopModel->getShopList($ownerId);
		if ($shopData != null && count($shopData) > 0) {
			$machineID = $shopData[$isExistSelectedShopId]['machine_id'];
			$shopName = $shopData[$isExistSelectedShopId]['shop_name'];
			$branch = $shopData[$isExistSelectedShopId]['branch'];
			$selectedShopIndex = $shopData[$isExistSelectedShopId]['id'];

			$updateData = [];
			$updateData['last_shop_id'] = $selectedShopIndex;
			$this->ShopModel->updateItemData('account', $updateData, $ownerId);

			$sessionArray = array(
				"shopName" => $shopName,
				"branch" => $branch,
				"machineID" => $machineID,
				'selectedShopIndex' => $selectedShopIndex
			);

			$this->session->set_userdata($sessionArray);

			$result = $sessionArray;
		}

		return $result;
	}

	public function setSessionWithSelectedShopId($shopId) {
		$result = [];
		$ownerId = $_SESSION["ownerId"];
		$shopData = $this->ShopModel->getShopList($ownerId);
		if ($shopData != null && count($shopData) > 0) {
			for ($i = 0; $i < count($shopData); $i++) {
				if ((int)$shopData[$i]['id'] == (int)$shopId) {
					$machineID = $shopData[$i]['machine_id'];
					$shopName = $shopData[$i]['shop_name'];
					$branch = $shopData[$i]['branch'];
					$selectedShopIndex = $shopData[$i]['id'];

					$updateData = [];
					$updateData['last_shop_id'] = $selectedShopIndex;
					$this->ShopModel->updateItemData('account', $updateData, $ownerId);

					$sessionArray = array(
						"shopName" => $shopName,
						"branch" => $branch,
						"machineID" => $machineID,
						'selectedShopIndex' => $selectedShopIndex
					);

					$this->session->set_userdata($sessionArray);

					$result = $sessionArray;
				}
			}
		}

		return $result;
	}

    public function addShop()
    {
        $updateData = [];
        $postData = [];
        $updateData['shop_name'] = $this->input->post('shopName');
        $updateData['machine_id'] = $this->input->post('machineId');
        $updateData['registered_date'] = date('Y-m-d H:i:s');

        $branch = EMPTY_STRING;
        if (!empty($this->input->post('branchName')))
			$branch = $this->input->post('branchName');
		$updateData['branch'] = $branch;

        $ownerId = $_SESSION["ownerId"];

        if (!empty($updateData['machine_id']) && !empty($updateData['shop_name']) && !empty($ownerId))
        {
            $sameShopList = $this->ShopModel->getSameShopData($updateData['machine_id'], $this->session->ownerId);
            if (!empty($sameShopList) && count($sameShopList) == 0){
                echo 0;
            }
            else {
				$this->ShopModel->updateItemData('shop', $updateData, 0);
				$shopId = $this->ShopModel->getDataArray('shop', 'machine_id', $updateData['machine_id'])[0]['id'];
				$postData['account_id'] = $ownerId;
				$postData['shop_id'] = $shopId;
				$this->ShopModel->updateItemData('shop_management', $postData, 0);
				echo 1;
			}
        }
        else{
            echo 2;
        }
    }

    public function deleteShop(){
        $shopId = $this->input->get('shopId');
        $ownerId = $_SESSION["ownerId"];
        if (empty($shopId) || empty($ownerId)){
            echo 0;
        }
        else{
        	$registeredShopList = $this->ShopModel->getRegisteredShopList($shopId);

        	if (!empty($registeredShopList)){
//        		$shopList = json_decode($registeredShopList);
				if (count($registeredShopList) == 1){
					$this->ShopModel->deleteItems('shop', $shopId);
					$this->ShopModel->deleteShop($ownerId, $shopId);
				}
				else{
					$this->ShopModel->deleteShop($ownerId, $shopId);
				}
				echo 1;
			}
        	else{
        		echo 0;
			}
        }
    }
}
