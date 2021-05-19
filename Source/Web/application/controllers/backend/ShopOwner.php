<?php

class ShopOwner extends BaseController
{
	public function __construct() {
		parent::__construct();

		$this->load->model('backend/ShopOwnerModel');

		if(!isset($this->session->adminId))
			$this->adminSignOut();
	}

	public function index($data=NULL) {
		$this->data['content'] = $this->load->view('/backend/shopowner/index', [], true);
		$this->template();
	}

	public function getOwnerList() {
		$result = [];
		$searchValue = $_GET['search']['value'];
		$allData = $this->ShopOwnerModel->getOwnerList($searchValue);

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++) {
			if ($i < count($allData)) {
				$value = $allData[$i];

				$status = "";
				if($value['status_id'] == STATUS_ACTIVATED)
					$status = "<input type=\"checkbox\" class=\"form-control not-clickable checkbox-modify\" name=\"activation\" value=\"This is check box\" checked readonly>";
				else
					$status = "<input type=\"checkbox\" class=\"form-control not-clickable checkbox-modify\" name=\"activation\" value=\"This is check box\" readonly>";

				$ownerLevel = "";
				if ($value['owner_level'] == OWNER_SHOP){
					$ownerLevel = STR_OWNER_SHOP;
				} else if ($value['owner_level'] == OWNER_MANAGER){
					$ownerLevel = STR_OWNER_MANAGER;
				} else if ($value['owner_level'] == OWNER_SUPERVISOR){
					$ownerLevel = STR_OWNER_SUPERVISOR;
				} else if ($value['owner_level'] == OWNER_STAFF){
					$ownerLevel = STR_OWNER_STAFF;
				}

				$button1 = "<button class=\"btn btn-outline btn-circle btn-sm blue\" onclick=\"pageMove('/shopowner/edit?ownerId=".$value['id']."')\"><i class=\"fa fa-edit\"></i> Edit</button>";
//				$button2 = "<button class=\"btn btn-outline btn-circle btn-sm purple\" onclick=\"pageMove('/shopowner/changePassword?ownerId=".$value['id']."')\"><i class=\"fa fa-key\"></i> Change</button>";
				$button2 = "<button class=\"btn btn-outline btn-circle btn-sm purple\" onclick=\"updatePassword('".$value['id']."'); return false;\"><i class=\"fa fa-key\"></i> Change</button>";
				$button3 = "<button class=\"btn btn-outline btn-circle btn-sm red\" onclick=\"deleteShop(".$value['id']."); return false;\"><i class=\"fa fa-trash-o\"></i> Delete</button>";

				$item = [$i + 1, $value['first_name'] ." ". $value['last_name'], $value['email'], $value['expired_date'], $status, $ownerLevel, $button1.$button2.$button3];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

	public function deleteOwner() {
		$ownerId = $this->input->get('ownerId');
		if (empty($ownerId) || (int)$ownerId < -1)
			echo 2;
		else {
			$shopIds = [];
			$shopList = $this->ShopOwnerModel->getShopList($ownerId);
			if (!empty($shopList) && count($shopList) > 0) {
				for ($i = 0; $i < count($shopList); $i++) {
					$sameShopManagementList = [];
					$sameShopManagementList = $this->ShopOwnerModel->getDataArray('shop_management', 'shop_id', $shopList[$i]['id']);
					if (!empty($sameShopManagementList) && count($sameShopManagementList) == 1){
						array_push($shopIds, $shopList[$i]['id']);
					}
				}
				$this->ShopOwnerModel->deleteItems('shop', $shopIds);
			}

			$shopManagementIds = [];
			$shopManagementList = $this->ShopOwnerModel->getDataArray('shop_management', 'account_id', $ownerId);
			if (!empty($shopManagementList) && count($shopManagementList) > 0) {
				for ($i = 0; $i < count($shopManagementList); $i++) {
					array_push($shopManagementIds, $shopManagementList[$i]['id']);
				}

				$this->ShopOwnerModel->deleteItems('shop_management', $shopManagementIds);
			}

			$this->ShopOwnerModel->deleteItems('account', [$ownerId]);

			echo 1;
		}
	}

	public function add($data=NULL) {
		$this->data['content'] = $this->load->view('/backend/shopowner/addnew', $data, true);
		$this->template();
	}

	public function changePassword($data=NULL) {
		$ownerId = $this->input->get('ownerId');
		$_SESSION["currentOwnerId"]=$ownerId;
		$data['ownerId'] = $ownerId;
		$this->data['content'] = $this->load->view('/backend/shopowner/changePassword', $data, true);

		$this->template();
	}

	public function updatePassword() {
		$updateData = [];
		$ownerId = $_SESSION["currentOwnerId"];
		$oldPassword = $this->input->post('oldPassword');
		$newPassword = $this->input->post('newPassword');
		$currentPassword = $this->ShopOwnerModel->getDataArray('account', 'id', $ownerId)[0]['password'];
		if ($oldPassword != $currentPassword) {
			echo 0;
		}
		else{
			if (!empty($newPassword)) {
				$updateData['password'] = $newPassword;
				$this->ShopOwnerModel->updateItemData('account', $updateData, $ownerId);
				echo 1;
			}
			else{
				echo 2;
			}
		}
	}

	public function sendRandomPassword() {
		$ownerId = $this->input->post('ownerId');
		if (empty($ownerId) || (int)$ownerId < 1)
			echo 0;
		else {
			$ownerData = $this->BaseModel->getDataArray('account', 'id', $ownerId);
			if (empty($ownerData) || count($ownerData) < 1)
				echo 0;
			else {
				$randomPassword = $this->generate8BitRandomPassword();
				$content = "<div style='padding: 5%;'>
                        <label style='font-size: 24px;'>" . EMAIL_TITLE . "</label><br/><br/>
                        <label style='font-size: 16px; color: grey;'>" . EMAIL_RANDOM_PASSWORD . $randomPassword. "</label><br/>
                        </div>";

				$result = $this->sendEmail($ownerData[0]['email'], EMAIL_TITLE, $content);
				if ($result == 1) {
					$updateData = [];
					$updateData['password'] = md5($randomPassword);
					$this->BaseModel->updateItemData('account', $updateData, $ownerId);
				}

				echo $result;
			}
		}
	}

	public function edit($data=NULL) {
		$ownerId = $this->input->get('ownerId');
		$_SESSION["currentOwnerId"]=$ownerId;
		$data['ownerData'] = $this->ShopOwnerModel->getDataArray('account', 'id', $ownerId)[0];
		$data['ownerId'] = $ownerId;

		$expiredDate = $this->ShopOwnerModel->getDataArray('account', 'id', $ownerId)[0]['expired_date'];
		if (!empty($expiredDate) && strlen($expiredDate) > 9) {
			$temp = substr($expiredDate,0,strlen($expiredDate)- 9);
			$data['ownerData']['expired_date'] = $temp;
		}
		$this->data['content'] = $this->load->view('/backend/shopowner/edit', $data, true);
		$this->template();
	}

	public function getShopListByOwnerId() {
		$result = [];
		$searchValue = $_GET['search']['value'];
		$ownerId = $_SESSION["currentOwnerId"];
		$allData = $this->ShopOwnerModel->getShopList($ownerId, $searchValue);
		$tempList = $allData;
		foreach ($tempList as $key => $value) {
			if (!empty($value['expired_date']) && strlen($value['expired_date']) > 9) {
				$value['expired_date'] = substr($value['expired_date'] ,0,strlen($value['expired_date'])- 9);
				$tempList[$key] = $value;
			}
		}
		$allData = $tempList;

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++) {
			if ($i < count($allData)) {
				$value = $allData[$i];

				$shopName = "<input type=\"text\" class=\"form-control input-round-box\" name=\"\" id=\"shop_name".$i."\" value=\"".$value['shop_name']."\">";
				$branch = "<input type=\"text\" class=\"form-control input-round-box\" name=\"\" id=\"branch".$i."\" value=\"".$value['branch']."\">";
				$machineID = "<input type=\"text\" class=\"form-control input-round-box\" name=\"\" id=\"machine_id".$i."\" value=\"".$value['machine_id']."\">";

				$calendar = "";
				if ($value['expired_date'] == "0000-00-00") {
					$calendar = "<input class=\"form-control input-round-box\" id=\"expired_date".$i."\" type=\"date\" value=\"\">";
				} else {
					$calendar = "<input class=\"form-control input-round-box\" id=\"expired_date".$i."\" type=\"date\" value=\"".$value['expired_date']."\">";
				}

				$status = "";
				if($value['status_id'] == STATUS_ACTIVATED)
					$status = "<input type=\"checkbox\" class=\"form-control checkbox-modify\" id=\"status_id".$i."\" name=\"activation\" value=\"This is check box\" checked>";
				else
					$status = "<input type=\"checkbox\" class=\"form-control checkbox-modify\" id=\"status_id".$i."\" name=\"activation\" value=\"This is check box\">";

				$button1 = "<button class=\"btn btn-outline btn-circle btn-sm blue\" onclick=\"updateShopInformation('shop_name".$i."',
                                            'branch".$i."', 'machine_id".$i."', 'expired_date".$i."','status_id".$i."', '/shopowner/updateShopInformation?shopId=".$value['id']."'); return false;\"><i class=\"fa fa-edit\"></i> Save</button>";
				$button2 = "<button class=\"btn btn-outline btn-circle btn-sm red\" onclick=\"deleteShop('/shopowner/deleteShop?shopId=".$value['id']."'); return false;\"><i class=\"fa fa-trash-o\"></i> Delete</button>";

				$item = [$i + 1, $shopName, $branch, $machineID, $calendar, $status, $button1.$button2];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

	public function addNewOwner() {
		$updateData = [];
		$ids = ['first_name', 'last_name', 'password', 'email'];

		foreach ($ids as $key) {
			$postedValue = $this->input->post($key);
			if (!empty($postedValue))
				$updateData[$key] = $this->input->post($key);
		}

		$ownerLevel = $this->input->post('owner_level');
		if ($ownerLevel == STR_OWNER_SHOP){
			$updateData['owner_level'] = OWNER_SHOP;
		} else if ($ownerLevel == STR_OWNER_MANAGER){
			$updateData['owner_level'] = OWNER_MANAGER;
		} else if ($ownerLevel == STR_OWNER_SUPERVISOR){
			$updateData['owner_level'] = OWNER_SUPERVISOR;
		} else if ($ownerLevel == STR_OWNER_STAFF){
			$updateData['owner_level'] = OWNER_STAFF;
		}
		$updateData['status_id'] = STATUS_ACTIVATED;

		if (!empty($updateData['email']))
		{
			$sameUserList = $this->ShopOwnerModel->getDataArray('account', 'email', $updateData['email']);
			if (empty($sameUserList)) {
				$this->ShopOwnerModel->updateItemData('account', $updateData, 0);
				echo 1;
			}
			else{
				echo 0;
			}
		}
		else{
			echo 2;
		}
	}

	public function updateOwnerInformation() {
		$updateData = [];
		$ids = ['first_name', 'last_name', 'email', 'expired_date', 'status_id', 'owner_level'];

		foreach ($ids as $key)
		{
			$postedValue = $this->input->post($key);
			if (!empty($postedValue))
				$updateData[$key] = $postedValue;
			if ($key == 'status_id' || $key == 'owner_level')
				$updateData[$key] = $postedValue;
		}
		$ownerId = $_SESSION["currentOwnerId"];
		if (empty($ownerId)) {
			echo 0;
		}
		else{
			$sameEmailList = $this->ShopOwnerModel->getDataArray('account', 'email', $updateData['email']);
			if (empty($sameEmailList) ) {
				$this->ShopOwnerModel->updateItemData('account', $updateData, $ownerId);
				echo 1;
			}
			else{
				if ($sameEmailList[0]['id'] == $ownerId) {
					$this->ShopOwnerModel->updateItemData('account', $updateData, $ownerId);
					echo 1;
				}
				else{
					echo 2;
				}
			}
		}
	}

	public function updateShopInformation() {
		$updateData = [];
		$ids = ['shop_name', 'branch', 'machine_id', 'expired_date', 'status_id'];

		foreach ($ids as $key)
		{
			$postedValue = $this->input->post($key);
			if (!empty($postedValue))
				$updateData[$key] = $this->input->post($key);
			if (empty($postedValue) && $key == "branch")
				$updateData[$key] = EMPTY_STRING;
		}
		$shopId = $this->input->get('shopId');
		if (empty($shopId)) {
			echo 0;
		} else{
			$this->ShopOwnerModel->updateItemData('shop', $updateData, $shopId);
			echo 1;
		}
	}

	public function deleteShop() {
		$shopId = $this->input->get('shopId');
		$ownerId = $_SESSION["currentOwnerId"];
		if (empty($shopId) || empty($ownerId)) {
			echo 0;
		}
		else{
			$sameShopManagementList = [];
			$sameShopManagementList = $this->ShopOwnerModel->getDataArray('shop_management', 'shop_id', $shopId);
			if (!empty($sameShopManagementList) && count($sameShopManagementList) == 1){
				$this->ShopOwnerModel->deleteItems('shop', [$shopId]);
			}
			$this->ShopOwnerModel->deleteShop($ownerId, $shopId);
			echo 1;
		}
	}

}
