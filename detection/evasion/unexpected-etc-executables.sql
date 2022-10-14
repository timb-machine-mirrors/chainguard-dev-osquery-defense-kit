-- Find unexpected executables in /etc
--
-- references:
--   * https://blog.lumen.com/chaos-is-a-go-based-swiss-army-knife-of-malware/
--
-- tags: persistent
-- platform: posix
SELECT
  file.path,
  file.directory,
  uid,
  gid,
  mode,
  file.mtime,
  file.size,
  hash.sha256,
  magic.data
FROM
  file
  LEFT JOIN hash on file.path = hash.path
  LEFT JOIN magic ON file.path = magic.path
WHERE
  (file.path LIKE '/etc/%%')
  AND file.type = 'regular'
  AND (
    file.mode LIKE '%7%'
    or file.mode LIKE '%5%'
    or file.mode LIKE '%1%'
  )
  AND file.directory NOT IN (
    '/etc/X11/xinit/xinitrc.d',
    '/etc/apcupsd',
    '/etc/menu-methods',
    '/etc/avahi',
    '/etc/chromium/native-messaging-hosts',
    '/etc/cifs-utils',
    '/etc/cron.hourly',
    '/etc/flatpak/remotes.d',
    '/etc/gdm/Init',
    '/etc/gdm/PostLogin',
    '/etc/gdm/PostSession',
    '/etc/gdm/PreSession',
    '/etc/gdm',
    '/etc/grub.d',
    '/etc/httpd/modules',
    '/etc/ifplugd',
    '/etc/init.d',
    '/etc/lightdm',
    '/etc/pinentry',
    '/etc/ppp',
    '/etc/ppp/ip-down.d',
    '/etc/ppp/ip-up.d',
    '/etc/ppp/ipv6-up.d',
    '/etc/profile.d',
    '/etc/rdnssd',
    '/etc/security',
    '/etc/skel',
    '/etc/ssl/misc',
    '/etc/systemd/system',
    '/etc/systemd/system/graphical.target.wants',
    '/etc/vpnc',
    '/etc/xdg/Xwayland-session.d',
    '/etc/NetworkManager/dispatcher.d',
    '/etc/X11',
    '/etc/X11/xinit',
    '/etc/acpi',
    '/etc/alternatives',
    '/etc/apm/resume.d',
    '/etc/apm/scripts.d',
    '/etc/apm/suspend.d',
    '/etc/brltty/Contraction',
    '/etc/console-setup',
    '/etc/cron.daily',
    '/etc/cron.monthly',
    '/etc/cron.weekly',
    '/etc/dhcp/dhclient-enter-hooks.d',
    '/etc/dhcp/dhclient-exit-hooks.d',
    '/etc/dkms',
    '/etc/gdm3/Init',
    '/etc/gdm3/PostLogin',
    '/etc/gdm3/PostSession',
    '/etc/gdm3/PreSession',
    '/etc/gdm3/Prime',
    '/etc/gdm3/PrimeOff',
    '/etc/gdm3',
    '/etc/ifplugd/action.d',
    '/etc/kernel/header_postinst.d',
    '/etc/kernel/install.d',
    '/etc/kernel/postinst.d',
    '/etc/kernel/postrm.d',
    '/etc/kernel/preinst.d',
    '/etc/kernel/prerm.d',
    '/etc/network/if-down.d',
    '/etc/network/if-post-down.d',
    '/etc/network/if-pre-up.d',
    '/etc/network/if-up.d',
    '/etc/openvpn',
    '/etc/pm/sleep.d',
    '/etc/rc0.d',
    '/etc/rc1.d',
    '/etc/rc2.d',
    '/etc/rc3.d',
    '/etc/rc4.d',
    '/etc/rc5.d',
    '/etc/rc6.d',
    '/etc/rcS.d',
    '/etc/update-motd.d',
    '/etc/wpa_supplicant',
    '/etc/zfs/zed.d',
    '/etc/zfs/zpool.d',
    '/etc/bash_completion.d',
    '/etc/dhcp/dhclient.d',
    '/etc/mcelog/triggers',
    '/etc/qemu-ga',
    '/etc/rc.d/init.d',
    '/etc/rc.d/rc0.d',
    '/etc/rc.d/rc1.d',
    '/etc/rc.d/rc2.d',
    '/etc/rc.d/rc3.d',
    '/etc/rc.d/rc4.d',
    '/etc/rc.d/rc5.d',
    '/etc/rc.d/rc6.d',
    '/etc/vmware-tools',
    '/etc/zfs-fuse',
    '/etc/ssl/certs',
    '/etc/ssl/trust-source',
    '/etc/systemd/system-shutdown'
  )
  AND file.path NOT IN (
    '/etc/nftables.conf',
    '/etc/rmt',
    '/etc/qemu-ifdown',
    '/etc/qemu-ifup',
    '/etc/opt/chrome/native-messaging-hosts/com.google.endpoint_verification.api_helper.json'
  )
