<html>
	<body>
		<h1>Kolab ISP Extensions</h1>
		<p>The Kolab extensions by
		<a href="http://www.tbits.net/" target="_blank">TBits.net</a>
		are available via
		<a href="http://www.git-scm.com/" target="_blank">Git</a> at</p>
		<blockquote><code>
			git@github.com:tpokorra/kolab2-isppatches.git<br/>
			(mirrored once from: git://twerp.unclesniper.org/tbits-kolab)
		</code></blockquote>
		<p>Currently</p>
		<ul>
			<li>
				based on HEAD 20100730<br />
			</li>
			<li>tested against HEAD 20100429</li>
		</ul>
		<p>The following branches are served:</p>
		<table>
			<thead>
				<tr>
					<th style="width: 250px;">branch name</th>
					<th>purpose</th>
					<th style="width: 200px;">pulls from</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/master_cvs">master_cvs</a></code></td>
					<td>
						track pesudo-origin; would-be identical
						to HEAD from <code>cvs.kolab.org</code>
					</td>
					<td>Kolab CVS</th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/tbits-base">tbits-base</a></code></td>
					<td>
						base of all feature branches, used to
						defer pulling changes from CVS
					</td>
					<td><code>master</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/ldap-schema">ldap-schema</a></code></td>
					<td>
						prepare LDAP schema for extensions<br />
						all branches modifying <code>kolab2.schema</code>
						pull from <code>ldap-schema</code>
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/domain-defaults">domain-defaults</a></code></td>
					<td>
						intermediate branch to ease merging<br />
						will be used by us; very likely not by you
					</td>
					<td><code>ldap-schema<br />domain-settings</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/domain-settings">domain-settings</a></code></td>
					<td>
						intermediate branch to ease merging<br />
						will be used by us; very likely not by you
					</td>
					<td><code>ldap-schema</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/account-limit-per-domain">account-limit-per-domain</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						limit number of e-mail accounts that can be created
						for a domain
					</td>
					<td><code>ldap-schema<br />domain-defaults</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/customers">customers</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						domains owned by &quot;customers&quot;, can be used
						to organize domain, users, etc.<br />
						entities owned by different customers will be
						separated in LDAP, appropriate permissions will be
						used and somesuch
					</td>
					<td><code>ldap-schema<br />domain-settings<br />monolithic-ldap-acl</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/disable-groupware-per-customer">disable-groupware-per-customer</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						disable groupware functionality for specific
						customers
					</td>
					<td><code>customers</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/home-server-per-customer">home-server-per-customer</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						set default Kolab home server for a customer
					</td>
					<td><code>customers</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/mail-alias-must-match-customer">mail-alias-must-match-customer</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						prevent customers from creating mail aliases
						within domains they do not own
					</td>
					<td><code>customers</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/mail-quota-per-customer">mail-quota-per-customer</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						set mail quota for specific customers,
						applying across all their domains
					</td>
					<td><code>customers</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/uid-prefix-per-customer">uid-prefix-per-customer</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						set a string for a customer which will be
						used as a prefix for the UIDs of their
						users
					</td>
					<td><code>customers</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/domain-default-quota">domain-default-quota</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						domains have a quota and a &quot;default
						quota&quot; dividing the quota into per-user
						segments
					</td>
					<td><code>ldap-schema<br />domain-defaults</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/settings-per-kolabhost">settings-per-kolabhost</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						framework is able to store settings for
						specific Kolab hosts<br />
						this is an abstract branch, use one of
						its children to see an effect
					</td>
					<td><code>ldap-schema</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/relayhost-per-kolabhost">relayhost-per-kolabhost</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						configure a separate relay host for specific
						Kolab hosts
					</td>
					<td><code>settings-per-kolabhost</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/password-security-regex">password-security-regex</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						passwords must match specified regular
						expression to be considered secure
					</td>
					<td><code>ldap-schema</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/deny-login-by-mail">deny-login-by-mail</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						admin can force users to log in using
						their UID instead of mail address
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/firefox-display-fixes">firefox-display-fixes</a></code></td>
					<td>
						<span class="bo">fix:</span><br />
						fix page display in Firefox<br />
						may break display in other browsers, double-check before merging
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/german-language-fixes">german-language-fixes</a></code></td>
					<td>
						<span class="bo">fix:</span><br />
						adjusted some outright ridiculous messages
						in the German .po file
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/hide-admin-mail-settings">hide-admin-mail-settings</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						may hide section &quot;administrative email
						addresses&quot; in settings
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/show-forward-in-user-list">show-forward-in-user-list</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						show aliases and currently active
						forwarding rules in user list
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/show-last-login">show-last-login</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						show last login time of users in user list<br />
						requires external program to update LDAP accordingly
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/show-quota-in-user-list">show-quota-in-user-list</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						show user quota and usage thereof in
						user list
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/sorting">sorting</a></code></td>
					<td>
						<span class="bo">feature:</span><br />
						sort a couple of things alphabetically
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/misc-fixes">misc-fixes</a></code></td>
					<td>
						<span class="bo">fix:</span><br />
						various logic/spelling fixes
					</td>
					<td><code>tbits-base</code></th>
				</tr>
				<tr>
					<td><code><a href="https://github.com/tpokorra/kolab2-isppatches/tree/monolithic-ldap-acl">monolithic-ldap-acl</a></code></td>
					<td>
						<span class="bo">fix:</span><br />
						fixes issue mentioned in message
						<code>20100521112809.20847d7ohpsbu8kc@kolab.tbits.net</code>
						on <code>kolab-devel</code> mailing list<br />
						merged into <code>customers</code> since we need this
						fixed for testing
					</td>
					<td><code>tbits-base</code></th>
				</tr>
			</tbody>
		</table>
		<p><span class="bo">Note:</span> When merging the
		<code>mail-quota-per-customer</code> and
		<code>domain-default-quota</code> branches together,
		additional quota logic will be in order, we might
		create a separate branch if this is desired.</p>
		<p><span class="bo">Note:</span> The <code>CVS</code>
		directories in the repository still refer to
		20100429, even though the base has been updated to
		20100730.</p>
	</body>
</html>
