<?php

class Personal extends BaseController
{
	public function __construct()
	{
		parent::__construct();

		if(!isset($this->session->ownerId))
			$this->signOut();
	}

	public function index($data=NULL)
	{
		if (!$this->checkUUIDIsSame())
			$this->signOut();

		$this->data['content'] = $this->load->view('frontend/personal/index', $data, true);

		$this->userTemplate();
	}

	public function updatePassword()
	{
		$oldPassword = $this->input->post('oldPassword');
		$newPassword = $this->input->post('newPassword');
		$confirmPassword = $this->input->post('confirmPassword');
		$ownerId = $_SESSION["ownerId"];

		if (!empty($oldPassword) && !empty($newPassword) && !empty($confirmPassword))
		{
			$ownerData = $this->BaseModel->getDataArray('account', 'id', $ownerId)[0];
			if (!empty($ownerData)) {
				if ($ownerData['password'] == $oldPassword) {
					if ($newPassword == $confirmPassword) {
						$this->BaseModel->updateItemData('account', ['password' => $newPassword], $ownerId);
						echo 1;
					} else
						echo 3;
				} else
					echo 2;
			} else {
				echo 0;
			}
		}
		else{
			echo 0;
		}
	}

}

