<?php


class Customer extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('frontend/CustomerModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
    }

    public function index($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow(CUSTOMERS_GET_SEARCH_ALL);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
        $this->data['content'] = $this->load->view('frontend/customer/index', $data, true);

        $this->userTemplate();
    }

	public function getAnotherUniqueIDBySearchKey($data=NULL)
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$searchKey = $this->input->post("searchKey");

			$code = 0;
			if (empty($searchKey) || $searchKey == "")
				$code = CUSTOMERS_GET_SEARCH_ALL;
			else
				$code = CUSTOMERS_GET_SEARCH;

			// generate request data
			$requestData = $this->generateDataLogRow($code, $searchKey);
			$resultData['uniqueId'] = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function getPremium() {
		$result = [];
		$requestUniqueID = $_GET['requestUniqueID'];
		$allData = $this->CustomerModel->getCustomerList($requestUniqueID, CUSTOMER_PREMIUM);	// 1: premium

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$button = "<button class='btn btn-outline btn-circle btn-sm purple' onclick='pageMove(\"/customer/profileAccount?clientId=" . $value[0] . "\");'><i class=\"fa fa-eye\"></i> Detail</button>";

				$item = [$i + 1, $value[1] ." ". $value[2], $value[4], $value[5], $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

	public function getRegular() {
		$result = [];
		$requestUniqueID = $_GET['requestUniqueID'];
		$allData = $this->CustomerModel->getCustomerList($requestUniqueID, CUSTOMER_REGULAR);	// 1: premium

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$button = "<button class='btn btn-outline btn-circle btn-sm purple' onclick='pageMove(\"/customer/profileAccount?clientId=" . $value[0] . "\");'><i class=\"fa fa-eye\"></i> Detail</button>";

				$item = [$i + 1, $value[1] ." ". $value[2], $value[4], $value[5], $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

    public function profileAccount($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$clientID = $this->input->get("clientId");

    	if (empty($clientID))
    		redirect('/customer/index');
    	else {
			// generate request data
			$requestData = $this->generateDataLogRow(CUSTOMERS_SELECTED_DETAIL, $clientID);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
			$data['clientId'] = $clientID;
			$this->data['content'] = $this->load->view('frontend/customer/profileAccount', $data, true);

			$this->userTemplate();
		}
    }

	public function getAnotherUniqueID($data=NULL)
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$isPrev = $this->input->post("isPrev");
			$currentClientID = $this->input->post("currentClientID");
			if ($this->isIncludeSpaceCharacter($isPrev))
				$resultCode = 2;
			else {
				$code = 0;
				if ($isPrev == 1)
					$code = CUSTOMERS_PREV_DETAIL;
				else
					$code = CUSTOMERS_NEXT_DETAIL;

				// generate request data
				$requestData = $this->generateDataLogRow($code, $currentClientID);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

}
