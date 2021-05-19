<?php


class Setting extends BaseController
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

		$this->data['content'] = $this->load->view('frontend/setting/index', $data, true);

		$this->userTemplate();
	}

}
