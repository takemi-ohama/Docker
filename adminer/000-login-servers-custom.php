<?php
require_once 'plugins/login-servers-custom.php';

return new AdminerLoginServers(json_decode($_ENV['ADMINER_JSON'], true));
