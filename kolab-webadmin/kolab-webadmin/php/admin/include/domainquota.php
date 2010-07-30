<?php
/*
 * Copyright (c) 2008 TBits.net GmbH
 *
 *    Written by Martin Zapfl <mz@tbits.net>
 *
 *  This  program is free  software; you can redistribute  it and/or
 *  modify it  under the terms of the GNU  General Public License as
 *  published by the  Free Software Foundation; either version 2, or
 *  (at your option) any later version.
 *
 *  This program is  distributed in the hope that it will be useful,
 *  but WITHOUT  ANY WARRANTY; without even the  implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 *  You can view the  GNU General Public License, online, at the GNU
 *  Project's homepage; see <http://www.gnu.org/licenses/gpl.html>.
 */

// Get attribute for max. no. of accounts for a domain.
function getMaxAccounts($domain){
  global $ldap;
  if ($ldap->search( "cn=".$domain.",cn=domains,cn=internal,".$_SESSION['base_dn'],"(objectClass=kolabGroupOfNames)",array("maxAccounts"))){
    $maxaccounts = $ldap->getEntries();
    if(is_array($maxaccounts)) return $maxaccounts[0]["maxaccounts"][0];
    else return $maxaccounts;
  } else return false;
}

// Count No. of accounts for a domain
function countAccounts($domain, $excluded_accounts=""){
  global $ldap;
  if ("@".$domain == $excluded_accounts) $excluded_accounts = ""; // Avoid search match exclude pattern
  if(is_array($excluded_accounts)){
    $exclude_filter="(!";
    foreach($excluded_accounts as $exclude_address){
     $exclude_filter.="(mail=".$exclude_address.")";
    }
    $exclude_filter.=")";
  } elseif ($excluded_accounts!="") $exclude_filter = "(!(mail=".$excluded_accounts."))";
  if ($ldap->search( $_SESSION['base_dn'], "(&(objectClass=kolabInetOrgPerson)(mail=*".$domain.")".$exclude_filter.")", array("mail") )){
    $accounts = $ldap->getEntries();
    return $accounts["count"];
  } else return false;
}

// Get domain quota space in use
function getDomainQuotaInUse($domain){
  global $ldap;
  // Do not count userquota for current user
  if (isset($_POST["user_mail"]) && isset($_POST["domain_mail"])){
    $exclude_filter="(!(mail=".trim(strtolower($_POST["user_mail"]))."@".trim(strtolower($_POST["domain_mail"]))."))";
  }
  if ($ldap->search( $_SESSION['base_dn'], "(&(objectClass=kolabInetOrgPerson)(mail=*@".$domain.")".$exclude_filter.")",array("cyrus-userquota"))){
    foreach($ldap->getEntries()as $v){
      if(isset($v["cyrus-userquota" ])) $quotainuse =  $quotainuse + $v["cyrus-userquota"][0];
    }
    return $quotainuse;
  } else return false;
}

// Get attribute for max. no. of accounts for a domain.
function getDomainQuotas($domain){
  global $ldap;
  if ($ldap->search( "cn=".$domain.",cn=domains,cn=internal,".$_SESSION['base_dn'],"(objectClass=kolabGroupOfNames)",array("domainDefaultQuota","domainQuota"))){
    foreach ($ldap->getEntries() as $v){
      if(is_array($v)){
        if(in_array('domainquota',$v,true)) $quota["domainquota"] = $v["domainquota"][0];
        if(in_array("domaindefaultquota",$v,true)) $quota["domaindefaultquota"] = $v["domaindefaultquota"][0];
      }
    }
    if (isset( $quota["domainquota"])) $quota["quotainuse"] = getDomainQuotaInUse($domain);
    return $quota;
  } else return false;
}

function getCustomerQuotaUsed($customer) {
	global $ldap;
	$domains = $ldap->domainsOfCustomer($customer);
	if(!is_array($domains))
		return $domains;
	$used = 0;
	foreach($domains as $domain)
		$used += getDomainQuotaInUse($domain);
	return $used;
}

function getUserQuotaByDN($user) {
	global $ldap;
	$attrs = $ldap->read($user);
	if(!$attrs)
		return 0;
	$quota = $attrs['cyrus-userquota'][0];
	return $quota ? $quota : 0;
}

?>
