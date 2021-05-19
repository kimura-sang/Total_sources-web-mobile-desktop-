<?php


class AdminLogin extends BaseController
{
    public function __construct()
    {
        parent::__construct();

        $this->load->model('backend/LoginModel');
    }

    public function index(){
        $this->load->view('backend/adminlogin/index');
    }

    public function tryLogin(){
        $email = $this->input->post('email');
        $password = $this->input->post('password');

        if ($this->isIncludeSpaceCharacter($email) || $this->isIncludeSpaceCharacter($password))
            echo 0;
        else {
            $admins = $this->LoginModel->getMember($email, $password);

            if ($admins) {
                $sessionArray = array(
                	"adminId" => $admins->id,
                    "adminEmail" => $admins->email
                );

                $this->session->set_userdata($sessionArray);

                echo 1;
            }
            else
                echo 2;
        }
    }

}
