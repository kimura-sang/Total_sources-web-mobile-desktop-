<?php


class Transaction extends BaseController
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
			$requestData = $this->generateDataLogRow(TRANSACTIONS_GET);
			$requestUniqueID = $requestData['unique_id'];

			// insert to the sql
			$this->BaseModel->updateItemData('data_log', $requestData, 0);

			$data['requestUniqueID'] = $requestUniqueID;
		}
		$this->data['content'] = $this->load->view('frontend/transaction/index', $data, true);
		$this->userTemplate();
	}

	public function getAnotherUniqueID($data=NULL)
	{
		$resultCode = 1;
		$resultData = [];

		if (!$this->checkUUIDIsSame()) {
			$resultCode = UUID_CHANGED;
		} else {
			$isPrev = $this->input->post("isPrev");
			$transactionID = $this->input->post("transactionID");
			if ($this->isIncludeSpaceCharacter($isPrev))
				$resultCode = 2;
			else {
				$code = 0;
				if ($isPrev == 1)
					$code = TRANSACTIONS_GET_PREV;
				else
					$code = TRANSACTIONS_GET_NEXT;

				// generate request data
				$requestData = $this->generateDataLogRow($code, $transactionID);
				$resultData['uniqueId'] = $requestData['unique_id'];

				// insert to the sql
				$this->BaseModel->updateItemData('data_log', $requestData, 0);
			}
		}

		echo json_encode($this->getProcessResultData($resultCode, $resultData));
	}

}
