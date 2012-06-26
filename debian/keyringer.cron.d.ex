#
# Regular cron jobs for the keyringer package
#
0 4	* * *	root	[ -x /usr/bin/keyringer_maintenance ] && /usr/bin/keyringer_maintenance
