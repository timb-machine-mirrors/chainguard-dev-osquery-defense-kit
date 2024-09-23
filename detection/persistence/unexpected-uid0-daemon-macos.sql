-- Unexpected long-running processes running as root
--
-- false positives:
--   * new software requiring escalated privileges
--
-- references:
--   * https://attack.mitre.org/techniques/T1543/
--
-- tags: persistent process state
-- platform: darwin
SELECT
  s.authority AS p0_auth,
  s.identifier AS p0_id,
  DATETIME(f.ctime, 'unixepoch') AS p0_changed,
  DATETIME(f.mtime, 'unixepoch') AS p0_modified,
  (strftime('%s', 'now') - p0.start_time) AS p0_runtime_s,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1_f.mode AS p1_mode,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256,
  -- Grandparent
  p1.parent AS p2_pid,
  p2.name AS p2_name,
  p2.path AS p2_path,
  p2.cmdline AS p2_cmd,
  p2_hash.sha256 AS p2_sha256
FROM
  processes p0
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN signature s ON p0.path = s.path
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN file p1_f ON p1.path = p1_f.path
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
WHERE -- Focus on longer-running programs
  p0.pid IN (
    SELECT
      pid
    FROM
      processes
    WHERE
      euid = 0
      AND start_time < (strftime('%s', 'now') - 900)
      AND parent != 0 -- Assume STP
      AND path NOT IN (
        '/Applications/Foxit PDF Reader.app/Contents/MacOS/FoxitPDFReaderUpdateService.app/Contents/MacOS/FoxitPDFReaderUpdateService',
        '/Applications/OneDrive.app/Contents/StandaloneUpdaterDaemon.xpc/Contents/MacOS/StandaloneUpdaterDaemon',
        '/Applications/Opal.app/Contents/Library/LaunchServices/com.opalcamera.cameraExtensionShim',
        '/Applications/Parallels Desktop.app/Contents/MacOS/Parallels Service.app/Contents/MacOS/prl_disp_service',
        '/Applications/Parallels Desktop.app/Contents/MacOS/prl_naptd',
        '/Applications/WiFiman Desktop.app/Contents/service/wifiman-desktopd',
        '/Applications/VMware Fusion.app/Contents/Library/vmware-vmx',
        '/bin/bash',
        '/Library/Apple/System/Library/CoreServices/XProtect.app/Contents/MacOS/XProtect',
        '/Library/Apple/System/Library/CoreServices/XProtect.app/Contents/XPCServices/XProtectPluginService.xpc/Contents/MacOS/XProtectPluginService',
        '/Library/Application Support/Adobe/Adobe Desktop Common/ElevationManager/Adobe Installer',
        '/Library/Application Support/Fortinet/FortiClient/bin/fcconfig',
        '/Library/Application Support/Fortinet/FortiClient/bin/fctservctl',
        '/Library/Application Support/Objective Development/Little Snitch/Components/at.obdev.littlesnitch.daemon.bundle/Contents/MacOS/at.obdev.littlesnitch.daemon',
        '/Library/Application Support/Paragon Software/com.paragon-software.extfsd',
        '/Library/Application Support/Paragon Software/com.paragon-software.ntfsd',
        '/Library/Application Support/VMware/VMware Fusion/Services/Contents/Library/vmnet-bridge',
        '/Library/Application Support/VMware/VMware Fusion/Services/Contents/Library/vmnet-dhcpd',
        '/Library/Application Support/VMware/VMware Fusion/Services/Contents/Library/vmnet-natd',
        '/Library/Application Support/VMware/VMware Fusion/Services/Contents/Library/vmware-usbarbitrator',
        '/Library/Application Support/X-Rite/Frameworks/XRiteDevice.framework/Versions/B/Resources/xrdd',
        '/Library/Audio/Plug-Ins/HAL/SolsticeDesktopSpeakers.driver/Contents/XPCServices/RelayXpc.xpc/Contents/MacOS/RelayXpc',
        '/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Resources/Java Updater.app/Contents/MacOS/Java Updater',
        '/Library/Nessus/run/sbin/nessusd',
        '/Library/Nessus/run/sbin/nessus-service',
        '/Library/PrivilegedHelperTools/com.adobe.acc.installer.v2',
        '/Library/PrivilegedHelperTools/com.docker.vmnetd',
        '/Library/PrivilegedHelperTools/com.fortinet.forticlient.macos.PrivilegedHelper',
        '/Library/PrivilegedHelperTools/com.macpaw.CleanMyMac4.Agent',
        '/Library/PrivilegedHelperTools/keybase.Helper',
        '/Library/PrivilegedHelperTools/licenseDaemon.app/Contents/MacOS/licenseDaemon',
        '/Library/PrivilegedHelperTools/MHLinkServer.app/Contents/MacOS/MHLinkServer',
        '/Library/SystemExtensions/0FDB5206-860F-465C-B4D3-D6A0F43F4302/com.google.one.NetworkExtension.systemextension/Contents/MacOS/com.google.one.NetworkExtension',
        '/Library/SystemExtensions/2DA71D8A-7905-4012-A7D5-0B246D5AA77B/at.obdev.littlesnitch.networkextension.systemextension/Contents/MacOS/at.obdev.littlesnitch.networkextension',
        '/Library/SystemExtensions/4D1BF33A-9817-45D7-A242-8C39810C7F11/com.redcanary.agent.securityextension.systemextension/Contents/MacOS/com.redcanary.agent.securityextension',
        '/Library/SystemExtensions/CC9A335C-A6D0-4C87-B902-45EBDF4BFD85/com.google.one.NetworkExtension.systemextension/Contents/MacOS/com.google.one.NetworkExtension',
        '/opt/homebrew/Cellar/telepresence-arm64/2.7.6/bin/telepresence',
        '/opt/osquery/lib/osquery.app/Contents/MacOS/osqueryd',
        '/opt/socket_vmnet/bin/socket_vmnet',
        '/sbin/launchd',
        '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd',
        '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd-helper',
        '/System/Library/CoreServices/CrashReporterSupportHelper',
        '/System/Library/CoreServices/iconservicesagent',
        '/System/Library/CoreServices/launchservicesd',
        '/System/Library/CoreServices/logind',
        '/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow',
        '/System/Library/CoreServices/osanalyticshelper',
        '/System/Library/CoreServices/powerd.bundle/powerd',
        '/System/Library/CoreServices/ReportCrash',
        '/System/Library/CoreServices/sharedfilelistd',
        '/System/Library/CoreServices/Software Update.app/Contents/Resources/suhelperd',
        '/System/Library/CoreServices/SubmitDiagInfo',
        '/System/Library/CryptoTokenKit/com.apple.ifdreader.slotd/Contents/MacOS/com.apple.ifdreader',
        '/System/Library/CryptoTokenKit/com.apple.ifdreader.slotd/Contents/XPCServices/com.apple.ifdbundle.xpc/Contents/MacOS/com.apple.ifdbundle',
        '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/XPCServices/com.apple.hiservices-xpcservice.xpc/Contents/MacOS/com.apple.hiservices-xpcservice',
        '/System/Library/Frameworks/AudioToolbox.framework/AudioComponentRegistrar',
        '/System/Library/Frameworks/AudioToolbox.framework/XPCServices/CAReportingService.xpc/Contents/MacOS/CAReportingService',
        '/System/Library/Frameworks/AudioToolbox.framework/XPCServices/com.apple.audio.SandboxHelper.xpc/Contents/MacOS/com.apple.audio.SandboxHelper',
        '/System/Library/Frameworks/ColorSync.framework/Versions/A/XPCServices/com.apple.ColorSyncXPCAgent.xpc/Contents/MacOS/com.apple.ColorSyncXPCAgent',
        '/System/Library/Frameworks/CoreMediaIO.framework/Versions/A/Resources/com.apple.cmio.registerassistantservice',
        '/System/Library/Frameworks/CoreMediaIO.framework/Versions/A/Resources/iOSScreenCapture.plugin/Contents/Resources/iOSScreenCaptureAssistant',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Support/coreservicesd',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/XPCServices/csnameddatad.xpc/Contents/MacOS/csnameddatad',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/FSEvents.framework/Versions/A/Support/fseventsd',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mds',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mds_stores',
        '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mdsync',
        '/System/Library/Frameworks/CryptoTokenKit.framework/ctkahp.bundle/Contents/MacOS/ctkahp',
        '/System/Library/Frameworks/GSS.framework/Helpers/GSSCred',
        '/System/Library/Frameworks/LocalAuthentication.framework/Support/coreauthd',
        '/System/Library/Frameworks/Metal.framework/Versions/A/XPCServices/MTLCompilerService.xpc/Contents/MacOS/MTLCompilerService',
        '/System/Library/Frameworks/NetFS.framework/Versions/A/XPCServices/PlugInLibraryService.xpc/Contents/MacOS/PlugInLibraryService',
        '/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/CVMServer',
        '/System/Library/Frameworks/PCSC.framework/Versions/A/XPCServices/com.apple.ctkpcscd.xpc/Contents/MacOS/com.apple.ctkpcscd',
        '/System/Library/Frameworks/PreferencePanes.framework/Versions/A/XPCServices/cacheAssistant.xpc/Contents/MacOS/cacheAssistant',
        '/System/Library/Frameworks/Security.framework/Versions/A/XPCServices/authd.xpc/Contents/MacOS/authd',
        '/System/Library/Frameworks/Security.framework/Versions/A/XPCServices/com.apple.CodeSigningHelper.xpc/Contents/MacOS/com.apple.CodeSigningHelper',
        '/System/Library/Frameworks/SystemExtensions.framework/Versions/A/Helpers/sysextd',
        '/System/Library/PrivateFrameworks/AccountPolicy.framework/XPCServices/com.apple.AccountPolicyHelper.xpc/Contents/MacOS/com.apple.AccountPolicyHelper',
        '/System/Library/PrivateFrameworks/AmbientDisplay.framework/Versions/A/XPCServices/com.apple.AmbientDisplayAgent.xpc/Contents/MacOS/com.apple.AmbientDisplayAgent',
        '/System/Library/PrivateFrameworks/AppleCredentialManager.framework/AppleCredentialManagerDaemon',
        '/System/Library/PrivateFrameworks/AppleNeuralEngine.framework/XPCServices/ANECompilerService.xpc/Contents/MacOS/ANECompilerService',
        '/System/Library/PrivateFrameworks/AppleNeuralEngine.framework/XPCServices/ANEStorageMaintainer.xpc/Contents/MacOS/ANEStorageMaintainer',
        '/System/Library/PrivateFrameworks/ApplePushService.framework/apsd',
        '/System/Library/PrivateFrameworks/AppSSO.framework/Support/AppSSODaemon',
        '/System/Library/PrivateFrameworks/AppStoreDaemon.framework/Versions/A/XPCServices/com.apple.AppStoreDaemon.StorePrivilegedTaskService.xpc/Contents/MacOS/com.apple.AppStoreDaemon.StorePrivilegedTaskService',
        '/System/Library/PrivateFrameworks/AssetCacheServicesExtensions.framework/Versions/A/XPCServices/AssetCacheManagerService.xpc/Contents/MacOS/AssetCacheManagerService',
        '/System/Library/PrivateFrameworks/AssetCacheServicesExtensions.framework/Versions/A/XPCServices/AssetCacheTetheratorService.xpc/Contents/MacOS/AssetCacheTetheratorService',
        '/System/Library/PrivateFrameworks/AuthKit.framework/Versions/A/Support/akd',
        '/System/Library/PrivateFrameworks/BackgroundTaskManagement.framework/Versions/A/Resources/backgroundtaskmanagementd',
        '/System/Library/PrivateFrameworks/BridgeOSInstallReporting.framework/Versions/A/Resources/bosreporter',
        '/System/Library/PrivateFrameworks/CacheDelete.framework/deleted_helper',
        '/System/Library/PrivateFrameworks/CloudKitDaemon.framework/Support/cloudd',
        '/System/Library/PrivateFrameworks/CoreAccessories.framework/Support/accessoryd',
        '/System/Library/PrivateFrameworks/CoreDuetContext.framework/Versions/A/Resources/contextstored',
        '/System/Library/PrivateFrameworks/CoreKDL.framework/Support/corekdld',
        '/System/Library/PrivateFrameworks/CoreSymbolication.framework/coresymbolicationd',
        '/System/Library/PrivateFrameworks/FamilyControls.framework/Versions/A/Resources/parentalcontrolsd',
        '/System/Library/PrivateFrameworks/FindMyMac.framework/Versions/A/Resources/FindMyMacd',
        '/System/Library/PrivateFrameworks/GenerationalStorage.framework/Versions/A/Support/revisiond',
        '/System/Library/PrivateFrameworks/GeoServices.framework/Versions/A/XPCServices/com.apple.geod.xpc/Contents/MacOS/com.apple.geod',
        '/System/Library/PrivateFrameworks/Heimdal.framework/Helpers/kdc',
        '/System/Library/PrivateFrameworks/InstallerDiagnostics.framework/Versions/A/Resources/installerdiagd',
        '/System/Library/PrivateFrameworks/InstallerDiagnostics.framework/Versions/A/Resources/installerdiagwatcher',
        '/System/Library/PrivateFrameworks/MediaRemote.framework/Support/mediaremoted',
        '/System/Library/PrivateFrameworks/MobileInstallation.framework/XPCServices/com.apple.MobileInstallationHelperService.xpc/Contents/MacOS/com.apple.MobileInstallationHelperService',
        '/System/Library/PrivateFrameworks/MobileSoftwareUpdate.framework/Versions/A/XPCServices/com.apple.MobileSoftwareUpdate.CleanupPreparePathService.xpc/Contents/MacOS/com.apple.MobileSoftwareUpdate.CleanupPreparePathService',
        '/System/Library/PrivateFrameworks/Noticeboard.framework/Versions/A/Resources/nbstated',
        '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/Resources/installd',
        '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/Resources/system_installd',
        '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/XPCServices/package_script_service.xpc/Contents/MacOS/package_script_service',
        '/System/Library/PrivateFrameworks/SiriInference.framework/Support/siriinferenced',
        '/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/Resources/WindowServer',
        '/System/Library/PrivateFrameworks/StorageKit.framework/Versions/A/Resources/storagekitd',
        '/System/Library/PrivateFrameworks/SystemAdministration.framework/XPCServices/writeconfig.xpc/Contents/MacOS/writeconfig',
        '/System/Library/PrivateFrameworks/SystemMigration.framework/Versions/A/Resources/systemmigrationd',
        '/System/Library/PrivateFrameworks/SystemStatusServer.framework/Support/systemstatusd',
        '/System/Library/PrivateFrameworks/TCC.framework/Support/tccd',
        '/System/Library/PrivateFrameworks/Uninstall.framework/Versions/A/Resources/uninstalld',
        '/System/Library/PrivateFrameworks/ViewBridge.framework/Versions/A/XPCServices/ViewBridgeAuxiliary.xpc/Contents/MacOS/ViewBridgeAuxiliary',
        '/System/Library/PrivateFrameworks/WiFiPolicy.framework/XPCServices/WiFiCloudAssetsXPCService.xpc/Contents/MacOS/WiFiCloudAssetsXPCService',
        '/System/Library/PrivateFrameworks/WirelessDiagnostics.framework/Support/awdd',
        '/System/Library/PrivateFrameworks/XprotectFramework.framework/Versions/A/XPCServices/XProtectBehaviorService.xpc/Contents/MacOS/XProtectBehaviorService',
        '/System/Library/PrivateFrameworks/XprotectFramework.framework/Versions/A/XPCServices/XprotectService.xpc/Contents/MacOS/XprotectService',
        '/usr/bin/login',
        '/usr/bin/sudo',
        '/usr/bin/sysdiagnose',
        '/usr/libexec/AirPlayXPCHelper',
        '/usr/libexec/airportd',
        '/usr/libexec/amfid',
        '/usr/libexec/aned',
        '/usr/libexec/apfsd',
        '/usr/libexec/applessdstatistics',
        '/usr/libexec/ApplicationFirewall/socketfilterfw',
        '/usr/libexec/ASPCarryLog',
        '/usr/libexec/autofsd',
        '/usr/libexec/automountd',
        '/usr/libexec/batteryintelligenced',
        '/usr/libexec/biokitaggdd',
        '/usr/libexec/biometrickitd',
        '/usr/libexec/bootinstalld',
        '/usr/libexec/colorsyncd',
        '/usr/libexec/colorsync.displayservices',
        '/usr/libexec/configd',
        '/usr/libexec/containermanagerd',
        '/usr/libexec/corebrightnessd',
        '/usr/libexec/coreduetd',
        '/usr/libexec/corestoraged',
        '/usr/libexec/cryptexd',
        '/usr/libexec/dasd',
        '/usr/libexec/dirhelper',
        '/usr/libexec/diskarbitrationd',
        '/usr/libexec/diskmanagementd',
        '/usr/libexec/dprivacyd',
        '/usr/libexec/endpointsecurityd',
        '/usr/libexec/findmydeviced',
        '/usr/libexec/firmwarecheckers/ethcheck/ethcheck',
        '/usr/libexec/InternetSharing',
        '/usr/libexec/IOMFB_bics_daemon',
        '/usr/libexec/ioupsd',
        '/usr/libexec/kernelmanagerd',
        '/usr/libexec/keybagd',
        '/usr/libexec/logd',
        '/usr/libexec/logd_helper',
        '/usr/libexec/lsd',
        '/usr/libexec/mdmclient',
        '/usr/libexec/memoryanalyticsd',
        '/usr/libexec/microstackshot',
        '/usr/libexec/misagent',
        '/usr/libexec/mobileactivationd',
        '/usr/libexec/mobileassetd',
        '/usr/libexec/multiversed',
        '/usr/libexec/nehelper',
        '/usr/libexec/nesessionmanager',
        '/usr/libexec/online-authd',
        '/usr/libexec/opendirectoryd',
        '/usr/libexec/PerfPowerServices',
        '/usr/libexec/periodic-wrapper',
        '/usr/libexec/powerdatad',
        '/usr/libexec/PowerUIAgent',
        '/usr/libexec/remoted',
        '/usr/libexec/rtcreportingd',
        '/usr/libexec/runningboardd',
        '/usr/libexec/sandboxd',
        '/usr/libexec/searchpartyd',
        '/usr/libexec/secinitd',
        '/usr/libexec/securityd_service',
        '/usr/libexec/smd',
        '/usr/libexec/storagekitd',
        '/usr/libexec/symptomsd-diag',
        '/usr/libexec/sysmond',
        '/Library/Application Support/iStat Menus 7/com.bjango.istatmenus.daemon',
        '/usr/libexec/syspolicyd',
        '/usr/libexec/tailspind',
        '/usr/libexec/taskgated',
        '/usr/libexec/thermald',
        '/Applications/Tailscale.app/Contents/Frameworks/Sparkle.framework/Versions/B/Autoupdate',
        '/usr/libexec/thermalmonitord',
        '/usr/libexec/TouchBarServer',
        '/usr/libexec/trustdFileHelper',
        '/usr/libexec/tzd',
        '/usr/libexec/tzlinkd',
        '/usr/libexec/usbd',
        '/usr/libexec/UserEventAgent',
        '/usr/libexec/usermanagerd',
        '/usr/libexec/warmd',
        '/usr/libexec/watchdogd',
        '/usr/libexec/wifianalyticsd',
        '/usr/libexec/wifip2pd',
        '/usr/libexec/wifivelocityd',
        '/usr/local/bin/warsaw/core',
        '/usr/local/kolide-k2/bin/osquery-extension.ext',
        '/usr/local/sbin/velociraptor',
        '/usr/sbin/aslmanager',
        '/usr/sbin/audioclocksyncd',
        '/usr/sbin/auditd',
        '/usr/sbin/BlueTool',
        '/usr/sbin/bluetoothd',
        '/usr/sbin/BTLEServer',
        '/usr/sbin/cfprefsd',
        '/usr/sbin/distnoted',
        '/usr/sbin/filecoordinationd',
        '/usr/sbin/KernelEventAgent',
        '/usr/sbin/mDNSResponderHelper',
        '/usr/sbin/notifyd',
        '/usr/sbin/securityd',
        '/usr/sbin/spindump',
        '/usr/sbin/sshd',
        '/usr/sbin/syslogd',
        '/usr/sbin/systemsoundserverd',
        '/usr/sbin/systemstats',
        '/usr/sbin/WirelessRadioManagerd'
      )
      AND NOT path LIKE '/nix/store/%-nix-%/bin/nix'
      AND NOT path LIKE '/opt/homebrew/Cellar/btop/%/bin/btop'
      AND NOT path LIKE '/opt/homebrew/Cellar/htop/%/bin/htop'
      AND NOT path LIKE '/opt/homebrew/Cellar/mtr/%/sbin/%'
      AND NOT path LIKE '/opt/homebrew/Cellar/socket_vmnet/%/bin/socket_vmnet'
      AND NOT path LIKE '/usr/local/Cellar/btop/%/bin/btop'
      AND NOT path LIKE '/usr/local/Cellar/htop/%/bin/htop'
      AND NOT path LIKE '/usr/local/kolide-k2/bin/launcher-updates/%/Kolide.app/Contents/MacOS/launcher'
      AND NOT path LIKE '/usr/local/kolide-k2/bin/osqueryd-updates/%/osqueryd'
    GROUP BY
      path
  )
  AND NOT s.authority IN (
    'Developer ID Application: Adguard Software Limited (TC3Q7MAJXF)',
    'Developer ID Application: Adobe Inc. (JQ525L2MZD)',
    'Developer ID Application: Bitdefender SRL (GUNFMW623Y)',
    'Developer ID Application: Bjango Pty Ltd (Y93TK974AT)',
    'Developer ID Application: Canonical Group Limited (X4QN7LTP59)',
    'Developer ID Application: Cloudflare Inc. (68WVV388M8)',
    'Developer ID Application: Corsair Memory, Inc. (Y93VXCB8Q5)',
    'Developer ID Application: Creative Labs Pte. Ltd. (5Q3552844F)',
    'Developer ID Application: Docker Inc (9BNSXJN65R)',
    'Developer ID Application: Dropbox, Inc. (G7HH3F8CAK)',
    'Developer ID Application: Ecamm Network, LLC (5EJH68M642)',
    'Developer ID Application: Elasticsearch, Inc (2BT3HPN62Z)',
    'Developer ID Application: Fortinet, Inc (AH4XFXJ7DK)',
    'Developer ID Application: Foxit Corporation (8GN47HTP75)',
    'Developer ID Application: SURFSHARK LTD (YHUG37CKN8)',
    'Developer ID Application: Fumihiko Takayama (G43BCU2T37)',
    'Developer ID Application: Google LLC (EQHXZ8M8AV)',
    'Developer ID Application: Ilya Parniuk (ACC5R6RH47)',
    'Developer ID Application: Kandji, Inc. (P3FGV63VK7)',
    'Developer ID Application: Keybase, Inc. (99229SGT5K)',
    'Developer ID Application: Kolide, Inc (X98UFR7HA3)',
    'Developer ID Application: Kolide Inc (YZ3EM74M78)',
    'Developer ID Application: Logitech Inc. (QED4VVPZWA)',
    'Developer ID Application: MacPaw Inc. (S8EX82NJP6)',
    'Developer ID Application: Mersive Technologies (63B5A5WDNG)',
    'Developer ID Application: Metric Halo Distribution, Inc. (X7EY8SFM86)',
    'Developer ID Application: Microsoft Corporation (UBF8T346G9)',
    'Developer ID Application: Mullvad VPN AB (CKG9MXH72F)',
    'Developer ID Application: Nordvpn S.A. (W5W395V82Y)',
    'Developer ID Application: Objective Development Software GmbH (MLZF7K7B5R)',
    'Developer ID Application: Objective-See, LLC (VBG97UB4TA)',
    'Developer ID Application: Opal Camera Inc (97Z3HJWCRT)',
    'Developer ID Application: OPENVPN TECHNOLOGIES, INC. (ACV7L3WCD8)',
    'Developer ID Application: OSQUERY A Series of LF Projects, LLC (3522FA9PXF)',
    'Developer ID Application: Parallels International GmbH (4C6364ACXT)',
    'Developer ID Application: Private Internet Access, Inc. (5357M5NW9W)',
    'Developer ID Application: Rapid7 LLC (UL6CGN7MAL)',
    'Developer ID Application: Ryan Hanson (XSYZ3E4B7D)',
    'Developer ID Application: Slack Technologies, Inc. (BQR82RBBHL)',
    'Developer ID Application: Tailscale Inc. (W5364U7YZB)',
    'Developer ID Application: Tenable, Inc. (4B8J598M7U)',
    'Developer ID Application: X-Rite, Incorporated (2K7GT73B4R)',
    'Developer ID Application: Y Soft Corporation, a.s. (3CPED8WGS9)',
    'Software Signing'
  )
  AND NOT (
    p0.path = '/Library/Printers/DYMO/Utilities/pnpd'
    AND s.identifier = 'pnpd'
    AND s.authority = 'Developer ID Application: Sanford, L.P. (N3S6676K3E)'
  )
GROUP BY
  p0.path
