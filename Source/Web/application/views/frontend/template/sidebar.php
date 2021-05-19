<div class="page-sidebar-wrapper">
    <div class="page-sidebar navbar-collapse collapse">
        <ul class="page-sidebar-menu  page-header-fixed " data-keep-expanded="false" data-auto-scroll="true" data-slide-speed="200">
            <li class="nav-item start <? if ($this->router->fetch_class() == 'Dashboard') { ?>active<? } ?>" style="margin-top: 14px;">
                <a href="/dashboard/index" class="nav-link nav-toggle">
					<i class="icon-bag"></i>
                    <span class="title">Dashboard</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Shop') { ?>active<? } ?>">
                <a href="/shop/index" class="nav-link nav-toggle">
					<i class="icon-home"></i>
                    <span class="title">My shops</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Transaction') { ?>active<? } ?>">
                <a href="/transaction/index" class="nav-link nav-toggle">
                    <i class="icon-wallet"></i>
                    <span class="title">Transactions</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Customer') { ?>active<? } ?>">
                <a href="/customer/index" class="nav-link nav-toggle">
                    <i class="icon-user"></i>
                    <span class="title">Customers</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Staff') { ?>active<? } ?>">
                <a href="/staff/index" class="nav-link nav-toggle">
                    <i class="icon-user-following"></i>
                    <span class="title">Staff</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Offer') { ?>active<? } ?>">
                <a href="/offer/index" class="nav-link nav-toggle">
                    <i class="icon-support"></i>
                    <span class="title">Offers</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Report') { ?>active<? } ?>">
                <a href="/report/index?tab=<?= STR_REPORT_SALES ?>" class="nav-link nav-toggle">
                    <i class="icon-doc"></i>
                    <span class="title">Reports</span>
                    <span class="selected"></span>
                </a>
            </li>
            <li class="nav-item <? if ($this->router->fetch_class() == 'Setting') { ?>active<? } ?>">
                <a href="/setting/index" class="nav-link nav-toggle">
                    <i class="icon-settings"></i>
                    <span class="title">Settings</span>
                    <span class="selected"></span>
                </a>
            </li>
        </ul>
    </div>
</div>
