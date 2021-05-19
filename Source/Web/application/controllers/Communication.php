<?php

use Restserver\Libraries\REST_Controller;
defined('BASEPATH') OR exit('No direct script access allowed');

require APPPATH . 'libraries/REST_Controller.php';
require APPPATH . 'libraries/Format.php';

class Communication extends REST_Controller
{
	public $RESULT_SUCCESS = 201;
	public $RESULT_FAILED = 202;
	public $RESULT_EMAIL_PASSWORD_INCORRECT = 203;
	public $RESULT_PASSWORD_INCORRECT = 204;
    public $RESULT_EMAIL_DUPLICATE = 205;
    public $RESULT_SEARCH_EMPTY = 206;
    public $RESULT_EMPTY_SHOP = 207;
	public $RESULT_OVER_EXPIRED = 208;
	public $RESULT_MACHINE_ID_EXIST = 209;

	public $RESULT_EMPTY_MACHINE_ID = 210;
	public $RESULT_INCORRECT_UUID = 211;
	public $RESULT_EMPTY_DATA = 212;

	public $RESULT_EMAIL_INCORRECT = 213;
	public $RESULT_SEND_EMAIL_FAILED = 214;
	public $RESULT_VERIFICATION_CODE_USED = 215;
	public $RESULT_VERIFICATION_CODE_INCORRECT = 216;

	public function __construct()
	{
		parent::__construct();

		$this->load->model('CommunicationModel');
        date_default_timezone_set('Asia/Shanghai');
	}

    /**
     * Function : generate request data by sql no
     * Parameter: sql no, search key
     * Return   : request data json
     * Creator  : xxx
     * Date     : 20191114
     * @param $sqlNo
     * @param $searchKey
     * @return string
     */
    public function generateRequestData($sqlNo, $searchKey)
    {
        return json_encode(array(
            "sqlNo" => $sqlNo,
            "searchKey" => $searchKey
        ));
    }

    /**
     * Function : generate UUID for request data
     * Parameter:
     * Return   : 32bit UUID
     * Creator  : xxx
     * Date     : 20191114
     */
    public function generateRequestUUID()
    {
        return md5(uniqid(mt_rand(), true));
    }

    /**
     * Function : generate UUID for owners
     * Parameter:
     * Return   : 32bit UUID
     * Creator  : mars
     * Date     : 20191213
     */
    public function generateOwnerUUID()
    {
        $chars = md5(uniqid(mt_rand(), true));
        $uuid = substr ( $chars, 0, 8 ) . '-'
            . substr ( $chars, 8, 4 ) . '-'
            . substr ( $chars, 12, 4 ) . '-'
            . substr ( $chars, 16, 4 ) . '-'
            . substr ( $chars, 20, 12 );
        return $uuid ;
    }

	/**
	 * Function : common function for send result to client
	 * Parameter:
	 * @param $returnCode
	 * @param $resultData
	 * Return   : json data
	 *      ex: {
	 *          "code" : $returnCode,
	 *          "data" : $resultData
	 *      }
	 * Creator  : xxx
	 * Date     : 20190530
	 * @return array
	 */
	public function getResultData($returnCode, $resultData) {
		$returnData = [];

		$returnData['code'] = REST_Controller::HTTP_OK;
		$returnData['data'] = [];

		if ($returnCode < 0)
			$returnData['code'] = $returnCode;
		$returnData['code'] = $returnCode;

		if (!empty($resultData))
			$returnData['data'] = $resultData;

		return $returnData;
	}


	public function getRequestedData_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];

		$machineID = $this->input->get("machineID");
		if ($machineID != NULL && $machineID != "") {
			try {
				$resultData = $this->CommunicationModel->getOnlyRequestedData($machineID);
			} catch (Exception $e) {
				$returnCode = $this->RESULT_FAILED;
			}
		} else {
			$returnCode = $this->RESULT_EMPTY_MACHINE_ID;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

	public function cleanMachineDataLog_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];

		$machineID = $this->input->get("machineID");
		if ($machineID != NULL && $machineID != "") {
			try {
				$resultData = $this->CommunicationModel->cleanMachineLogs($machineID);
			} catch (Exception $e) {
				$returnCode = $this->RESULT_FAILED;
			}
		} else {
			$returnCode = $this->RESULT_EMPTY_MACHINE_ID;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

	public function updateResponseData_post() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];

		$responseData = $this->input->post("responseData");
		$dataId = $this->input->post("dataId");
		$sqlNo = $this->input->post("sqlNo");
		$machineID = $this->input->post("machineID");
		try {
			$data = [];
			$data['response_data'] = $responseData;
			$data['status_id'] = DATA_RESPONSED;
			$data['received_time'] = date('Y-m-d H:i:s');

			$resultData = $this->CommunicationModel->updateItemData('data_log', $data, $dataId);

			if ((int)$sqlNo == MY_SHOPS_GET_AMOUNT) {
				$amount = -1;
				$amountData = json_decode($responseData, true);
				if ($amountData != null && $amountData['amount'] != null) {
					$temp = json_decode($amountData['amount'], true)[0];
					if ($temp != null && $temp[0] != null)
						$amount = $temp[0];
				}

				$this->CommunicationModel->updateShopAmount($amount, $machineID);
			}
		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

    /**
     * Function : generate request data log row and return uuid to frontend
     * Parameter: sql no, machine id, request user email
     * Return   : uuid
     * Creator  : mars
     * Date     : 20191119
     * @param $sqlNo
     * @return array
     */
	public function requestUUID_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $userId = $this->post('user_id');
            $userUniqueId = $this->post('unique_id');
            if (!empty($userId) && !empty($userUniqueId)){
                $userInfo = $this->CommunicationModel->getDataArray('account', 'id', $userId)[0];
                if ($userUniqueId != $userInfo['unique_id']){
                    $returnCode = $this->RESULT_INCORRECT_UUID;
                }
                else{
                    $keys = ['machine_id', 'request_by', 'status_id'];
                    foreach ($keys as $key)
                    {
                        $postData[$key] = $this->post($key);
                    }
                    $postData['requested_time'] = date('Y-m-d H:i:s');
                    $sqlNo = $this->post('sql_no');
                    $searchKey = $this->post('search_key');
                    if ($searchKey != null && !empty($searchKey)){
                        $postData['request_data'] = $this->generateRequestData((int)$sqlNo, $searchKey);
                    }
                    else{
                        $postData['request_data'] = $this->generateRequestData((int)$sqlNo, "");
                    }
                    $postData['unique_id'] = $this->generateRequestUUID();

                    if (!empty($postData['machine_id']) && !empty($postData['request_by']) && !empty($postData['status_id']))
                    {
                        $this->BaseModel->updateItemData('data_log', $postData, 0);
                        $resultData['uuid'] = $postData['unique_id'];
                    }
                    else{
                        $returnCode = $this->RESULT_FAILED;
                    }
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

	public function requestEmailUUID_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $userId = $this->post('user_id');
            $userUniqueId = $this->post('unique_id');
            if (!empty($userId) && !empty($userUniqueId)){
                $userInfo = $this->CommunicationModel->getDataArray('account', 'id', $userId)[0];
                if ($userUniqueId != $userInfo['unique_id']){
                    $returnCode = $this->RESULT_INCORRECT_UUID;
                }
                else{
					$keys = ['request_by', 'status_id'];
					foreach ($keys as $key)
					{
						$postData[$key] = $this->post($key);
					}
					$postData['requested_time'] = date('Y-m-d H:i:s');
					$sqlNo = $this->post('sql_no');
					$searchKey = $this->post('search_key');
					if ($searchKey != null && !empty($searchKey)){
						$postData['request_data'] = $this->generateRequestData((int)$sqlNo, $searchKey);
					}
					else{
						$postData['request_data'] = $this->generateRequestData((int)$sqlNo, "");
					}
                	$machineIds = $this->post('machine_id');
					$machineList = explode(",", $machineIds);
					foreach($machineList as $key=>$value) {
						$postData['machine_id'] = $value;
						$postData['unique_id'] = $this->generateRequestUUID();
						if (!empty($postData['machine_id']) && !empty($postData['request_by']) && !empty($postData['status_id']))
						{
							$this->BaseModel->updateItemData('data_log', $postData, 0);
						}
					}
					$resultData['uuid'] = $postData['unique_id'];
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function requestUUIDS_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        $requestUniqueIDs = [];
        try {
            $userId = $this->post('user_id');
            $userUniqueId = $this->post('unique_id');
            $machineId = $this->post('machine_id');
            $sqlNo = $this->post('sql_no');
            $searchKey = $this->post('search_key');
            if (!empty($userId) && !empty($userUniqueId)){
                $userInfo = $this->CommunicationModel->getDataArray('account', 'id', $userId)[0];
                if ($userUniqueId != $userInfo['unique_id']){
                    $returnCode = $this->RESULT_INCORRECT_UUID;
                }
                else{
                    if(!empty($machineId) && $machineId != null) {
                        $branches = $this->CommunicationModel->getShopBranches($userId);
                        if (!empty($branches) && count($branches) > 0) {
                            for ($i = 0; $i < count($branches); $i++){
                                $keys = ['request_by', 'status_id'];
                                foreach ($keys as $key) {
                                    $postData[$key] = $this->post($key);
                                }
                                $postData['machine_id'] = $branches[$i]['machine_id'];
                                $postData['requested_time'] = date('Y-m-d H:i:s');
                                if ($searchKey != null && !empty($searchKey)) {
                                    $postData['request_data'] = $this->generateRequestData((int)$sqlNo, $searchKey);
                                } else {
                                    $postData['request_data'] = $this->generateRequestData((int)$sqlNo, "");
                                }
                                $postData['unique_id'] = $this->generateRequestUUID();

                                $this->BaseModel->updateItemData('data_log', $postData, 0);
                                array_push($requestUniqueIDs, [$postData['unique_id'], $branches[$i]['shop_name'], $branches[$i]['branch'], $branches[$i]['machine_id']]);
                            }
                            $resultData['uuids'] = $requestUniqueIDs;
                        }
                        else{
                            $returnCode = $this->RESULT_FAILED;
                        }
                    }
                    else{
                        $returnCode = $this->RESULT_FAILED;
                    }
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }


    /**
     * Function : get dashboard date from data log
     * Parameter: uuid
     * Return   : dashboard data to display in frontend
     * Creator  : mars
     * Date     : 20191119
     */
	public function getDashboardData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getDashboardData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $resultData[] = json_decode($tempData[0]['response_data']);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getCustomerData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');
			$searchValue = $this->get('search_value');
            $customerType = $this->get('customer_type');
			if (!empty($uniqueId)){
				$allData = $this->CommunicationModel->getCustomerList($uniqueId, $customerType, $searchValue);
				if ( $allData != null && !empty($allData)){
					$resultData = $allData;
				}
				else{
					if (!empty($searchValue) && $searchValue != null){
						$returnCode = $this->RESULT_SEARCH_EMPTY;
					}
					else{
						$responseStatus =  $this->CommunicationModel->getDataArray('data_log', 'unique_id', $uniqueId)[0]['status_id'];
						if ($responseStatus == 5){
							$returnCode = $this->RESULT_SEARCH_EMPTY;
						}
						else{
							$returnCode = $this->RESULT_FAILED;
						}
					}
				}
			}
			else{
				$returnCode = $this->RESULT_FAILED;
			}
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getCustomerProfileData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getDashboardData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['detail'] =json_decode( $firstData['detail'], true);
                    $resultData['transaction'] =json_decode( $firstData['transaction'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getStaffData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');
            $searchValue = $this->get('search_value');
            if (!empty($uniqueId)){
                $allData = $this->CommunicationModel->getStaffList($uniqueId, $searchValue);
                if ( $allData != null && !empty($allData)){
                    $resultData = $allData;
                }
                else{
                    if (!empty($searchValue) && $searchValue != null){
                        $returnCode = $this->RESULT_SEARCH_EMPTY;
                    }
                    else{
                        $responseStatus =  $this->CommunicationModel->getDataArray('data_log', 'unique_id', $uniqueId)[0]['status_id'];
                        if ($responseStatus == 5){
                            $returnCode = $this->RESULT_SEARCH_EMPTY;
                        }
                        else{
                            $returnCode = $this->RESULT_FAILED;
                        }
                    }
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getStaffProfileData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getDashboardData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['profile'] =json_decode( $firstData['profile'], true);
//                    $resultData['attendance'] =json_decode( $firstData['attendance'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getOfferData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getOfferData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                	$firstData = json_decode($tempData[0]['response_data'], true);
	            	$resultData['category'] =json_decode( $firstData['category'], true);
                	$resultData['available'] =json_decode( $firstData['available'], true);
                	$resultData['disable'] =json_decode( $firstData['disable'], true);
				}
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getOfferCategory_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');
            $category = $this->get('category');
            $type = $this->get('type');
            $searchKey = $this->get('search_key');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getOfferList($uniqueId, $type, $category, $searchKey);
                if (!empty($tempData) && $tempData != null){
                	$resultData = $tempData;
				}
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getItemOptions_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getDashboardData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['options'] =json_decode( $firstData['options'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getReportData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getOfferData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['result'] =json_decode( $firstData['result'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getOfferDetailData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getOfferData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['detail'] =json_decode( $firstData['detail'], true);
                    $resultData['content'] =json_decode( $firstData['content'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function getNoticeData_get(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $uniqueId = $this->get('unique_id');

            if(!empty($uniqueId)) {
                $tempData = $this->CommunicationModel->getDashboardData($uniqueId);
                if (!empty($tempData[0]['response_data']) && $tempData[0]['response_data'] != null){
                    $firstData = json_decode($tempData[0]['response_data'], true);
                    $resultData['result'] =json_decode( $firstData['result'], true);
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

	public function getConsolidateResult_post() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];
		try {
			$requestUniqueIDs = $this->post("requestUniqueIDs");

			if(!empty($requestUniqueIDs)) {
				$requestIDList = json_decode($requestUniqueIDs, true);
//                $requestIDList = explode(",", $requestUniqueIDs);
//                    print_r($requestIDList); exit();

				if (!empty($requestIDList) && count($requestIDList) > 0) {
					for ($i = 0; $i < count($requestIDList); $i++) {
						$machineResult = $this->CommunicationModel->getBranchConsolidateData($requestIDList[$i][0]);

						if (!empty($machineResult) && count($machineResult) > 0) {
							$temp = $machineResult[0]['response_data'];
							$tempJsonString = json_decode($temp, true);

							if (!empty($tempJsonString) && count($tempJsonString) > 0) {
								$tempRes = json_decode($tempJsonString['result'], true);

								if (!empty($tempRes) && count($tempRes) > 0) {
									$resultTemp = [];
									$resultTemp['shopName'] = $requestIDList[$i][1];
									$resultTemp['branch'] = $requestIDList[$i][2];
									$resultTemp['machineId'] = $requestIDList[$i][3];
									$resultTemp['data'] = $tempRes;

									array_push($resultData, $resultTemp);
								}
							}
						}
					}
//                    print_r($resultData); exit();
				}
				else{
					$returnCode = $this->RESULT_EMPTY_DATA;
				}
			} else {
				print_r("empty request ids"); exit();
				$returnCode = $this->RESULT_FAILED;
			}
		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}
		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);

	}

    public function getConsolidateResult_get() {
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $requestUniqueIDs = $this->get("requestUniqueIDs");

            if(!empty($requestUniqueIDs)) {
                $requestIDList = json_decode($requestUniqueIDs, true);
//                $requestIDList = explode(",", $requestUniqueIDs);
//                    print_r($requestIDList); exit();

                if (!empty($requestIDList) && count($requestIDList) > 0) {
                    for ($i = 0; $i < count($requestIDList); $i++) {
                        $machineResult = $this->CommunicationModel->getBranchConsolidateData($requestIDList[$i][0]);

                        if (!empty($machineResult) && count($machineResult) > 0) {
                            $temp = $machineResult[0]['response_data'];
                            $tempJsonString = json_decode($temp, true);

                            if (!empty($tempJsonString) && count($tempJsonString) > 0) {
                                $tempRes = json_decode($tempJsonString['result'], true);

                                if (!empty($tempRes) && count($tempRes) > 0) {
                                    $resultTemp = [];
                                    $resultTemp['shopName'] = $requestIDList[$i][1];
                                    $resultTemp['branch'] = $requestIDList[$i][2];
                                    $resultTemp['machineId'] = $requestIDList[$i][3];
                                    $resultTemp['data'] = $tempRes;

                                    array_push($resultData, $resultTemp);
                                }
                            }
                        }
                    }
//                    print_r($resultData); exit();
                }
                else{
                	$returnCode = $this->RESULT_EMPTY_DATA;
				}
            } else {
				print_r("empty request ids"); exit();
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }
        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);

    }

    public function tryUserLogin_get() {
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $updateData = [];

        try {
            $email = $this->get('email');
            $password = $this->get('password');
            $sdktype = $this->get('type');
            if(!empty($email)) {
                if (!empty($password)){
                    $tempUser = $this->CommunicationModel->getUser($email, $password);
                }
                else if (!empty($sdktype)){
                    $tempUser = $this->CommunicationModel->getSocialUser($email, $sdktype);
					$photoUrl = $this->get('photo_url');
					if (!empty($tempUser)){
						if ($photoUrl != "" && !empty($photoUrl)){
							$currentPhotoUrl = $tempUser[0]['photo_url'];
							$currentUserId = $tempUser[0]['id'];
							if ($photoUrl != $currentPhotoUrl){
								$updateData['photo_url'] = $photoUrl;
								$this->CommunicationModel->updateItemData('account', $updateData, $currentUserId);
							}
						}
					}
                }

                if (!empty($tempUser)){
                    $currentDate = date('Y-m-d H:i:s');
                    $expireDate = $tempUser[0]['expired_date'];
                    if ($currentDate < $expireDate && $tempUser[0]['status_id'] == 1){
                        $uniqueID = $this->generateOwnerUUID();
                        $userId = $tempUser[0]['id'];
                        $this->CommunicationModel->updateItemData('account', ['unique_id' => $uniqueID], $userId);
                        $userInfo = $this->CommunicationModel->getDataArray('account', 'id', $userId)[0];
                        $machineID = EMPTY_STRING;
                        $shopName = EMPTY_STRING;
                        $branch = EMPTY_STRING;
                        $selectedShopIndex = -1;
                        $isFirstSelect = false;
                        $shopList = $this->CommunicationModel->getShopList($userId);
                        if (count($shopList) > 0) {
                            for ($i = 0; $i < count($shopList); $i++) {
                                if ((int)$shopList[$i]['status_id'] == STATUS_ACTIVATED) {
                                    $diffDate = $this->getDiffDateFromCurrentDate($shopList[$i]['expired_date']);
                                    if ($diffDate >= 0) {
                                        if (!$isFirstSelect || $shopList[$i]['id'] == $userInfo['last_shop_id']) {
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
                        $this->CommunicationModel->updateItemData('account', ['last_shop_id' => $selectedShopIndex], $userId);
                        $userInfo['machine_id'] = $machineID;
                        $userInfo['shop_name'] = $shopName;
                        $userInfo['branch_name'] = $branch;
                        $resultData = $userInfo;
                    }
                    else{
                        $returnCode = $this->RESULT_OVER_EXPIRED;
                    }
                }
                else
                    $returnCode = $this->RESULT_EMAIL_PASSWORD_INCORRECT;
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }


    public function tryRegister_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $keys = ['first_name', 'last_name','email','password'];
            foreach ($keys as $key)
            {
                $postData[$key] = $this->post($key);
            }
            $postData['registered_date'] = date('Y-m-d H:i:s');
            $postData['owner_level'] = 0;
            $postData['email_binding_status'] = 1;

            if (!empty($postData['email']))
            {
                $sameUserList = $this->CommunicationModel->getDataArray('account', 'email', $postData['email']);
                if (empty($sameUserList)){
                    $this->CommunicationModel->updateItemData('account', $postData, 0);
                }
                else{
                    $returnCode = $this->RESULT_EMAIL_DUPLICATE;
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function trySocialRegister_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $keys = ['first_name', 'last_name','email'];
            foreach ($keys as $key)
            {
                $postData[$key] = $this->post($key);
            }
            $sdkType = $this->post('type');
            $photoUrl = $this->post('photo_url');
            if (!empty($photoUrl) || $photoUrl != ""){
                $postData['photo_url'] = $photoUrl;
            }
            $postData['registered_date'] = date('Y-m-d H:i:s');
            $postData['owner_level'] = 0;
            if($postData['email'] == "" || empty($postData['email'])){
                $postData['email_binding_status'] = 0;
            }
            else
                $postData['email_binding_status'] = 1;
            if (!empty($sdkType)){
                if ($sdkType == '1'){
                    $postData['facebook_id'] = $this->post('sdk_id');
                    $sameUserList = $this->CommunicationModel->getDataArray('account', 'facebook_id', $postData['facebook_id']);
                    if (empty($sameUserList)){
                        if($postData['email'] == "" || empty($postData['email'])){
                            $this->CommunicationModel->updateItemData('account', $postData, 0);
                            $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'facebook_id', $postData['facebook_id'])[0];
                        }
                        else{
                            $sameEmailList = $this->CommunicationModel->getDataArray('account', 'email', $postData['email']);
                            if (empty($sameEmailList)){
                                $this->CommunicationModel->updateItemData('account', $postData, 0);
                                $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'facebook_id', $postData['facebook_id'])[0];
                            }
                            else{
                                $tempUserId = $sameEmailList[0]['id'];
                                $this->CommunicationModel->updateItemData('account', $postData, $tempUserId);
                                $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'id', $tempUserId)[0];
                            }
                        }
                    }
                    else{
                        $returnCode = $this->RESULT_EMAIL_DUPLICATE;
                    }
                }
                else if ($sdkType == '2'){
                    $postData['google_id'] = $this->post('sdk_id');
                    $sameUserList = $this->CommunicationModel->getDataArray('account', 'google_id', $postData['google_id']);
                    if (empty($sameUserList)){
                        if($postData['email'] == "" || empty($postData['email'])){
                            $this->CommunicationModel->updateItemData('account', $postData, 0);
                            $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'google_id', $postData['google_id'])[0];
                        }
                        else{
                            $sameEmailList = $this->CommunicationModel->getDataArray('account', 'email', $postData['email']);
                            if (empty($sameEmailList)){
                                $this->CommunicationModel->updateItemData('account', $postData, 0);
                                $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'google_id', $postData['google_id'])[0];
                            }
                            else{
                                $tempUserId = $sameEmailList[0]['id'];
                                $this->CommunicationModel->updateItemData('account', $postData, $tempUserId);
                                $resultData = $this->BaseModel->CommunicationModel->getDataArray('account', 'id', $tempUserId)[0];
                            }
                        }
                    }
                    else{
                        $returnCode = $this->RESULT_EMAIL_DUPLICATE;
                    }
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function addNewShop_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $postData['registered_date'] = date('Y-m-d H:i:s');
            $postData['shop_name'] = $this->post('shop_name');
            $postData['machine_id'] = $this->post('machine_id');
            $postData['branch'] = $this->post('branch');
            if (!empty($postData['machine_id'])){
            	$sameShopList = $shopId = $this->CommunicationModel->getDataArray('shop', 'machine_id', $postData['machine_id']);
            	if (empty($sameShopList )){
					$this->CommunicationModel->updateItemData('shop', $postData, 0);
					$shopId = $this->CommunicationModel->getDataArray('shop', 'machine_id', $postData['machine_id'])[0]['id'];
					$updateData['account_id'] = $this->post('user_id');
					$updateData['shop_id'] = $shopId;
					$this->CommunicationModel->updateItemData('shop_management', $updateData, 0);
				}
            	else{
					$shopId = $sameShopList[0]['id'];
					$updateData['account_id'] = $this->post('user_id');
					$updateData['shop_id'] = $shopId;
					$shopRegisterList = $this->CommunicationModel->getShopRegisterList($updateData['account_id'], $updateData['shop_id']);
					if (empty($shopRegisterList)){
						$this->CommunicationModel->updateItemData('shop_management', $updateData, 0);
					}
					else{
						$returnCode = $this->RESULT_MACHINE_ID_EXIST;
					}
				}
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function changePassword_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $userId = $this->post('userId');
            $postData['password'] = $this->post('password');
            if (!empty($postData['password']) && !empty($userId)){
                $userList = $this->CommunicationModel->getDataArray('account', 'id', $userId);
                if (!empty($userList)){
                    $this->CommunicationModel->updateItemData('account', $postData, $userId);
                    $resultData["password"] = $this->CommunicationModel->getDataArray('account', 'id', $userId)[0]['password'];
                }
                else{
                    $returnCode = $this->RESULT_FAILED;
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

	public function getShopList_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];

		try {
			$userId = $this->get('user_id');
			if(!empty($userId)) {
				$shopList = $this->CommunicationModel->getShopList($userId);
				if(!empty($shopList) && count($shopList) > 0){
				    $activatedShopList = [];
				    for ($i = 0; $i < count($shopList); $i++){
				        if ((int)$shopList[$i]['status_id'] == STATUS_ACTIVATED){
                            $diffDate = $this->getDiffDateFromCurrentDate($shopList[$i]['expired_date']);
                            if ($diffDate >= 0) {
                                array_push($activatedShopList, $shopList[$i]);
                            } else {
                                $updateData = [];
                                $updateData['status_id'] = STATUS_EXPIRED;
                                $this->ShopModel->updateItemData('shop', $updateData, $shopList[$i]['id']);
                            }
                        }
                        $resultData = $activatedShopList;
                    }
				}
				else{
					$returnCode = $this->RESULT_EMPTY_SHOP;
				}
			} else {
				$returnCode = $this->RESULT_FAILED;
			}
		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

	public function updateShopLog_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];

		try {
			$userId = $this->get('user_id');
			$email = $this->get('email');
			if(!empty($userId) && !empty($email)) {
				$shopList = $this->CommunicationModel->getShopList($userId);
				if(!empty($shopList) && count($shopList) > 0){
				    for ($i = 0; $i < count($shopList); $i++){
				        if ((int)$shopList[$i]['status_id'] == STATUS_ACTIVATED){
                            $diffDate = $this->getDiffDateFromCurrentDate($shopList[$i]['expired_date']);
                            if ($diffDate >= 0) {
                                $requestData = $this->generateDataLogRowWithMachineID(MY_SHOPS_GET_AMOUNT, $shopList[$i]['machine_id'], $email);
                                $updateData = [];
                                $updateData['online_status'] = 0;
                                $this->BaseModel->updateItemData('shop', $updateData, $shopList[$i]['id']);
                                $this->BaseModel->updateItemData('data_log', $requestData, 0);
                            } else {
                                $updateData = [];
                                $updateData['status_id'] = STATUS_EXPIRED;
                                $this->BaseModel->updateItemData('shop', $updateData, $shopList[$i]['id']);
                            }
                        }
                    }
				}
				else{
					$returnCode = $this->RESULT_EMPTY_SHOP;
				}
			} else {
				$returnCode = $this->RESULT_FAILED;
			}
		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

    public function updateLastShop_get() {
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];

        try {
            $userId = $this->get('user_id');
            $shopId = $this->get('shop_id');
            if(!empty($userId) && !empty($shopId)) {
                $updateData['last_shop_id'] = $shopId;
                $this->BaseModel->updateItemData('account', $updateData, $userId);
            } else {
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }



    public function getDiffDateFromCurrentDate($comparedDate) {
        $expireDate = new DateTime($comparedDate);
        $currentDate = new DateTime();
        $diff = $currentDate->diff($expireDate);
        $diffDate = (int)$diff->format('%R%a');

        return $diffDate;
    }

    public function generateDataLogRowWithMachineID($sqlNo, $machineID, $email) {
        $data = [];
        $data['machine_id'] = $machineID;
        $data['request_by'] = $email;
        $data['request_data'] = $this->generateRequestData($sqlNo, "");
        $data['status_id'] = DATA_REQUESTED;
        $data['unique_id'] = $this->generateRequestUUID();
        $data['requested_time'] = date("Y-m-d H:i:s");

        return $data;
    }

    public function addNewItemReplenish_post() {
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
			$keys = ['account_id', 'machine_id', 'item_name', 'item_code', 'quantity', 'unit', 'expired_date'];
			foreach ($keys as $key)
			{
				$postData[$key] = $this->post($key);
			}

            if (!empty($postData['machine_id']) && !empty($postData['account_id'])){
				$this->BaseModel->updateItemData('replenish_temp', $postData, 0);
				$tempItemList = $this->CommunicationModel->getTempItemReplenish($postData['account_id'], $postData['machine_id']);
				if (!empty($tempItemList) && $tempItemList != null){
					$resultData = $tempItemList;
					$returnCode = $this->RESULT_SUCCESS;
				}
				else{
					$returnCode = $this->RESULT_FAILED;
				}
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }

        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

	public function getTempReplenishList_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];
		$postData = [];
		try {

			$userId = $this->get('account_id');
			$machineId = $this->get('machine_id');
			if (!empty($userId) && !empty($machineId)){
				$tempItemList = $this->CommunicationModel->getTempItemReplenish($userId, $machineId);
                $resultData = $tempItemList;
                $returnCode = $this->RESULT_SUCCESS;
			}
			else{
				$returnCode = $this->RESULT_FAILED;
			}

		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}


	public function deleteTempReplenishItem_get() {
		$returnCode = $this->RESULT_SUCCESS;
		$resultData = [];
		try {

			$userId = $this->get('account_id');
			$machineId = $this->get('machine_id');
			$itemId = $this->get("item_id");
			if (!empty($userId) && !empty($machineId) && !empty($itemId)){
				$this->BaseModel->deleteItems('replenish_temp', [$itemId]);
				$tempItemList = $this->CommunicationModel->getTempItemReplenish($userId, $machineId);
				$resultData = $tempItemList;
				$returnCode = $this->RESULT_SUCCESS;
			}
			else{
				$returnCode = $this->RESULT_FAILED;
			}

		} catch (Exception $e) {
			$returnCode = $this->RESULT_FAILED;
		}

		$result = $this->getResultData($returnCode, $resultData);
		$this->response($result,REST_Controller::HTTP_OK);
	}

    public function itemReplenishSave_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $postData = [];
        try {
            $keys = ['machine_id', 'request_by', 'status_id'];
            foreach ($keys as $key)
            {
                $postData[$key] = $this->post($key);
            }
            $postData['requested_time'] = date('Y-m-d H:i:s');
            $postData['unique_id'] = $this->generateRequestUUID();
            $sqlNo = $this->post('sql_no');
            $ownerId = $this->post('user_id');
            $ownerData = $this->BaseModel->getDataArray('account', 'id', $ownerId)[0];
            $saveData['ownerName'] = $ownerData['first_name']." ".$ownerData['last_name'];
            $allData = $this->CommunicationModel->getTempItemReplenishForWindowsService($ownerId, $postData['machine_id']);
            $saveData['replenish'] = $allData;

            $postData['request_data'] = $this->generateRequestData((int)$sqlNo, json_encode($saveData));

            if (!empty($postData['machine_id']) && !empty($postData['request_by']) && !empty($postData['status_id']) && !empty($postData['request_data']))
            {
                $this->BaseModel->updateItemData('data_log', $postData, 0);
                $resultData['uuid'] = $postData['unique_id'];

                for ($i = 0; $i < count($allData); $i++) {
                    $this->BaseModel->deleteItems('replenish_temp', [$allData[$i]['id']]);
                }
            }
            else{
                $returnCode = $this->RESULT_FAILED;
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function sendEmailForForgotPassword_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $email = $this->post('email');
            if (empty($email))
                $returnCode = $this->RESULT_FAILED;
            else {
                $ownerData = $this->BaseModel->getDataArray('account', 'email', $email);
                if (empty($ownerData) || count($ownerData) < 1)
                    $returnCode = $this->RESULT_EMAIL_INCORRECT;
                else {
                    $token = $this->generateRequestUUID();
                    $verificationCode = $this->generateVerificationCode();
                    $updateData = [];
                    $updateData['account_id'] = $ownerData[0]['id'];
                    $userId = $ownerData[0]['id'];
                    $updateData['token'] = $token;
                    $this->BaseModel->updateItemData('token_history', $updateData, 0);

                    $tokenLink = "" . SERVER_ADDRESS . "/flogin/resetPassword?token=".$token;
                    $content = "<div style='padding: 5%;'>
                        <label style='font-size: 24px;'>" . EMAIL_TITLE . "</label><br/><br/>
                        <label style='font-size: 16px; color: grey;'>The verification code is ".$verificationCode.".</label><br/><br/><br/>
                       </div>";

                    $result =  $this->sendEmail($ownerData[0]['email'], EMAIL_TITLE, $content);
                    if($result == 1){
                        $postData = [];
                        $postData['verification_code'] = $verificationCode;
                        $postData['verification_used'] = 0;
                        $this->BaseModel->updateItemData('account', $postData, $userId);
                        $resultData['userId'] = $userId;
                        $returnCode = $this ->RESULT_SUCCESS;
                    }
                    else if ($result == 2){
                        $returnCode = $this ->RESULT_SEND_EMAIL_FAILED;
                    }
                }
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function sendEmailForSDKBinding_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        try {
            $email = $this->post('email');
            $userId = $this->post('userId');
            if (empty($email) || empty($userId))
                $returnCode = $this->RESULT_FAILED;
            else {
                $ownerData = $this->BaseModel->getDataArray('account', 'email', $email);
                if (!empty($ownerData) || count($ownerData) > 1)
                    $returnCode = $this->RESULT_EMAIL_DUPLICATE;
                else{
                    $postData = [];
                    $postData['email'] = $email;
                    $this->BaseModel->updateItemData('account', $postData, $userId);
                    $ownerData = $this->BaseModel->getDataArray('account', 'id', $userId);
                    $token = $this->generateRequestUUID();
                    $verificationCode = $this->generateVerificationCode();
                    $updateData = [];
                    $updateData['account_id'] = $ownerData[0]['id'];
                    $userId = $ownerData[0]['id'];
                    $updateData['token'] = $token;
                    $this->BaseModel->updateItemData('token_history', $updateData, 0);
                    $content = "<div style='padding: 5%;'>
                        <label style='font-size: 24px;'>" . EMAIL_TITLE . "</label><br/><br/>
                        <label style='font-size: 16px; color: grey;'>The verification code is ".$verificationCode.".</label><br/><br/><br/>
                       </div>";

                    $result =  $this->sendEmail($ownerData[0]['email'], EMAIL_TITLE, $content);
                    if($result == 1){
                        $postData = [];
                        $postData['verification_code'] = $verificationCode;
                        $postData['verification_used'] = 0;
                        $this->BaseModel->updateItemData('account', $postData, $userId);
                        $resultData['userId'] = $userId;
                        $returnCode = $this ->RESULT_SUCCESS;
                    }
                    else if ($result == 2){
                        $returnCode = $this ->RESULT_SEND_EMAIL_FAILED;
                    }
                }
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function sendEmail($email, $title, $content) {
        if (!empty($email) && !empty($title) && !empty($content)) {
            $config['protocol'] = 'smtp';
            $config['smtp_host'] = SMTP_SERVER;
            $config['smtp_user'] = SYSTEM_MAIL;
            $config['smtp_pass'] = SMTP_PASSWORD;
            $config['smtp_port'] = 465;
            $config['charset'] = 'utf-8';
            $config['mailtype'] = 'html';
            // $config['smtp_timeout'] = '5';
            $config['newline'] = "\r\n";
            $this->load->library('email', $config);

            $this->email->from(SYSTEM_MAIL, 'nSofts');
            $this->email->to($email);
            $this->email->subject($title);
            $this->email->message($content);

            if($this->email->send())
                return 1;
            else {
                return 2;
            }
        } else {
            return 2;
        }
    }

    public function generateVerificationCode()
    {
        $result = "";
        for ($i = 0; $i < 6; $i++)
        {
            $result .= rand(0, 9);
        }

        return $result;
    }

    public function sendVerificationCode_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $updateData = [];
        try {
            $userId = $this->post('userId');
            $verificationCode = $this->post('code');
            if (empty($userId) || empty($verificationCode))
                $returnCode = $this->RESULT_FAILED;
            else {
                $ownerData = $this->BaseModel->getDataArray('account', 'id', $userId)[0];
                if ($verificationCode == $ownerData['verification_code']){
                    if ($ownerData['verification_used'] == 0){
                        $updateData['verification_used'] = 1;
                        $this->BaseModel->updateItemData('account', $updateData, $userId);
                    }
                    else{
                        $returnCode = $this->RESULT_VERIFICATION_CODE_USED;
                    }
                }
                else{
                    $returnCode = $this->RESULT_VERIFICATION_CODE_INCORRECT;
                }
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    public function sendVerificationCodeForBinding_post(){
        $returnCode = $this->RESULT_SUCCESS;
        $resultData = [];
        $updateData = [];
        try {
            $userId = $this->post('userId');
            $verificationCode = $this->post('code');
            if (empty($userId) || empty($verificationCode))
                $returnCode = $this->RESULT_FAILED;
            else {
                $ownerData = $this->BaseModel->getDataArray('account', 'id', $userId)[0];
                if ($verificationCode == $ownerData['verification_code']){
                    if ($ownerData['verification_used'] == 0){
                        $updateData['verification_used'] = 1;
                        $updateData['email_binding_status'] = 1;
                        $this->BaseModel->updateItemData('account', $updateData, $userId);
                    }
                    else{
                        $returnCode = $this->RESULT_VERIFICATION_CODE_USED;
//                        $resultData = $this->BaseModel->getDataArray('account', 'id', $userId)[0];
                    }
                }
                else{
                    $returnCode = $this->RESULT_VERIFICATION_CODE_INCORRECT;
                }
            }
        } catch (Exception $e) {
            $returnCode = $this->RESULT_FAILED;
        }

        $result = $this->getResultData($returnCode, $resultData);
        $this->response($result,REST_Controller::HTTP_OK);
    }

    //todo for the test

}
