<?php

class LoginModel extends BaseModel
{
    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set('Asia/Shanghai');
    }

    function getMember($email, $password = null)
    {
        $sql = "select a.* from admin as a ";

        $sql .= " where a.email = '$email'";
        if ($password != null)
            $sql .= " and a.password = '$password'";

        $result = $this->db->query($sql);

        return $result->row();
    }
}
