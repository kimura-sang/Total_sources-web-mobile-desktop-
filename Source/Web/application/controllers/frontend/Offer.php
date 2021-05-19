<?php

class Offer extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('frontend/OfferModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
    }

    public function index($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow(OFFERS_GET);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
        $this->data['content'] = $this->load->view('frontend/offer/index', $data, true);

        $this->userTemplate();
    }

	public function waitingToGetResponseWithCategory()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$requestUniqueID = $this->input->post("requestUniqueID");
			if ($this->isIncludeSpaceCharacter($requestUniqueID))
				$resultCode = 2;
			else {
				$dataLogs = $this->BaseModel->getDataArray('data_log', 'unique_id', $requestUniqueID);
				if ($dataLogs != NULL && count($dataLogs) > 0) {
					$counter = 0;
					$dataLog = $dataLogs[0];
					for (; ;) {
						if ($dataLog['status_id'] == DATA_RESPONSED) {
							$resultData = json_decode($dataLog['response_data'], true)['category'];
							break;
						}

						$counter++;
						if ($counter > $this->WAITING_LIMIT_TIME) {
							$resultCode = 4;
							break;
						}

						$dataLogs = $this->BaseModel->getDataArray('data_log', 'unique_id', $requestUniqueID);
						$dataLog = $dataLogs[0];

						sleep(1);
					}
				} else {
					$resultCode = 3;
				}
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function getAvailableCategories() {
		$result = [];
		$searchValue = $_GET['search']['value'];
		$requestUniqueID = $_GET['requestUniqueID'];
		$category = $_GET['category'];
		$allData = $this->OfferModel->getOfferList($requestUniqueID, OFFER_AVAILABLE, $category, $searchValue);

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$button = "<button class='btn btn-outline btn-circle btn-sm purple' onclick='pageMove(\"/offer/offerDetail?code=" . $value[0] . "\");'><i class=\"fa fa-eye\"></i> Detail</button>";

				$item = [$i + 1, $value[0], $value[1], $value[2], $value[3], $value[4], $value[5], $value[6], $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

	public function getDisableCategories() {
		$result = [];
		$searchValue = $_GET['search']['value'];
		$requestUniqueID = $_GET['requestUniqueID'];
		$category = $_GET['category'];
		$allData = $this->OfferModel->getOfferList($requestUniqueID, OFFER_DISABLE, $category, $searchValue);

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$button = "<button class='btn btn-outline btn-circle btn-sm purple' onclick='pageMove(\"/offer/offerDetail?code=" . $value[0] . "\");'><i class=\"fa fa-eye\"></i> Detail</button>";

				$item = [$i + 1, $value[0], $value[1], $value[2], $value[3], $value[4], $value[5], $value[6], $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

    public function offerDetail($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$code = $this->input->get("code");

		if (empty($code))
			redirect('/offer/index');
		else {
			// generate request data
			$requestData = $this->generateDataLogRow(OFFERS_GET_DETAIL, $code);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
			$data['code'] = $code;
			$this->data['content'] = $this->load->view('frontend/offer/offerDetail', $data, true);

			$this->userTemplate();
		}
    }

	public function getAnotherUniqueID()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$code = $this->input->post("code");
			$price = $this->input->post("price");
			if ($this->isIncludeSpaceCharacter($code))
				$resultCode = 2;
			else {
				$strData = $price . "_" . $code;

				// generate request data
				$requestData = $this->generateDataLogRow(OFFERS_SAVE_DETAIL, $strData);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

    public function itemReplenish($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow(OFFERS_REPLENISH_GET_CATEGORY);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
        $this->data['content'] = $this->load->view('frontend/offer/itemReplenish', $data, true);

        $this->userTemplate();
    }

    public function getTempItemReplenish()
	{
		$result = [];
		$searchValue = $_GET['search']['value'];
		$allData = $this->OfferModel->getTempItemReplenish($this->session->ownerId, $this->session->machineID, $searchValue);

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$button = "<button class='btn btn-outline btn-circle btn-sm red' onclick='deleteTempReplenish(".$value['id']."); return false;'><i class=\"fa fa-trash-o\"></i> Delete</button>";
				$value['expired_date'] = empty($value['expired_date'])? EMPTY_STRING: $value['expired_date'];

				$item = [$i + 1, $value['item_name'], $value['quantity'], $value['unit'], $value['expired_date'], $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

	public function deleteTempReplenish() {
		$resultCode = 1;

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$itemId = $this->input->post("itemId");
			if (empty($itemId))
				$resultCode = 2;
			else {
				$this->BaseModel->deleteItems('replenish_temp', [$itemId]);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, []));
	}

	public function getItemReplenishFromWindowsService()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$itemCategory = $this->input->post("itemCategory");
			if (empty($itemCategory))
				$resultCode = 2;
			else {
				// generate request data
				$requestData = $this->generateDataLogRow(OFFERS_REPLENISH_GET_CATEGORY_DETAIL, $itemCategory);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function addNewItemReplenish()
	{
		$resultCode = 1;

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$itemCode = $this->input->post("itemCode");
			$itemName = $this->input->post("itemName");
			$quantity = $this->input->post("quantity");
			$unit = $this->input->post("unit");
			$expiredDate = $this->input->post("expiredDate")? $this->input->post("expiredDate"): null;
			if (empty($itemCode) || empty($itemName) || empty($quantity) || empty($unit))
				$resultCode = 2;
			else {
				$updateData = [];
				$updateData['account_id'] = $this->session->ownerId;
				$updateData['machine_id'] = $this->session->machineID;
				$updateData['item_code'] = $itemCode;
				$updateData['item_name'] = $itemName;
				$updateData['quantity'] = $quantity;
				$updateData['unit'] = $unit;
				$updateData['expired_date'] = $expiredDate;

				// insert to the sql
				$this->BaseModel->updateItemData('replenish_temp', $updateData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, []));
	}

	public function saveItemReplenishToWindowsService()
	{
		$resultCode = 1;

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$allData = $this->OfferModel->getTempItemReplenishForWindowsService($this->session->ownerId, $this->session->machineID);
			if (empty($allData) || count($allData) < 1) {
				$resultCode = 2;
			} else {
				$saveData = [];
				$ownerData = $this->BaseModel->getDataArray('account', 'id', $this->session->onwerId)[0];
				$saveData['ownerName'] = $ownerData['first_name'] . " " . $ownerData['last_name'];

				$saveData['replenish'] = $allData;

				// generate request data
				$requestData = $this->generateDataLogRow(OFFERS_REPLENISH_SAVE, json_encode($saveData));
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);

				for ($i = 0; $i < count($allData); $i++) {
					$this->BaseModel->deleteItems('replenish_temp', [$allData[$i]['id']]);
				}
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, []));
	}
}
