<?php
/* -------------------------------------------------------------------
   Copyright (c) 2004 Klaraelvdalens Datakonsult AB
   Copyright (C) 2007 by Intevation GmbH
   Author(s):
   Sascha Wilde <wilde@intevation.de>
   Steffen Hansen <steffen@klaralvdalens-datakonsult.se>

   This program is free software under the GNU GPL (>=v2)
   Read the file COPYING coming with the software for details.
   ------------------------------------------------------------------- */

// Generate OpenLDAP style SSHA password strings
function ssha($string, $salt)
{
  return "{SSHA}" . base64_encode(pack("H*", sha1($string . $salt)) . $salt);
}

// return 4 random bytes
function gensalt()
{
  $salt = '';
  while (strlen($salt) < 4)
    $salt = $salt . chr(mt_rand(0,255));
  return $salt;
}

// get regex for password validation
function pwSecRegEx($dn) {
	global $ldap;
	global $dn; // i'm pretty sure that's nonsense...  -- simon
	if(preg_match("/cn=internal," . $_SESSION['base_dn'] . "/", $dn))
		$attrs = array('passwordSecAdminRegEx');
	else
		$attrs = array('passwordSecUserRegEx');
	if($ldap->search("k=kolab,".$_SESSION['base_dn'],
			'(objectclass=kolab)', $attrs)) {
		$entry = $ldap->getEntries();
		return $entry[0][strtolower(end($attrs))][0];
	}
	else
		return false;
}

// Check that passwords from form input match
function checkpw( $form, $key, $value ) {
  global $action;
  $passwordRegEx = pwSecRegEx();
  if( $action == 'firstsave' ) {
    if( $key == 'password_0' ) {
      if( $value == '' ) return _('Password is empty');
	  elseif(!preg_match($passwordRegEx, $value)
			&& $key == 'password_0' && !empty($passwordRegEx))
		return _('Password does not meet password policy requirements');
    } else if( $key == 'password_1' ) {
      if( $value != $_POST['password_0'] ) {
        return _('Passwords dont match');
      }
    }
  } else {
    if( $value != $_POST['password_0'] ) {
      return _('Passwords dont match');
    }
	elseif($passwordRegEx && $key == 'password_0' && !empty($value)) {
		if(!preg_match("$passwordRegEx", $value))
			return _('Password does not meet security policy requirements');
	}
  }
  return '';
}

?>
