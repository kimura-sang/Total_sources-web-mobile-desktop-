<div class="page-header navbar">
    <div class="page-header-inner ">
        <div class="page-logo">
			<div class="logo-left" style="cursor: pointer;" onclick="pageMove('/dashboard/index');">
				<img src="<?=SERVER_ADDRESS ?>/include/img/logo_image_small.png" style="margin-top: 5px; margin-left: 20px;" alt="" />
			</div>
        </div>
        <a href="javascript:;" class="menu-toggler responsive-toggler" data-toggle="collapse" data-target=".navbar-collapse">
            <span></span>
        </a>

        <div class="top-menu">
            <ul class="nav navbar-nav pull-right">
                <li class="dropdown dropdown-user">
                    <a href="javascript:;" class="dropdown-toggle" data-toggle="dropdown" data-hover="dropdown" data-close-others="true">
                        <img alt="" class="img-circle" src="<?=SERVER_ADDRESS ?>/include/img/admin.png" />
                        <span class="username username-hide-on-mobile" style="margin-left: 10px;"><?= $this->session->email ?></span>
                        <i class="fa fa-angle-down" style="margin-left: 20px;"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-default">
						<li>
							<a href="/personal/index"><i class="icon-key"></i> Change Password </a>
						</li>
                        <li>
                            <a href="/flogin/signOut"><i class="icon-logout"></i> Sign Out </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</div>
