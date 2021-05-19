<?php


//use Restserver\Libraries\REST_Controller;

class Dashboard extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('BaseModel');

		if(!isset($this->session->ownerId))
			$this->signOut();
    }

    public function index($data=NULL)
    {
		if (!$this->checkUUIDIsSame())
			$this->signOut();

    	if ($this->session->machineID != null && $this->session->machineID != EMPTY_STRING) {
			// generate request data
			$requestData = $this->generateDataLogRow(DASHBOARD_GET, EMPTY_STRING);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
        $this->data['content'] = $this->load->view('frontend/dashboard/index', $data, true);
        $this->userTemplate();
    }

	public function getOnlyInventory()
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$searchCategory = $this->input->post("searchCategory");
			if (empty($searchCategory))
				$resultCode = 2;
			else {
				// generate request data
				$requestData = $this->generateDataLogRow(DASHBOARD_GET_ONLY_INVENTORY, $searchCategory);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}
}
