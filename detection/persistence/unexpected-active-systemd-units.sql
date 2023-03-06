-- Unexpected systemd units, may be evidence of persistence
--
-- references:
--   * https://attack.mitre.org/techniques/T1543/002/ (Create or Modify System Process: Systemd Service)
--
-- false positives:
--   * System updates
--
-- tags: persistent seldom filesystem systemd
-- platform: linux
SELECT --  description AS 'desc',
  fragment_path AS path,
  MAX(user, "root") AS effective_user,
  following,
  hash.sha256,
  file.ctime,
  file.size,
  CONCAT (
    id,
    ',',
    description,
    ',',
    user,
    ',',
    (file.size / 225) * 225
  ) AS exception_key
FROM
  systemd_units
  LEFT JOIN hash ON systemd_units.fragment_path = hash.path
  LEFT JOIN file ON systemd_units.fragment_path = file.path
WHERE
  active_state != 'inactive'
  AND sub_state != 'plugged'
  AND sub_state != 'mounted'
  AND fragment_path != ''
  AND NOT (
    (
      -- Only allow fragment paths in known good directories
      fragment_path LIKE '/lib/systemd/system/%'
      OR fragment_path LIKE '/usr/lib/systemd/system/%'
      OR fragment_path LIKE '/etc/systemd/system/%'
      OR fragment_path LIKE '/run/systemd/generator/%'
      OR fragment_path LIKE '/run/systemd/generator.late/%.service'
      OR fragment_path LIKE '/run/systemd/transient/%'
    )
    AND (
      exception_key IN (
        'abrtd.service,ABRT Automated Bug Reporting Tool,,450',
        'abrt-journal-core.service,Creates ABRT problems from coredumpctl messages,,225',
        'abrt-oops.service,ABRT kernel log watcher,,225',
        'abrt-xorg.service,ABRT Xorg log watcher,,225',
        'accounts-daemon.service,Accounts Service,,1800',
        'accounts-daemon.service,Accounts Service,,675',
        'gitsign.service,Keyless Git signing with Sigstore!,,900',
        'supergfxd.service,SUPERGFX,,450',
        'acpid.path,ACPI Events Check,,0',
        'acpid.service,ACPI Daemon,,1125',
        'acpid.service,ACPI event daemon,,225',
        'acpid.socket,ACPID Listen Socket,,0',
        'akmods-keygen.target,akmods-keygen.target,,0',
        'akmods.service,Builds and install new kmods from akmod packages,,225',
        'alsa-restore.service,Save/Restore Sound Card State,,225',
        'alsa-restore.service,Save/Restore Sound Card State,,450',
        'alsa-state.service,Manage Sound Card State (restore and store),,450',
        'alsa-store.service,Store Sound Card State,,1125',
        'anacron.service,Run anacron jobs,,675',
        'anacron.timer,Trigger anacron every hour,,0',
        'apcupsd.service,APC UPS Power Control Daemon for Linux,,225',
        'apparmor.service,Load AppArmor profiles,,1125',
        'apport-autoreport.path,Process error reports when automatic reporting is enabled (file watch),,0',
        'apport-autoreport.timer,Process error reports when automatic reporting is enabled (timer based),,0',
        'apport.service,LSB: automatic crash report generation,,450',
        'apt-daily.service,Daily apt download activities,,225',
        'apt-daily.timer,Daily apt download activities,,0',
        'apt-daily-upgrade.timer,Daily apt upgrade and clean activities,,0',
        'archlinux-keyring-wkd-sync.service,Refresh existing keys of archlinux-keyring,,1000',
        'archlinux-keyring-wkd-sync.service,Refresh existing keys of archlinux-keyring,,900',
        'archlinux-keyring-wkd-sync.timer,Refresh existing PGP keys of archlinux-keyring regularly,,0',
        'atd.service,Deferred execution scheduler,,225',
        'auditd.service,Security Auditing Service,,1575',
        'audit.service,Kernel Auditing,,1125',
        'avahi-daemon.service,Avahi mDNS/DNS-SD Stack,,900',
        'avahi-daemon.socket,Avahi mDNS/DNS-SD Stack Activation Socket,,675',
        'basic.target,Basic System,,900',
        'binfmt-support.service,Enable support for additional executable binary formats,,1125',
        'blk-availability.service,Availability of block devices,,225',
        "blockdev@dev-mapper-cryptdata.target,Block Device Preparation for /dev/mapper/cryptdata,,225",
        'blockdev@dev-mapper-cryptoswap.target,Block Device Preparation for /dev/mapper/cryptoswap,,225',
        "blockdev@dev-mapper-cryptswap.target,Block Device Preparation for /dev/mapper/cryptswap,,225",
        'bluetooth.service,Bluetooth service,,675',
        'bluetooth.target,Bluetooth Support,,225',
        'bolt.service,Thunderbolt system service,,450',
        'chronyd.service,NTP client/server,,1350',
        "chrony.service,chrony, an NTP client/server,,1575",
        'chrony.service,chrony, an NTP client/server,,450',
        'cloud-config.service,Apply the settings specified in cloud-config,,225',
        'cloud-config.target,Cloud-config availability,,450',
        'cloud-config.target,Cloud-config availability,,675',
        'cloud-final.service,Execute cloud user/final scripts,,450',
        'cloud-init-hotplugd.socket,cloud-init hotplug hook socket,,225',
        'cloud-init-local.service,Initial cloud-init job (pre-networking),,450',
        'cloud-init.service,Initial cloud-init job (metadata service crawler),,450',
        'cloud-init.service,Initial cloud-init job (metadata service crawler),,675',
        'cloud-init.target,Cloud-init target,,225',
        'cloud-init.target,Cloud-init target,,450',
        'colord.service,Manage, Install and Generate Color Profiles,colord,225',
        "com.system76.PowerDaemon.service,System76 Power Daemon,,225",
        "com.system76.Scheduler.service,Automatically configure CPU scheduler for responsiveness on AC,,225",
        'console-setup.service,Set console font and keymap,,225',
        'containerd.service,containerd container runtime,,1125',
        'crond.service,Command Scheduler,,225',
        'cronie.service,Periodic Command Scheduler,,0',
        'cron.service,Regular background program processing daemon,,225',
        'cryptsetup.target,Local Encrypted Volumes,,225',
        'cups-browsed.service,Make remote CUPS printers available locally,,225',
        'cups.path,CUPS Scheduler,,0',
        'cups.service,CUPS Scheduler,,225',
        'cups.socket,CUPS Scheduler,,0',
        "dbus-:1.2-org.pop_os.transition_system@0.service,dbus-:1.2-org.pop_os.transition_system@0.service,0,225",
        'dbus-broker.service,D-Bus System Message Bus,,450',
        'dbus.service,D-Bus System Message Bus,,225',
        'dbus.service,D-Bus System Message Bus,,450',
        'dbus.socket,D-Bus System Message Bus Socket,,0',
        'dhcpcd.service,DHCP Client,,1575',
        'display-manager.service,X11 Server,,1575',
        'dkms.service,Builds and install new kernel modules through DKMS,,225',
        'dm-event.socket,Device-mapper event daemon FIFOs,,0',
        'dm-event.socket,Device-mapper event daemon FIFOs,,225',
        'dnf-automatic-install.service,dnf automatic install updates,,225',
        'dnf-automatic-install.timer,dnf-automatic-install timer,,225',
        'dnf-makecache.service,dnf makecache,,225',
        'dnf-makecache.service,dnf makecache,,450',
        'dnf-makecache.timer,dnf makecache --timer,,225',
        'docker.service,Docker Application Container Engine,,1125',
        'docker.service,Docker Application Container Engine,,1350',
        'docker.service,Docker Application Container Engine,,1575',
        'docker.socket,Docker Socket for the API,,0',
        'docker.socket,Docker Socket for the API,,225',
        'dpkg-db-backup.timer,Daily dpkg database backup timer,,0',
        'dracut-shutdown.service,Restore /run/initramfs on shutdown,,225',
        'dracut-shutdown.service,Restore /run/initramfs on shutdown,,450',
        'e2scrub_all.timer,Periodic ext4 Online Metadata Check for All Filesystems,,225',
        "finalrd.service,Create final runtime dir for shutdown pivot root,,225",
        'firewalld.service,firewalld - dynamic firewall daemon,,450',
        'firewall.service,Firewall,,1350',
        'flatpak-system-helper.service,flatpak system helper,,225',
        'fprintd.service,Fingerprint Authentication Daemon,,900',
        'fprintd.service,Fingerprint Authentication Daemon,,675',
        'fstrim.service,Discard unused blocks on filesystems from /etc/fstab,,225',
        'fstrim.timer,Discard unused blocks once a week,,225',
        'fwupd-refresh.service,Refresh fwupd metadata and update motd,fwupd-refresh,225',
        'fwupd-refresh.timer,Refresh fwupd metadata regularly,,0',
        'fwupd.service,Firmware update daemon,,450',
        'gdm.service,GNOME Display Manager,,675',
        'gdm.service,GNOME Display Manager,,900',
        'geoclue.service,Location Lookup Service,geoclue,450',
        'getty-pre.target,Preparation for Logins,,450',
        'getty.target,Login Prompts,,450',
        'graphical.target,Graphical Interface,,450',
        'gssproxy.service,GSSAPI Proxy Daemon,,450',
        "ifupdown-pre.service,Helper to synchronize boot up for ifupdown,,225",
        'iio-sensor-proxy.service,IIO Sensor Proxy service,,225',
        'import-state.service,Import network configuration from initramfs,,225',
        'integritysetup.target,Local Integrity Protected Volumes,,225',
        'irqbalance.service,irqbalance daemon,,225',
        'irqbalance.service,irqbalance daemon,,450',
        'iscsid.socket,Open-iSCSI iscsid Socket,,0',
        'iscsiuio.socket,Open-iSCSI iscsiuio Socket,,0',
        'iwd.service,Wireless service,,450',
        'kerneloops.service,Tool to automatically collect and submit kernel crash signatures,kernoops,225',
        'keyboard-setup.service,Set the console keyboard layout,,225',
        'kmod-static-nodes.service,Create List of Static Device Nodes,,675',
        'kmod-static-nodes.service,Create list of static device nodes for the current kernel,,675',
        'kolide-launcher.service,Kolide launcher,,1800',
        'launcher.kolide-k2.service,The Kolide Launcher,,225',
        'ldconfig.service,Rebuild Dynamic Linker Cache,,675',
        'libvirtd-admin.socket,Libvirt admin socket,,225',
        'libvirtd-ro.socket,Libvirt local read-only socket,,225',
        'libvirtd.service,Virtualization daemon,,1800',
        'libvirtd.socket,Libvirt local socket,,225',
        'lightdm.service,Light Display Manager,,225',
        'lima-guestagent.service,lima-guestagent,,0',
        'livesys-late.service,SYSV: Late init script for live image.,,450',
        'livesys.service,LSB: Init script for live image.,,450',
        'lm_sensors.service,Hardware Monitoring Sensors,,225',
        'lm_sensors.service,Initialize hardware monitoring sensors,,225',
        'local-fs-pre.target,Local File Systems (Pre),,225',
        'local-fs-pre.target,Preparation for Local File Systems,,450',
        'local-fs.target,Local File Systems,,450',
        'logrotate-checkconf.service,Logrotate configuration check,,1125',
        'logrotate.timer,Daily rotation of log files,,0',
        'logrotate.timer,logrotate.timer,,0',
        'low-memory-monitor.service,Low Memory Monitor,,675',
        'lvm2-lvmpolld.socket,LVM2 poll daemon socket,,0',
        'lvm2-lvmpolld.socket,LVM2 poll daemon socket,,225',
        'lvm2-monitor.service,Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling,,450',
        'machine.slice,Virtual Machine and Container Slice,,450',
        'machines.target,Containers,,225',
        'man-db.service,Daily man-db regeneration,root,675',
        'man-db.timer,Daily man-db regeneration,,0',
        'mcelog.service,Machine Check Exception Logging Daemon,,225',
        'mlocate-updatedb.timer,Updates mlocate database every day,,0',
        'ModemManager.service,Modem Manager,root,450',
        'modprobe@efi_pstore.service,Load Kernel Module efi_pstore,,450',
        'modprobe@pstore_blk.service,Load Kernel Module pstore_blk,,450',
        'modprobe@pstore_zone.service,Load Kernel Module pstore_zone,,450',
        'modprobe@ramoops.service,Load Kernel Module ramoops,,450',
        'monitorix.service,Monitorix,,225',
        'motd-news.timer,Message of the Day,,0',
        'mount-pstore.service,mount-pstore.service,,1125',
        'multipathd.service,Device-Mapper Multipath Device Controller,,675',
        'multipathd.socket,multipathd control socket,,225',
        'multi-user.target,Multi-User System,,450',
        'nessusd.service,The Nessus Vulnerability Scanner,,675',
        'netcf-transaction.service,Rollback uncommitted netcf network config change transactions,,225',
        'networkd-dispatcher.service,Dispatcher daemon for systemd-networkd,,225',
        "networking.service,Raise network interfaces,,450",
        'network-interfaces.target,All Network Interfaces (deprecated),,0',
        'network-local-commands.service,Extra networking commands.,,1350',
        'NetworkManager-dispatcher.service,Network Manager Script Dispatcher Service,,675',
        'NetworkManager-dispatcher.service,Network Manager Script Dispatcher Service,,450',
        'NetworkManager.service,Network Manager,,1125',
        'nvidia-suspend.service,NVIDIA system suspend actions,,225',
        'NetworkManager.service,Network Manager,,1350',
        'NetworkManager-wait-online.service,Network Manager Wait Online,,1125',
        'network-online.target,Network is Online,,450',
        'network-pre.target,Network (Pre),,450',
        'network-pre.target,Preparation for Network,,450',
        'sleep.target,Sleep,,450',
        'network-setup.service,Networking Setup,,1350',
        'network.target,Network,,225',
        'network.target,Network,,450',
        'nfs-client.target,NFS client services,,225',
        'nginx.service,Nginx Web Server,nginx,2400',
        'nix-daemon.service,Nix Daemon,,225',
        'nix-daemon.socket,Nix Daemon Socket,,225',
        'nix-gc.timer,nix-gc.timer,,0',
        'nscd.service,Name Service Cache Daemon,nscd,1800',
        'nss-lookup.target,Host and Network Name Lookups,,450',
        'nss-user-lookup.target,User and Group Name Lookups,,450',
        'nvidia-fallback.service,Fallback to nouveau as nvidia did not load,,225',
        'nvidia-persistenced.service,NVIDIA Persistence Daemon,,225',
        'nvidia-powerd.service,nvidia-powerd service,,0',
        'openvpn.service,OpenVPN service,,225',
        'packagekit.service,PackageKit Daemon,root,225',
        'paths.target,Paths,,225',
        'paths.target,Path Units,,225',
        'pcscd.service,PC/SC Smart Card Daemon,,225',
        'pcscd.socket,PC/SC Smart Card Daemon Activation Socket,,0',
        'phpsessionclean.timer,Clean PHP session files every 30 mins,,0',
        'plocate-updatedb.service,Update the plocate database,,225',
        'plocate-updatedb.timer,Update the plocate database daily,,0',
        'plymouth-quit.service,Terminate Plymouth Boot Screen,,0',
        'plymouth-quit.service,Terminate Plymouth Boot Screen,,225',
        'plymouth-quit-wait.service,Hold until boot process finishes up,,0',
        'plymouth-read-write.service,Tell Plymouth To Write Out Runtime Data,,225',
        'plymouth-start.service,Show Plymouth Boot Screen,,450',
        'polkit.service,Authorization Manager,,0',
        'polkit.service,Authorization Manager,,225',
        'power-profiles-daemon.service,Power Profiles daemon,,675',
        'proc-sys-fs-binfmt_misc.automount,Arbitrary Executable File Formats File System Automount Point,,675',
        'pwrstatd.service,The monitor UPS software.,,225',
        'qemu-kvm.service,QEMU KVM preparation - module, ksm, hugepages,,225',
        'raid-check.timer,Weekly RAID setup health check,,0',
        'reflector.service,Refresh Pacman mirrorlist with Reflector.,,1350',
        'reflector.timer,Refresh Pacman mirrorlist weekly with Reflector.,,0',
        'reload-systemd-vconsole-setup.service,Reset console on configuration changes,,1125',
        'remote-fs-pre.target,Preparation for Remote File Systems,,450',
        'remote-fs.target,Remote File Systems,,450',
        "resolvconf-pull-resolved.path,resolvconf-pull-resolved.path,,0",
        "resolvconf.service,Nameserver information manager,,225",
        'resolvconf.service,resolvconf update,,1125',
        'rngd.service,Hardware RNG Entropy Gatherer Daemon,,225',
        'rpc_pipefs.target,rpc_pipefs.target,,0',
        'rpc-statd-notify.service,Notify NFS peers of a restart,,225',
        'rsyslog.service,System Logging Service,,225',
        'rsyslog.service,System Logging Service,,450',
        'rtkit-daemon.service,RealtimeKit Scheduling Policy Service,,900',
        'serial-getty@ttyS0.service,Serial Getty on ttyS0,,1350',
        'setroubleshootd.service,SETroubleshoot daemon for processing new SELinux denial logs,setroubleshoot,225',
        'setvtrgb.service,Set console scheme,,225',
        'shadow.service,Verify integrity of password and group files,,900',
        'shadow.timer,Daily verification of password and group files,,0',
        'sleep.target,Sleep,,225',
        'slices.target,Slices,,450',
        'slices.target,Slice Units,,450',
        'smartcard.target,Smart Card,,225',
        'smartd.service,Self Monitoring and Reporting Technology (SMART) Daemon,,225',
        'smartd.service,Self Monitoring and Reporting Technology (SMART) Daemon,,450',
        'snapd.apparmor.service,Load AppArmor profiles managed internally by snapd,,675',
        'snapd.mounts-pre.target,Mounting snaps,,0',
        'snapd.mounts.target,Mounted snaps,,0',
        'snapd.seeded.service,Wait until snapd is fully seeded,,225',
        'snapd.service,Snap Daemon,,450',
        'snapd.socket,Socket activation for snappy daemon,,225',
        'snap.lxd.daemon.unix.socket,Socket unix for snap application lxd.daemon,,225',
        'snap.lxd.user-daemon.unix.socket,Socket unix for snap application lxd.user-daemon,,225',
        'snap.yubioath-desktop.pcscd.service,Service for snap application yubioath-desktop.pcscd,,450',
        'sockets.target,Sockets,,225',
        'sockets.target,Socket Units,,225',
        'sound.target,Sound Card,,225',
        'sshd-keygen.target,sshd-keygen.target,,0',
        'sshd.service,OpenSSH Daemon,,225',
        'sshd.service,OpenSSH server daemon,,225',
        'sshd.service,SSH Daemon,,1575',
        'ssh.service,OpenBSD Secure Shell server,,450',
        'sssd-kcm.service,SSSD Kerberos Cache Manager,,225',
        'sssd-kcm.socket,SSSD Kerberos Cache Manager responder socket,,0',
        'swap.target,Swap,,225',
        'swap.target,Swaps,,225',
        'switcheroo-control.service,Switcheroo Control Proxy service,,450',
        'sysinit.target,System Initialization,,450',
        'syslog.socket,Syslog Socket,,1350',
        'sysstat-collect.timer,Run system activity accounting tool every 10 minutes,,225',
        'sysstat.service,Resets System Activity Logs,root,225',
        'sysstat.service,Resets System Activity Logs,root,450',
        'sysstat-summary.timer,Generate summary of yesterday''s process accounting,,225',
        'systemd-ask-password-console.path,Dispatch Password Requests to Console Directory Watch,,675',
        'systemd-ask-password-plymouth.path,Forward Password Requests to Plymouth Directory Watch,,225',
        'systemd-ask-password-plymouth.path,Forward Password Requests to Plymouth Directory Watch,,450',
        'systemd-ask-password-wall.path,Forward Password Requests to Wall Directory Watch,,450',
        'systemd-ask-password-wall.path,Forward Password Requests to Wall Directory Watch,,675',
        'systemd-binfmt.service,Set Up Additional Binary Formats,,1125',
        'systemd-boot-random-seed.service,Update Boot Loader Random Seed,,900',
        'systemd-boot-update.service,Automatic Boot Loader Update,,675',
        'systemd-coredump.socket,Process Core Dump Socket,,450',
        "systemd-cryptsetup@cryptdata.service,Cryptography Setup for cryptdata,,900",
        'systemd-cryptsetup@cryptoswap.service,Cryptography Setup for cryptoswap,,900',
        "systemd-cryptsetup@cryptswap.service,Cryptography Setup for cryptswap,,1125",
        'systemd-fsckd.socket,fsck to fsckd communication Socket,,450',
        'systemd-growfs@-.service,Grow File System on /,,225',
        'systemd-homed-activate.service,Home Area Activation,,450',
        'systemd-homed.service,Home Area Manager,,1350',
        'systemd-hostnamed.service,Hostname Service,,1125',
        'systemd-hwdb-update.service,Rebuild Hardware Database,,675',
        'systemd-initctl.socket,initctl Compatibility Named Pipe,,450',
        'systemd-journal-catalog-update.service,Rebuild Journal Catalog,,675',
        'systemd-journald-audit.socket,Journal Audit Socket,,450',
        'systemd-journald-audit.socket,Journal Audit Socket,,675',
        'systemd-journald-dev-log.socket,Journal Socket (/dev/log),,1125',
        'systemd-journald.service,Journal Service,,1800',
        'systemd-journald.service,Journal Service,,2025',
        'systemd-journald.service,Journal Service,,2200',
        'systemd-journald.socket,Journal Socket,,900',
        'systemd-journal-flush.service,Flush Journal to Persistent Storage,,675',
        'systemd-localed.service,Locale Service,,1125',
        'systemd-logind.service,User Login Management,,1800',
        'systemd-logind.service,User Login Management,,2025',
        'systemd-machined.service,Virtual Machine and Container Registration Service,,1125',
        'systemd-machined.service,Virtual Machine and Container Registration Service,,1350',
        'systemd-modules-load.service,Load Kernel Modules,,900',
        'systemd-networkd.service,Network Configuration,systemd-network,2250',
        'systemd-networkd.socket,Network Service Netlink Socket,,675',
        'systemd-networkd-wait-online.service,Wait for Network to be Configured,,675',
        'systemd-network-generator.service,Generate network units from Kernel command line,,450',
        'systemd-network-generator.service,Generate network units from Kernel command line,,675',
        'systemd-oomd.service,Userspace Out-Of-Memory (OOM) Killer,systemd-oom,1575',
        'systemd-oomd.socket,Userspace Out-Of-Memory (OOM) Killer Socket,,450',
        'systemd-pcrmachine.service,TPM2 PCR Machine ID Measurement,,675',
        'systemd-pcrmachine.service,TPM2 PCR Machine ID Measurement,,700',
        'systemd-pcrphase.service,TPM2 PCR Barrier (User),,675',
        'systemd-pcrphase-sysinit.service,TPM2 PCR Barrier (Initialization),,675',
        'systemd-random-seed.service,Load/Save OS Random Seed,,1125',
        'systemd-random-seed.service,Load/Save Random Seed,,1125',
        'systemd-remount-fs.service,Remount Root and Kernel File Systems,,675',
        'systemd-resolved.service,Network Name Resolution,systemd-resolve,1575',
        'systemd-rfkill.socket,Load/Save RF Kill Switch Status /dev/rfkill Watch,,675',
        'systemd-suspend.service,System Suspend,,450',
        'systemd-sysctl.service,Apply Kernel Variables,,675',
        'systemd-sysusers.service,Create System Users,,1125',
        'systemd-sysusers.service,Create System Users,,675',
        'systemd-sysusers.service,Create System Users,,900',
        'systemd-timedated.service,Time & Date Service,,1125',
        'systemd-timesyncd.service,Network Time Synchronization,systemd-timesync,1575',
        'systemd-timesyncd.service,Network Time Synchronization,systemd-timesync,1800',
        'systemd-tmpfiles-clean.timer,Daily Cleanup of Temporary Directories,,450',
        'systemd-tmpfiles-setup-dev.service,Create Static Device Nodes in /dev,,675',
        'systemd-tmpfiles-setup.service,Create Volatile Files and Directories,,675',
        'systemd-tmpfiles-setup.service,Create Volatile Files and Directories,,900',
        'systemd-udevd-control.socket,udev Control Socket,,450',
        'systemd-udevd-kernel.socket,udev Kernel Socket,,450',
        'systemd-udevd.service,Rule-based Manager for Device Events and Files,,1125',
        'systemd-udevd.service,Rule-based Manager for Device Events and Files,,1350',
        'systemd-udev-settle.service,Wait for udev To Complete Device Initialization,,675',
        'systemd-udev-trigger.service,Coldplug All udev Devices,,675',
        'systemd-update-done.service,Update is Completed,,675',
        'systemd-update-utmp.service,Record System Boot/Shutdown in UTMP,,675',
        'systemd-update-utmp.service,Record System Boot/Shutdown in UTMP,,900',
        'systemd-update-utmp.service,Update UTMP about System Boot/Shutdown,,675',
        'systemd-userdbd.service,User Database Manager,,1125',
        'systemd-userdbd.socket,User Database Manager Socket,,675',
        'systemd-user-sessions.service,Permit User Sessions,,450',
        'systemd-user-sessions.service,Permit User Sessions,,675',
        'systemd-vconsole-setup.service,Setup Virtual Console,,450',
        'systemd-vconsole-setup.service,Setup Virtual Console,,675',
        'system.slice,System Slice,,0',
        'tailscaled.service,Tailscale node agent,,675',
        'thermald.service,Thermal Daemon Service,,225',
        'timers.target,Timers,,450',
        'timers.target,Timer Units,,450',
        'time-set.target,System Time Set,,225',
        "time-sync.target,System Time Synchronized,,225",
        'time-sync.target,System Time Synchronized,,450',
        'tlp.service,TLP system startup/shutdown,,450',
        "touchegg.service,Touchégg Daemon,,225",
        'ua-timer.timer,Ubuntu Advantage Timer for running repeated jobs,,0',
        'udisks2.service,Disk Manager,,0',
        'udisks2.service,Disk Manager,,225',
        'ufw.service,Uncomplicated firewall,,225',
        'unattended-upgrades.service,Unattended Upgrades Shutdown,,225',
        'unbound-anchor.timer,daily update of the root trust anchor for DNSSEC,,225',
        'updatedb.timer,Daily locate database update,,0',
        'update-notifier-download.timer,Download data for packages that failed at package install time,,225',
        'update-notifier-motd.timer,Check to see whether there is a new version of Ubuntu available,,225',
        'upower.service,Daemon for power management,,900',
        'uresourced.service,User resource assignment daemon,,225',
        'usbmuxd.service,Socket daemon for the usbmux protocol used by Apple devices,,225',
        'user.slice,User and Session Slice,,225',
        'uuidd.socket,UUID daemon activation socket,,0',
        'vboxautostart-service.service,vboxautostart-service.service,,450',
        'vboxballoonctrl-service.service,vboxballoonctrl-service.service,,450',
        'vboxdrv.service,VirtualBox Linux kernel module,,450',
        'vboxweb-service.service,vboxweb-service.service,,450',
        'veritysetup.target,Local Verity Protected Volumes,,225',
        'virtinterfaced.socket,Libvirt interface local socket,,225',
        'virtlockd.socket,Virtual machine lock manager socket,,0',
        'virtlogd-admin.socket,Virtual machine log manager socket,,225',
        'virtlogd.service,Virtual machine log manager,,675',
        'virtlogd.socket,Virtual machine log manager socket,,0',
        'virtnetworkd.socket,Libvirt network local socket,,225',
        'virtnodedevd.socket,Libvirt nodedev local socket,,225',
        'virtnwfilterd.socket,Libvirt nwfilter local socket,,225',
        'virtproxyd.socket,Libvirt proxy local socket,,225',
        'virtqemud-admin.socket,Libvirt qemu admin socket,,225',
        'virtqemud-ro.socket,Libvirt qemu local read-only socket,,225',
        'virtqemud.socket,Libvirt qemu local socket,,0',
        'virtqemud.socket,Libvirt qemu local socket,,225',
        'virtsecretd.socket,Libvirt secret local socket,,0',
        'virtsecretd.socket,Libvirt secret local socket,,225',
        'virtstoraged.socket,Libvirt storage local socket,,225',
        'whoopsie.path,Start whoopsie on modification of the /var/crash directory,,0',
        'wpa_supplicant.service,WPA supplicant,,225',
        'zfs-import-cache.service,Import ZFS pools by cache file,,450',
        'zfs-import.target,ZFS pool import target,,0',
        'zfs-load-key-rpool.service,Load ZFS key for rpool,,675',
        'zfs-load-module.service,Install ZFS kernel module,,225',
        'zfs-mount.service,Mount ZFS filesystems,,225',
        'zfs-scrub.service,ZFS pools scrubbing,,900',
        'zfs-scrub.timer,zfs-scrub.timer,,0',
        'zfs-share.service,ZFS file system shares,,225',
        'zfs-share.service,ZFS file system shares,,450',
        'zfs.target,ZFS startup target,,0',
        'zfs-volumes.target,ZFS volumes are ready,,0',
        'zfs-volume-wait.service,Wait for ZFS Volume (zvol) links in /dev,,225',
        'zfs-zed.service,ZFS Event Daemon (zed),,225',
        'znapzend.service,ZnapZend - ZFS Backup System,root,1575',
        'zpool-trim.service,ZFS pools trim,,1125',
        'zpool-trim.timer,zpool-trim.timer,,0'
      )
      OR exception_key LIKE 'machine-qemu%.scope,Virtual Machine qemu%,,225'
      OR exception_key LIKE 'zfs-snapshot-%.timer,zfs-snapshot-%.timer,,0'
      OR exception_key LIKE 'zfs-snapshot-%.service,zfs-snapshot-%.service,,900'
      OR exception_key LIKE 'dbus-:1.%-org.freedesktop.problems@%.service,dbus-:%.%-org.freedesktop.problems@%.service,0,225'
      OR exception_key LIKE 'run-media-%.mount,run-media-%.mount,,0'
      OR id LIKE 'blockdev@dev-mapper-luks%.target'
      OR id LIKE 'blockdev@dev-mapper-nvme%.target'
      OR id LIKE ''
      OR id LIKE 'dev-disk-by%.swap'
      OR id LIKE 'dev-mapper-%.swap'
      OR id LIKE 'dev-zram%.swap'
      OR id LIKE 'docker-%.scope'
      OR id LIKE 'getty@tty%.service'
      OR id LIKE 'home-manager-%.service'
      OR id LIKE 'lvm2-pvscan@%.service'
      OR id LIKE 'session-%.scope'
      OR id LIKE 'system-systemd%cryptsetup.slice'
      OR id LIKE 'systemd-backlight@%.service'
      OR id LIKE 'systemd-cryptsetup@luks%.service'
      OR id LIKE 'systemd-cryptsetup@nvme%.service'
      OR id LIKE 'systemd-fsck@dev-disk-by%service'
      OR id LIKE 'systemd-zram-setup@zram%.service'
      OR id LIKE 'user-runtime-dir@%.service'
      OR id LIKE 'user@%.service'
      OR id LIKE 'akmods@%64.service'
    )
  )
