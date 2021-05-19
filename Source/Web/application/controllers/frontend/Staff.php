<?php


class Staff extends BaseController
{
    public function __construct()
    {
        parent::__construct();

		$this->load->model('frontend/StaffModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
    }

    public function index($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow(STAFF_GET);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
        $this->data['content'] = $this->load->view('frontend/staff/index', $data, true);

        $this->userTemplate();
    }

	public function getList() {
		$result = [];
		$searchValue = $_GET['search']['value'];
		$requestUniqueID = $_GET['requestUniqueID'];
		$allData = $this->StaffModel->getStaffList($requestUniqueID, $searchValue);

		$result["recordsTotal"] = count($allData);
		$result["recordsFiltered"] = count($allData);
		$result["data"] = [];

		for ($i = $_GET['start']; $i < $_GET['start'] + $_GET['length']; $i++)
		{
			if ($i < count($allData))
			{
				$value = $allData[$i];

				$temp = "";
				$inOutTime = EMPTY_STRING." / ".EMPTY_STRING;
				if (!empty($value[4])) {
					$temp = str_replace('/', '-', $value[4]);
					$inOutTime = "$temp / ";
					if (!empty($value[5])) {
						$temp = str_replace('/', '-', $value[5]);
						$inOutTime .= $temp;
					} else {
						$inOutTime .= EMPTY_STRING;
					}
				} else {
					if (!empty($value[5])) {
						$temp = str_replace('/', '-', $value[5]);
						$inOutTime = EMPTY_STRING." / ".$temp;
					}
				}

				$button = "<button class='btn btn-outline btn-circle btn-sm purple' 
									onclick='pageMove(\"/staff/staffProfile?listUniqueID=".$requestUniqueID."&userName=".$value[0]."\");'>
								<i class=\"fa fa-eye\"></i> Detail
							</button>";

				$item = [$i + 1, $value[0], $value[1], $inOutTime, $button];
				array_push($result["data"], $item);
			}
		}

		echo json_encode($result);
	}

    public function staffProfile($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$userName = $this->input->get("userName");
		$listUniqueID = $this->input->get("listUniqueID");

		if (empty($userName) || empty($listUniqueID))
			redirect('/staff/index');
		else {
			// generate request data
			$requestData = $this->generateDataLogRow(STAFF_SELECTED_DETAIL, $userName."_".EMPTY_STRING);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
			$data['userName'] = $userName;
			$data['listUniqueID'] = $listUniqueID;
			$this->data['content'] = $this->load->view('frontend/staff/staffProfile', $data, true);

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
			$userValue = $this->input->post("userValue");
			$currentUserName = $this->input->post("currentUserName");
			$dateForSearch = $this->input->post("dateForSearch");
			$listUniqueID = $this->input->post("listUniqueID");
			$calcUserName = "";
			if ($this->isIncludeSpaceCharacter($userValue))
				$resultCode = 2;
			else {
				$allData = $this->StaffModel->getStaffList($listUniqueID);
				for ($i = 0; $i < count($allData); $i++)
				{
					$value = $allData[$i];
					if ($value[0] == $currentUserName) {
						if (($i == 0 && $userValue == 1) || ($i == (count($allData) - 1) || $userValue == 0))
							$calcUserName = "";
						else {
							if ($userValue == 1)
								$calcUserName = $allData[$i - 1][0];
							else
								$calcUserName = $allData[$i + 1][0];
						}
					}
				}

				if ($userValue == 3)
					$calcUserName = $currentUserName;

				$code = 0;
				if ($userValue == 1)
					$code = STAFF_PREV_DETAIL;
				else if($userValue == 2)
					$code = STAFF_NEXT_DETAIL;
				else
					$code = STAFF_SELECTED_DETAIL;

				// generate request data
				$requestData = $this->generateDataLogRow($code, $calcUserName."_".$dateForSearch);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function sendEmailByCategory()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$sqlNo = $this->input->post("sqlNo");
			$currentUserName = $this->input->post("currentUserName") ? $this->input->post("currentUserName") : EMPTY_STRING;
			$searchDate = !empty($this->input->post("searchDate")) ? $this->input->post("searchDate") : EMPTY_STRING;

			if (empty($sqlNo) || empty($currentUserName) || empty($searchDate))
				$resultCode = 2;
			else {
				// generate request data
				$requestData = $this->generateDataLogRow($sqlNo, $currentUserName."_".$searchDate);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}
}
