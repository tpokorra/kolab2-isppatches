<?php
/*
 (c) 2008 TBits.net GmbH
 (c) 2008 Martin Zapfl <mz@tbits.net>
 This program is Free Software under the GNU General Public License (>=v2).
 Read the file COPYING that comes with this packages for details.
*/

// List all customers
// Show "no customer" by defalt
function getCustomerList($add_choose = true, $customer_id = ""){
  global $ldap;
  if ( $add_choose ) $item_count = 1;
  else $item_count = 0;
  $array_count = 0;
  if ($add_choose) $customer[] = _("No customer");
  // Output a sorted customer field
  $result = $ldap->search( "cn=customers,cn=internal,".$_SESSION['base_dn'],"(objectClass=kolabGroupOfNames)",array("cn","description"));
  ldap_sort($ldap->connection,$result,'description');
  if($result){
    foreach ($ldap->getEntries() as $v){
      if(is_array($v)){
			  if ($customer_id != "" && $item_count == $customer_id && $v["cn"][0] != "" ) { 
				  return $v["cn"][0];
				}	
       $customer[] = $v["description"][0];
       $item_count++;
      }
    }
    return $customer_id ? false : $customer;
  } else return $customer;
}

// Return list of (Customer CN,
// Customer Description) pairs
// for given optional maintainer
function getNamedCustomerList($maintainer = '') {
	global $ldap;
	$cns = array();
	$descriptions = array();
	$filter = '(objectClass=kolabGroupOfNames)';
	if($maintainer != '')
		$filter = "(&$filter(member=" . $ldap->escape($maintainer) . '))';
	$result = $ldap->search('cn=customers,cn=internal,' . $_SESSION['base_dn'],
		$filter, array('cn', 'description'));
	if($result) {
		ldap_sort($ldap->connection, $result, 'description');
		foreach($ldap->getEntries() as $entry) {
			$cn = $entry['cn'];
			if($cn == '')
				continue;
			$cns[] = is_array($cn) ? $cn[0] : $cn;
			$desc = $entry['description'];
			$descriptions[] = is_array($desc) ? $desc[0] : $desc;
		}
	}
	return array('cns' => $cns, 'descriptions' => $descriptions);
}

// Get customer description for a customer dn
function customerDnToDescription($customer_dn){
  global $ldap;
  if (!preg_match("/".$_SESSION['base_dn']."/", $customer_dn)) $customer_dn .= ",cn=customers,cn=internal,".$_SESSION['base_dn'];
  $result = $ldap->search( $customer_dn,"(description=*)", array("description") );
  $entry = $ldap->getEntries();
  return ($entry[0]['description'][0])?$entry[0]['description'][0]:_("No customer");
}

// Get customer description for a member
function memberToCustomerDescription($member_dn){
  global $ldap;
  $result = $ldap->search( "cn=customers,cn=internal,".$_SESSION['base_dn'],"(member=".$member_dn.")", array("description") );
  $entry = $ldap->getEntries();
  return ($entry[0]['description'][0])?$entry[0]['description'][0]:_("No customer");
}

// Get UID Prefix for a customer dn
function getPrefixForCustomer($customer_dn){
    global $ldap;
    $res = ldap_read( $ldap->connection, $customer_dn,
					  '(objectclass=*)',
					  array( 'uidPrefix' ) );
	if( $res ) {
	  $entries = ldap_get_entries( $ldap->connection, $res );
	  ldap_free_result( $res );
	  if( $entries['count'] == 1 ) {
		return $entries[0]['uidprefix'][0];
	  } else {
		return false;
	  }
	} else {
	  return false;
	}
    return false;	
}

// Get customer dn for select field id
// this function is stupid and should be superfluous, but i dare not remove it  -- simon
function getCustomerDnFromId($id){
	$id = trim($id);
	if(is_numeric($id) && $id > 0){
		$customer_tree = getCustomerList(true, $id);
		return $customer_tree ? "cn=$customer_tree,".$_SESSION['base_dn'] : false;
	} else return $_SESSION['base_dn'];
}

// Get customer ID from a dn
// this function is stupid and should be superfluous, but i dare not remove it  -- simon
function getCustomerIdFromDn($dn){
	global $ldap;
	preg_match("/cn=([a-zA-Z0-9]+),".$_SESSION["base_dn"]."$/",$dn,$matches);
	$customer_cn = $matches[count($matches)-1];
	$result = $ldap->search( "cn=customers,cn=internal,".$_SESSION['base_dn'],"(cn=".$customer_cn.")", array("description") );
	$entry = $ldap->getEntries();
	if ($entry["count"] > 0){
		$customer_desc = $entry[0]["description"][0];
		foreach(getCustomerList(true) as $id => $customer){
			if ($customer_desc == $customer) return $id;
		}
	} else {
		return "0";
	}
}

function arrayInsideOut($a) {
	$b = array();
	foreach($a as $row_key => $row)
		foreach($row as $col_key => $col)
			if(!isset($b[$col_key]))
				$b[$col_key] = array($row_key => $col);
			else
				$b[$col_key][$row_key] = $col;
	return $b;
}

function getSelectedCustomerCN() {
	$base = $_SESSION['base_dn'];
	$cdn = $_SESSION['customer_dn'];
	if($base == $cdn)
		return '';
	return substr($cdn, 3, strlen($cdn) - strlen($base) - 4);
}

function removeDomainFromAllCustomers($domain) {
	global $ldap;
	$domain = canonicalizeEntity($domain, 'domains');
	$result = ldap_list($ldap->connection, 'cn=customers,cn=internal,'
			. $_SESSION['base_dn'],
			"(&(objectClass=kolabGroupOfNames)(domains=$domain))",
			array('cn'));
	if(!$result)
		return ldap_error($ldap->connection);
	$entry = ldap_first_entry($ldap->connection, $result);
	for(; $entry; $entry = ldap_next_entry($ldap->connection, $entry)) {
		$cn = ldap_get_values($ldap->connection, $entry, 'cn');
		$cn = $cn[0];
		if($error = removeDomainFromCustomer($domain, $cn)) {
			ldap_free_result($result);
			return $error;
		}
	}
	ldap_free_result($result);
	return false;
}

function canonicalizeEntity($entity, $path) {
	$base = ',' . $_SESSION['base_dn'];
	$intern = ",cn=$path,cn=internal" . $base;
	if(strlen($entity) > strlen($intern) &&
			substr($entity, strlen($entity) - strlen($intern)) == $intern)
		$entity = substr($entity, 0, strlen($entity) - strlen($intern));
	else if(strlen($entity) > strlen($base) &&
			substr($entity, strlen($entity) - strlen($base)) == $base)
		$entity = substr($entity, 0, strlen($entity) - strlen($base));
	if(strlen($entity) > 3 && substr($entity, 0, 3) == 'cn=')
		$entity = substr($entity, 3);
	return $entity;
}

function removeDomainFromCustomer($domain, $customer, $add = false) {
	global $ldap;
	$domain = canonicalizeEntity($domain, 'domains');
	$customer = canonicalizeEntity($customer, 'customers');
	if(!strlen($customer))
		return;
	$base = $_SESSION['base_dn'];
	$result = ldap_read($ldap->connection,
			"cn=$customer,cn=customers,cn=internal,$base",
			'(objectClass=kolabGroupOfNames)');
	if(!$result)
		return ldap_error($ldap->connection);
	$entry = ldap_get_entries($ldap->connection, $result);
	if(!$entry) {
		ldap_free_result($result);
		return ldap_error($ldap->connection);
	}
	ldap_free_result($result);
	$entry = $entry[0];
	$dn = $entry['dn'];
	unset($entry['dn']);
	$count = $entry['count'];
	unset($entry['count']);
	for($i = 0; $i < $count; ++$i)
		unset($entry[$i]);
	foreach($entry as $key => $value)
		unset($entry[$key]['count']);
	if(!isset($entry['domains']))
		$domains = array();
	else
		$domains = $entry['domains'];
	if($add)
		if(in_array($domain, $domains))
			return false;
		else
			$domains[] = $domain;
	else
		if(($index = array_search($domain, $domains)) === FALSE)
			return false;
		else
			unset($domains[$index]);
	$entry['domains'] = array_values($domains);
	if(ldap_modify($ldap->connection, $dn, $entry) === FALSE)
		return ldap_error($ldap->connection);
	return false;
}

function addDomainToCustomer($domain, $customer) {
	return removeDomainFromCustomer($domain, $customer, true);
}

function setDomainOwner($domain, $customer) {
	if($error = removeDomainFromAllCustomers($domain))
		return $error;
	return addDomainToCustomer($domain, $customer);
}

function findCustomerInSessionArrayByCN($cn) {
	$idx = 0;
	$dn = "cn=$cn," . $_SESSION['base_dn'];
	foreach($_SESSION['customer_dn_options'] as $option)
		if($option['dn'] == $dn)
			return $idx;
		else
			++$idx;
	return -1;
}

function adjustSessionForCustomerUpdate($customer, $action, $descr = null, $server = null, $nogroup = false) {
	$cdn = "cn=$customer," . $_SESSION['base_dn'];
	switch($action) {
		case 'added':
			$info = array(
				'dn' => $cdn,
				'descr' => $descr,
				'subtree' => "cn=$customer,cn=customers,cn=internal,"
						. $_SESSION['base_dn'],
				'nogroupware' => $nogroup ? 'TRUE' : 'FALSE',
				'ignore' => 0,
			);
			$_SESSION['customer_dn_options'][] = $info;
			sortCustomerList();
			break;
		case 'removed':
			$index = findCustomerInSessionArrayByCN($customer);
			if($index == -1)
				break;
			$data = $_SESSION['customer_dn_options'];
			unset($data[$index]);
			$_SESSION['customer_dn_options'] = array_values($data);
			if($_SESSION['customer_dn'] == $cdn)
				switchToCustomer(0);
			break;
		case 'modified':
			$index = findCustomerInSessionArrayByCN($customer);
			if($index == -1)
				break;
			$_SESSION['customer_dn_options'][$index]['descr'] = $descr;
			$_SESSION['customer_dn_options'][$index]['nogroupware'] = $nogroup ? 'TRUE' : 'FALSE';
			break;
	}
}

function getCurrentCustomerQuota() {
	$customer = getSelectedCustomerCN();
	if(!$customer)
		return 0;
	return getCustomerQuota($customer);
}

function getCustomerQuota($customer) {
	global $ldap;
	if(!$customer)
		return 0;
	$dn = "cn=$customer,cn=customers,cn=internal," . $_SESSION['base_dn'];
	$attr = $ldap->read($dn);
	if(!$attr)
		return 0;
	$quota = $attr['customerQuota'][0];
	return $quota ? $quota : 0;
}

function getCustomerUsedDomainQuota($customer) {
	global $ldap;
	if(!$customer)
		return 0;
	$domains = $ldap->domainsOfCustomer($customer);
	$used = 0;
	foreach($domains as $domain)
		$used += getCustomerUsedDomainQuotaByDomain($domain);
	return $used;
}

function getCustomerUsedDomainQuotaByDomain($domain) {
	$quotas = getDomainQuotas($domain);
	$dquota = $quotas ? $quotas['domainquota'] : 0;
	if($dquota)
		return $dquota;
	return getDomainQuotaInUse($domain);
}

function getValidAliasDomainsForUser($user_dn) {
	global $ldap;
	$base_dn = $_SESSION['base_dn'];
	$tree = ldap_explode_dn($user_dn, 0);
	unset($tree['count']);
	array_shift($tree);
	$base_tree = ldap_explode_dn($base_dn, 0);
	unset($base_tree['count']);
	if(count($tree) == count($base_tree))
		return $ldap->domainsOfNoCustomer();
	$customer = substr(array_shift($tree), 3);
	return $ldap->domainsOfCustomer($customer);
}

?>
