<?php

$servers = array();

if (isset($_SESSION['imp']['user']) && isset($_SESSION['imp']['pass'])) {
    require_once 'Horde/Kolab/Session.php';
    $session = Horde_Kolab_Session::singleton($_SESSION['imp']['user'],
                                              array('password' => Secret::read(Secret::getKey('imp'), $_SESSION['imp']['pass'])));
    $imapParams = $session->getImapParams();
    if (is_a($imapParams, 'PEAR_Error')) {
        $useDefaults = true;
    } else {
        $useDefaults = false;
    }
    $_SESSION['imp']['uniquser'] = $session->user_mail;
 } else {
    $useDefaults = true;
 }


$servers['kolab'] = array(
    'name'       => 'Kolab Cyrus IMAP Server',
    'hordeauth'  => 'full',
    'server'     => 'localhost',
    'port'       => 143,
    'protocol'   => 'imap',
    'maildomain' => $GLOBALS['conf']['kolab']['imap']['maildomain'],
    'realm'      => '',
    'preferred'  => '',
    'quota'      => array(
        'driver' => 'imap',
        'params' => array('hide_quota_when_unlimited' => true),
    ),
    'acl'        => array(
        'driver' => 'rfc2086',
    ),
    'login_tries' => 1,
);
