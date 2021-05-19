<?php

class LoginModel extends BaseModel
{
    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set('Asia/Shanghai');
    }

    function getMember($account, $password = null)
    {
        $sql = "select a.* from account as a ";

        $sql .= " where a.email = '$account'";
        if ($password != null)
            $sql .= " and a.password = '$password'";

        $result = $this->db->query($sql);

        return $result->row();
    }

	function judgeTokenIsValid($token) {
		$sql = "select * from token_history where token='$token' and used=0";
		$validResult = $this->db->query($sql)->row();

		$sql = "select max(th.id) as max_id from token_history as th
				inner join (
					select * from token_history
					where token='$token'
				) as vt on vt.account_id = th.account_id";
		$maxResult = $this->db->query($sql)->row();

		$result = null;
		if (!empty($validResult) && !empty($maxResult)) {
			if ($validResult->id == $maxResult->max_id)
				$result = $validResult;
		}

		return $result;
	}
}
