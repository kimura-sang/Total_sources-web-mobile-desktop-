<?php

class Report extends BaseController
{
	public function __construct()
	{
		parent::__construct();

		$this->load->model('frontend/ReportModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
	}

	public function getRequestIdByParams($sqlNo, $searchType = STR_REPORT_HOURLY, $date = EMPTY_STRING)
	{
		$requestUniqueID = "";
		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow($sqlNo, $searchType."_".$date);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);
		}

		return $requestUniqueID;
	}

	public function getConsolidateRequestIdByParams($sqlNo, $searchType = STR_REPORT_HOURLY, $date = EMPTY_STRING)
	{
		$requestUniqueIDs = [];
		if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			$branches = $this->ReportModel->getShopBranches($this->session->ownerId);

			if (!empty($branches) && count($branches) > 0) {
				for ($i = 0; $i < count($branches); $i++) {
					$data = [];
					$data['machine_id'] = $branches[$i]['machine_id'];
					$data['request_by'] = $this->session->email;
					$data['request_data'] = $this->generateRequestData($sqlNo, $searchType . "_" . $date);
					$data['status_id'] = DATA_REQUESTED;
					$data['unique_id'] = $this->generateRequestUUID();
					$data['requested_time'] = date("Y-m-d H:i:s");

					// insert to the sql
					$this->BaseModel->updateItemData('data_log', $data, 0);

					array_push($requestUniqueIDs, [$data['unique_id'], $branches[$i]['shop_name'], $branches[$i]['branch']]);
				}
			}
		}

		return json_encode($requestUniqueIDs);
	}

	public function index($data=NULL)
	{
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$tab = !empty($this->input->get("tab")) ? $this->input->get("tab") : STR_REPORT_SALES;
		switch ($tab) {
			case STR_REPORT_SALES:
				$data['requestUniqueID'] = $this->getRequestIdByParams(REPORTS_SALES);
				$data['tabContent'] = $this->load->view('frontend/report/salesReport', $data, true);
				break;
			case STR_REPORT_ITEM_SOLD:
				$data['requestUniqueID'] = $this->getRequestIdByParams(REPORTS_ITEM_SOLD);
				$data['tabContent'] = $this->load->view('frontend/report/itemSold', $data, true);
				break;
			case STR_REPORT_CONSOLIDATE:
				$data['requestUniqueIDs'] = $this->getConsolidateRequestIdByParams(REPORTS_CONSOLIDATE);
				$data['tabContent'] = $this->load->view('frontend/report/consolidate', $data, true);
				break;
			case STR_REPORT_MORE:
				$data['tabContent'] = $this->load->view('frontend/report/more', $data, true);
				break;
			default:
				break;
		}

		$data['tab'] = $tab;
		$this->data['content'] = $this->load->view('frontend/report/index', $data, true);

		$this->userTemplate();
	}

	public function requestNewUniqueID()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$sqlNo = $this->input->post("sqlNo");
			$searchType = $this->input->post("searchType");
			$newDate = !empty($this->input->post("newDate")) ? $this->input->post("newDate") : EMPTY_STRING;

			if (empty($sqlNo) || empty($searchType) || empty($newDate))
				$resultCode = 2;
			else {
				// generate request data
				$requestUniqueID = $this->getRequestIdByParams($sqlNo, $searchType, $newDate);
				$resultData['uniqueId'] = $requestUniqueID;
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function requestNewConsolidateUniqueID()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$searchType = $this->input->post("searchType");
			$newDate = !empty($this->input->post("newDate")) ? $this->input->post("newDate") : EMPTY_STRING;

			if (empty($searchType) || empty($newDate))
				$resultCode = 2;
			else {
				$resultData['requestUniqueIDs'] = $this->getConsolidateRequestIdByParams(REPORTS_CONSOLIDATE, $searchType, $newDate);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function getConsolidateResult() {
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$requestUniqueIDs = $this->input->post("requestUniqueIDs");
			if (empty($requestUniqueIDs))
				$resultCode = 2;
			else {
				$requestIDList = json_decode($requestUniqueIDs, true);
				if (!empty($requestIDList) && count($requestIDList) > 0) {
					for ($i = 0; $i < count($requestIDList); $i++) {
						$machineResult = $this->ReportModel->getBranchConsolidateData($requestIDList[$i][0]);

						if (!empty($machineResult) && count($machineResult) > 0) {
							$temp = $machineResult[0]['response_data'];
							$tempJsonString = json_decode($temp, true);

							if (!empty($tempJsonString) && count($tempJsonString) > 0) {
								$tempRes = json_decode($tempJsonString['result'], true);

								if (!empty($tempRes) && count($tempRes) > 0) {
									$resultTemp = [];
									$resultTemp['shopName'] = $requestIDList[$i][1];
									$resultTemp['branch'] = $requestIDList[$i][2];
									$resultTemp['data'] = $tempRes;

									array_push($resultData, $resultTemp);
								}
							}
						}
					}
				}
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
			$searchType = !empty($this->input->post("searchType")) ? $this->input->post("searchType") : EMPTY_STRING;
			$searchDate = !empty($this->input->post("searchDate")) ? $this->input->post("searchDate") : EMPTY_STRING;

			if (empty($sqlNo) || empty($searchType) || empty($searchDate))
				$resultCode = 2;
			else {
				// generate request data
				$requestUniqueID = $this->getRequestIdByParams($sqlNo, $searchType, $searchDate);
				$resultData['uniqueId'] = $requestUniqueID;
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

	public function sendConsolidateEmailByCategory()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$searchType = !empty($this->input->post("searchType")) ? $this->input->post("searchType") : EMPTY_STRING;
			$searchDate = !empty($this->input->post("searchDate")) ? $this->input->post("searchDate") : EMPTY_STRING;

			if (empty($searchType) || empty($searchDate))
				$resultCode = 2;
			else {
				$resultData['requestUniqueIDs'] = $this->getConsolidateRequestIdByParams(EMAIL_REPORTS_CONSOLIDATE, $searchType, $searchDate);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

}
