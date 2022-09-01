#!/bin/sh -e

DIRNAME=`dirname $0`
cd $DIRNAME
USAGE="$0 [ --update ]"
if [ `id -u` != 0 ]; then
echo 'You must be root to run this script'
exit 1
fi

if [ $# -eq 1 ]; then
	if [ "$1" = "--update" ] ; then
		time=`ls -l --time-style="+%x %X" amazon_ecs_volume_plugin.te | awk '{ printf "%s %s", $6, $7 }'`
		rules=`ausearch --start $time -m avc --raw -se amazon_ecs_volume_plugin`
		if [ x"$rules" != "x" ] ; then
			echo "Found avc's to update policy with"
			echo -e "$rules" | audit2allow -R
			echo "Do you want these changes added to policy [y/n]?"
			read ANS
			if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
				echo "Updating policy"
				echo -e "$rules" | audit2allow -R >> amazon_ecs_volume_plugin.te
				# Fall though and rebuild policy
			else
				exit 0
			fi
		else
			echo "No new avcs found"
			exit 0
		fi
	else
		echo -e $USAGE
		exit 1
	fi
elif [ $# -ge 2 ] ; then
	echo -e $USAGE
	exit 1
fi

echo "Building and Loading Policy"
set -x
make -f /usr/share/selinux/devel/Makefile amazon_ecs_volume_plugin.pp || exit
/usr/sbin/semodule -i amazon_ecs_volume_plugin.pp

# Generate a man page off the installed module
sepolicy manpage -p . -d amazon_ecs_volume_plugin_t
# Fixing the file context on /usr/libexec/amazon-ecs-volume-plugin
/sbin/restorecon -F -R -v /usr/libexec/amazon-ecs-volume-plugin
# Fixing the file context on /var/cache/ecs/state
/sbin/restorecon -F -R -v /var/cache/ecs/state
# Fixing the file context on /var/cache/ecs/ecs-agent-v1.62.2.tar
/sbin/restorecon -F -R -v /var/cache/ecs/ecs-agent-v1.62.2.tar
# Fixing the file context on /usr/lib/systemd/system/amazon-ecs-volume-plugin.socket
/sbin/restorecon -F -R -v /usr/lib/systemd/system/amazon-ecs-volume-plugin.socket
# Fixing the file context on /usr/lib/systemd/system/amazon-ecs-volume-plugin.service
/sbin/restorecon -F -R -v /usr/lib/systemd/system/amazon-ecs-volume-plugin.service
# Fixing the file context on /usr/lib/systemd/system/ecs.service
/sbin/restorecon -F -R -v /usr/lib/systemd/system/ecs.service
# Fixing the file context on /var/cache/ecs/ecs-agent.tar
/sbin/restorecon -F -R -v /var/cache/ecs/ecs-agent.tar
# Fixing the file context on /var/lib/ecs/data
/sbin/restorecon -F -R -v /var/lib/ecs/data
# Generate a rpm package for the newly generated policy

pwd=$(pwd)
rpmbuild --define "_sourcedir ${pwd}" --define "_specdir ${pwd}" --define "_builddir ${pwd}" --define "_srcrpmdir ${pwd}" --define "_rpmdir ${pwd}" --define "_buildrootdir ${pwd}/.build"  -ba amazon_ecs_volume_plugin_selinux.spec
