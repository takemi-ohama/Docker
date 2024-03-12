<?php
require_once 'plugins/login-servers-custom.php';

return new AdminerLoginServers([
                "carmo_db(dev)" => [
                        "server" => "carmo-cluster.cluster-ro-cgglzsqgnixi.ap-northeast-1.rds.amazonaws.com",
                        "driver" => "mysql",
                        "user" => "carmo",
                        "password" => "carmo4321"
                ],
                "carmo_analyst(dev)" => [
                        "server" => "carmo-cluster.cluster-ro-cgglzsqgnixi.ap-northeast-1.rds.amazonaws.com",
                        "driver" => "mysql",
                        "user" => "carmo_analyst",
                        "password" => "o7-m2vH@k7"
                ],
]);
