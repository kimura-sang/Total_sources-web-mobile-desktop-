<?php

class Login extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('frontend/LoginModel');
		$this->load->model('frontend/ShopModel');
    }

    public function index(){
        $this->load->view('frontend/login/index');
    }

    public function forgotPassword(){
        $this->load->view('frontend/login/forgotPassword');
    }

    public function tryLogin(){
        $email = $this->input->post('email');
        $password = $this->input->post('password');

        if ($this->isIncludeSpaceCharacter($email) || $this->isIncludeSpaceCharacter($password))
            echo 2;
        else {
            $owner = $this->LoginModel->getMember($email, $password);

            if ($owner) {
            	if ((int)$owner->status_id == STATUS_DEACTIVATED)
            		echo 4;
            	else if ((int)$owner->status_id == STATUS_EXPIRED)
            		echo 5;
            	else if ((int)$owner->status_id == STATUS_ACTIVATED) {
					$diffDate = $this->getDiffDateFromCurrentDate($owner->expired_date);
					if ($diffDate < 0) {
						$updateData = [];
						$updateData['status_id'] = STATUS_EXPIRED;
						$this->LoginModel->updateItemData('account', $updateData, $owner->id);

						echo 5;
					} else {
						$updateData = [];
						if ((int)$owner->status_id != STATUS_ACTIVATED) {
							$updateData['status_id'] = STATUS_ACTIVATED;
						}

						$uniqueID = $this->generateOwnerUUID();
						$updateData['unique_id'] = $uniqueID;

						$shopList = $this->ShopModel->getShopList($owner->id);
						$machineID = EMPTY_STRING;
						$shopName = EMPTY_STRING;
						$branch = EMPTY_STRING;
						$selectedShopIndex = -1;
						$isFirstSelect = false;
						if (count($shopList) > 0) {
							for ($i = 0; $i < count($shopList); $i++) {
								if ((int)$shopList[$i]['status_id'] == STATUS_ACTIVATED) {
									$diffDate = $this->getDiffDateFromCurrentDate($shopList[$i]['expired_date']);
									if ($diffDate >= 0) {
										if (!$isFirstSelect || $shopList[$i]['id'] == $owner->last_shop_id) {
											$isFirstSelect = true;
											$machineID = $shopList[$i]['machine_id'];
											$shopName = $shopList[$i]['shop_name'];
											$branch = $shopList[$i]['branch'];
											$selectedShopIndex = $shopList[$i]['id'];
										}
									}
								}
							}
						}

						$updateData['last_shop_id'] = $selectedShopIndex;
						$this->LoginModel->updateItemData('account', $updateData, $owner->id);

						$sessionArray = array(
							"ownerId" => $owner->id,
							"email" => $owner->email,
							"shopName" => $shopName,
							"branch" => $branch,
							"machineID" => $machineID,
							'selectedShopIndex' => $selectedShopIndex,
							'uniqueID' => $uniqueID
						);

						$this->session->set_userdata($sessionArray);

						echo 1;
					}
				}
            }
            else
                echo 3;
        }
    }

    public function signUp(){
		$this->load->view('frontend/login/signUp');
	}

	public function registerUser(){
		$updateData = [];
		$ids = ['first_name', 'last_name', 'password', 'email'];

		foreach ($ids as $key)
		{
			$postedValue = $this->input->post($key);
			if (!empty($postedValue))
				$updateData[$key] = $this->input->post($key);
		}

		if (!empty($updateData['email']))
		{
			$sameUserList = $this->LoginModel->getDataArray('account', 'email', $updateData['email']);
			if (empty($sameUserList)){
				$this->LoginModel->updateItemData('account', $updateData, 0);
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

    public function sendEmailForForgotPassword(){
        $email = $this->input->post('email');
		if (empty($email))
			echo 0;
		else {
			$ownerData = $this->BaseModel->getDataArray('account', 'email', $email);
			if (empty($ownerData) || count($ownerData) < 1)
				echo 3;
			else {
				$token = $this->generateRequestUUID();
				$updateData = [];
				$updateData['account_id'] = $ownerData[0]['id'];
				$updateData['token'] = $token;
				$this->BaseModel->updateItemData('token_history', $updateData, 0);

				$tokenLink = "" . SERVER_ADDRESS . "/flogin/resetPassword?token=".$token;
				$content = "<div style='padding: 5%;'>
                        <label style='font-size: 24px;'>" . EMAIL_TITLE . "</label><br/><br/>
                        <label style='font-size: 16px; color: grey;'>Please move to reset password for change password.</label><br/><br/><br/>
                        <a style='padding: 15px 30px; text-decoration: none; cursor: pointer; background: #2182ff; color: white; font-size: 18px; border: none; border-radius: 5px;' href='".$tokenLink."'>Reset Password</a><br/><br/><br/>
                        </div>";

				echo $this->sendEmail($ownerData[0]['email'], EMAIL_TITLE, $content);
			}
		}
    }

    public function resetPassword($data=NULL){
		$token = $this->input->get('token');
		if (empty($token))
			$data['errorText'] = "This token cannot be empty string!";
		else {
			$validToken = $this->LoginModel->judgeTokenIsValid($token);
			if (empty($validToken))
				$data['errorText'] = "This token is not valid!";
			else {
				$ownerData = $this->BaseModel->getDataArray('account', 'id', $validToken->account_id);
				if (empty($ownerData) || count($ownerData) < 1)
					$data['errorText'] = "This user is not exist!";
				else {
					$data['errorText'] = "";
					$data['userData'] = $ownerData[0];
					$data['tokenId'] = $validToken->id;
				}
			}
		}

        $this->load->view('frontend/login/resetPassword', $data);
    }

    public function updatePassword() {
		$updateData = [];
		$ownerId = $this->input->post('userId');
		$password = $this->input->post('password');
		$tokenId = $this->input->post('tokenId');
		if (!empty($ownerId) && !empty($password) && !empty($tokenId)) {
			$updateData['password'] = $password;
			$this->BaseModel->updateItemData('account', $updateData, $ownerId);

			$updateData = [];
			$updateData['used'] = 1;
			$this->BaseModel->updateItemData('token_history', $updateData, $tokenId);
			echo 1;
		}
		else{
			echo 0;
		}
	}

}
