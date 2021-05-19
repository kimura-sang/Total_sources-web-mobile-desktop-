<?php
defined('BASEPATH') OR exit('No direct script access allowed');

//include_once("./sms/CCPRestSmsSDK.php");

class BaseController extends CI_Controller
{
	public $WAITING_LIMIT_TIME = 7;

    public function __construct()
    {
        parent::__construct();
        $this->load->helper('url');
        $this->load->library('session');

        $this->load->model('BaseModel');

        header('Cache-Control: no cache');
        date_default_timezone_set('Asia/Shanghai');
    }

    public function template()
    {
    	$this->load->view('backend/template/index', $this->data);
    }

	public function adminSignOut(){
		$sessionArray = array('adminId', 'adminEmail');

		$this->session->unset_userdata($sessionArray);
		session_destroy();
		redirect('/adminlogin');
	}

    public function userTemplate()
    {
		$this->load->view('frontend/template/index', $this->data);
    }

	public function signOut(){
		$sessionArray = array('ownerId', 'email', 'shopName', 'branch', 'machineID', 'selectedShopIndex');

		$this->session->unset_userdata($sessionArray);
		session_destroy();
		redirect('/flogin');
	}

	public function initUserSession() {
		$sessionArray = array(
			"shopName" => EMPTY_STRING,
			"branch" => EMPTY_STRING,
			"machineID" => EMPTY_STRING,
			'selectedShopIndex' => -1
		);

		$this->session->set_userdata($sessionArray);
	}

	public function checkUUIDIsSame() {
		if(isset($this->session->ownerId)) {
			$userData = $this->BaseModel->getDataArray('account', 'id', $this->session->ownerId);
			if (!empty($userData) && !empty($userData[0])) {
				if ($userData[0]['unique_id'] != $this->session->uniqueID) {
					return false;
				} else {
					return true;
				}
			}
		} else {
			$this->signOut();
		}

		return true;
	}

    public function recurse_copy($src,$dst)
    {
        $dir = opendir($src);

        if (!file_exists($dst)) {
            mkdir($dst, 0777, true);
        }

        while(false !== ( $file = readdir($dir)) ) {
            if (( $file != '.' ) && ( $file != '..')) {
                if (file_exists($src . '/' . $file)) {
                    if (is_dir($src . '/' . $file)) {
                        $this->recurse_copy($src . '/' . $file, $dst . '/' . $file);
                    } else {
                        copy($src . '/' . $file, $dst . '/' . $file);
                    }
                }
            }
        }

        closedir($dir);
    }

    public function deleteDirectory($path)
    {
        if (is_dir($path) === true) {
            $files = array_diff(scandir($path), array('.', '..'));

            foreach ($files as $file) {
                $this->deleteDirectory(realpath($path) . '/' . $file);
            }

            return rmdir(realpath($path));
        }
        else if (is_file($path) === true) {
            return unlink($path);
        }

        return false;
    }

	/**
	 * Function : generate UUID for owners
	 * Parameter:
	 * Return   : 32bit UUID
	 * Creator  : billy
	 * Date     : 20191114
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
	 * Function : generate UUID for request data
	 * Parameter:
	 * Return   : 32bit UUID
	 * Creator  : billy
	 * Date     : 20191114
	 */
	public function generateRequestUUID()
	{
		return md5(uniqid(mt_rand(), true));
	}

	public function generate8BitRandomPassword()
	{
		return substr ( md5(uniqid(mt_rand(), true)), 0, 8 );
	}


	/**
	 * @return bool|string
	 */
	public function generateSuffix()
    {
        $chars = md5(uniqid(mt_rand(), true));
        return substr($chars, 10, 3);
    }

	/**
	 * @param $jsonData
	 */
	public function getJsonDecodeError($jsonData)
	{
		$result = json_decode($jsonData, true);
		if(!$result)
		{
			//error handle ,错误处理
			$ret = json_last_error();
			print_r($ret);   //打印为： 4,查错误信息表，可知是语法错误
		}
	}

    /**
     * Function : call restful api
     * Parameter: method, url, $data
     * Return   :
     *      returnData :
     * Creator  : clark
     * Date     : 20190203
     */
    function CallAPI($method, $url, $data = false)
    {
        $curl = curl_init();

        switch ($method)
        {
            case "POST":
                curl_setopt($curl, CURLOPT_POST, 1);

                if ($data)
                    curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
                break;
            case "PUT":
                curl_setopt($curl, CURLOPT_PUT, 1);
                break;
            default:
                if ($data)
                    $url = sprintf("%s?%s", $url, http_build_query($data));
        }

        // Optional Authentication:
        curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
        curl_setopt($curl, CURLOPT_USERPWD, "username:password");

        curl_setopt($curl, CURLOPT_URL, $url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

        $result = curl_exec($curl);

        curl_close($curl);

        return $result;
    }

    public function isIncludeSpaceCharacter($value)
    {
        if (empty($value))
            return false;

        if (strpos($value, " "))
            return true;
        else
            return false;
    }


	/**
	 * Function : generate request data by sql no
	 * Parameter: sql no, search key
	 * Return   : request data json
	 * Creator  : billy
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
	 * Function : generate request data log row
	 * Parameter: sql no
	 * Return   : data low row
	 * Creator  : billy
	 * Date     : 20191114
	 * @param $sqlNo
	 * @param string $searchKey
	 * @return array
	 */
	public function generateDataLogRow($sqlNo, $searchKey = "")
	{
		$data = [];
		$data['machine_id'] = $this->session->machineID;
		$data['request_by'] = $this->session->email;
		$data['request_data'] = $this->generateRequestData($sqlNo, $searchKey);
		$data['status_id'] = DATA_REQUESTED;
		$data['unique_id'] = $this->generateRequestUUID();
		$data['requested_time'] = date("Y-m-d H:i:s");

		return $data;
	}

	/**
	 * Function : get process result data
	 * Parameter: resultCode, resultData
	 * Return   : result array
	 * Creator  : billy
	 * Date     : 20191114
	 * @param $returnCode
	 * @param $resultData
	 * @return array
	 */
	public function getProcessResultData($returnCode, $resultData = NULL) {
		$returnData = [];
		$returnData['code'] = $returnCode;

		if (!empty($resultData))
			$returnData['data'] = $resultData;

		return $returnData;
	}

	/**
	 * Function : waiting to get response
	 * Creator  : billy
	 * Date     : 20191114
	 */
	public function waitingToGetResponse()
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
							$resultData = $dataLog['response_data'];
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

	/**
	 * Function : waiting to get response
	 * Creator  : billy
	 * Date     : 20191114
	 */
	public function waitingToGetResponseWithoutData()
	{
		$resultCode = 1;

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

		echo json_encode($this->getProcessResultData($resultCode, []));
	}

	public function getDiffDateFromCurrentDate($comparedDate) {
		$expireDate = new DateTime($comparedDate);
		$currentDate = new DateTime();
		$diff = $currentDate->diff($expireDate);
		$diffDate = (int)$diff->format('%R%a');

		return $diffDate;
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
//				show_error($this->email->print_debugger());
			}
		} else {
			return 2;
		}
	}
}
