<?php

/** Display constant list of servers in login form
 * @link https://www.adminer.org/plugins/#use
 * @author Jakub Vrana, https://www.vrana.cz/
 * @license https://www.apache.org/licenses/LICENSE-2.0 Apache License, Version 2.0
 * @license https://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
 */
class AdminerLoginServers
{
        /** @access protected */
        var $servers = [];

        var $target = "";

        /** Set supported servers
         * @param array array($description => array("server" => , "driver" => "server|pgsql|sqlite|..."))
         */
        function __construct($servers)
        {
                $this->servers = $servers;
                #print_r($this->servers);
                //print_r(array_keys($this->servers));
                //print_r(optionlist(array_keys($this->servers)));
                //print_r(optionlist(["a" => "b"]));
                if ($_POST["auth"]) {
                        $this->target = $_POST["auth"]["server"];
                }
        }

        function credentials()
        {
                return array(
                        $this->servers[$this->target]["server"],
                        $this->servers[$this->target]['user'],
                        $this->servers[$this->target]['password']
                );
        }

        function login($login, $password)
        {
                if (!$this->servers[$this->target]) {
                        return false;
                }
                return true;
        }

        function loginFormField($name, $heading, $value)
        {
                if ($name == 'server') {
                        return $heading . "<select name='auth[server]'>" . optionlist(array_keys($this->servers), $this->target) . "</select>\n";
                } else {
                        return "";
                }
        }
}
