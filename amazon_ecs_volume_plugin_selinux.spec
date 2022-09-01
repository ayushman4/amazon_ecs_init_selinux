# vim: sw=4:ts=4:et


%define relabel_files() \
restorecon -R /usr/libexec/amazon-ecs-volume-plugin; \
restorecon -R /var/cache/ecs/state; \
restorecon -R /var/cache/ecs/ecs-agent-v1.62.2.tar; \
restorecon -R /usr/lib/systemd/system/amazon-ecs-volume-plugin.socket; \
restorecon -R /usr/lib/systemd/system/amazon-ecs-volume-plugin.service; \
restorecon -R /usr/lib/systemd/system/ecs.service; \
restorecon -R /var/cache/ecs/ecs-agent.tar; \
restorecon -R /var/lib/ecs/data; \

%define selinux_policyver 3.13.1-268

Name:   amazon_ecs_volume_plugin_selinux
Version:	1.0
Release:	1%{?dist}
Summary:	SELinux policy module for amazon_ecs_volume_plugin

Group:	System Environment/Base		
License:	GPLv2+	
# This is an example. You will need to change it.
URL:		https://github.com/ayushman4/amazon_ecs_volume_plugin_selinux
Source0:	amazon_ecs_volume_plugin.pp
Source1:	amazon_ecs_volume_plugin.if
Source2:	amazon_ecs_volume_plugin_selinux.8


Requires: policycoreutils, libselinux-utils
Requires(post): selinux-policy-base >= %{selinux_policyver}, policycoreutils
Requires(postun): policycoreutils
Requires(post): ecs-init
BuildArch: noarch

%description
This package installs and sets up the  SELinux policy security module for amazon_ecs_volume_plugin.

%install
install -d %{buildroot}%{_datadir}/selinux/packages
install -m 644 %{SOURCE0} %{buildroot}%{_datadir}/selinux/packages
install -d %{buildroot}%{_datadir}/selinux/devel/include/contrib
install -m 644 %{SOURCE1} %{buildroot}%{_datadir}/selinux/devel/include/contrib/
install -d %{buildroot}%{_mandir}/man8/
install -m 644 %{SOURCE2} %{buildroot}%{_mandir}/man8/amazon_ecs_volume_plugin_selinux.8
install -d %{buildroot}/etc/selinux/targeted/contexts/users/


%post
semodule -n -i %{_datadir}/selinux/packages/amazon_ecs_volume_plugin.pp
if /usr/sbin/selinuxenabled ; then
    /usr/sbin/load_policy
    %relabel_files

fi;
exit 0

%postun
if [ $1 -eq 0 ]; then
    semodule -n -r amazon_ecs_volume_plugin
    if /usr/sbin/selinuxenabled ; then
       /usr/sbin/load_policy
       %relabel_files

    fi;
fi;
exit 0

%files
%attr(0600,root,root) %{_datadir}/selinux/packages/amazon_ecs_volume_plugin.pp
%{_datadir}/selinux/devel/include/contrib/amazon_ecs_volume_plugin.if
%{_mandir}/man8/amazon_ecs_volume_plugin_selinux.8.*


%changelog
* Thu Sep  1 2022 Ayushman Dutta ayushman999@gmail.com 1.0-1
- Initial version

