<?php

// user full name for From: line
// If you lock this preference, you must specify a value or a hook for it in
// horde/config/hooks.php.
$_prefs['fullname'] = array(
    'value' => '',
    'locked' => false,
    'shared' => true,
    'hook' => true,
    'type' => 'text',
    'desc' => _("Your full name:")
);

// user preferred email address for From: line
// If you lock this preference, you must specify a value or a hook for it in
// horde/config/hooks.php.
$_prefs['from_addr'] = array(
    'value' => '',
    'locked' => false,
    'shared' => true,
    'hook' => true,
    'type' => 'text',
    'desc' =>  _("Your From: address:")
);

// UI theme
$_prefs['theme'] = array(
    'value' => 'silver',
    'locked' => false,
    'shared' => true,
    'type' => 'select',
    'desc' => _("Select your color scheme.")
);