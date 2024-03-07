-- Unexpected programs communicating over HTTPS (state-based)
--
-- references:
--   * https://attack.mitre.org/techniques/T1071/ (C&C, Application Layer Protocol)
--
-- tags: transient state net often
-- platform: macos
SELECT
  pos.protocol,
  pos.local_port,
  pos.remote_port,
  pos.remote_address,
  pos.local_port,
  pos.local_address,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name,
    ',',
    s.authority,
    ',',
    s.identifier
  ) AS exception_key,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name,
    ',',
    MIN(f.uid, 500),
    'u,',
    MIN(f.gid, 500),
    'g'
  ) AS alt_exception_key,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  s.authority AS p0_sauth,
  s.identifier AS p0_sid,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
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
  process_open_sockets pos
  LEFT JOIN processes p0 ON pos.pid = p0.pid
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN signature s ON p0.path = s.path
WHERE
  pos.protocol IN (6, 17)
  AND pos.remote_port = 443
  AND pos.remote_address NOT IN ('127.0.0.1', '::ffff:127.0.0.1', '::1')
  AND pos.remote_address NOT LIKE 'fe80:%'
  AND pos.remote_address NOT LIKE '127.%'
  AND pos.remote_address NOT LIKE '192.168.%'
  AND pos.remote_address NOT LIKE '172.1%'
  AND pos.remote_address NOT LIKE '172.2%'
  AND pos.remote_address NOT LIKE '172.30.%'
  AND pos.remote_address NOT LIKE '172.31.%'
  AND pos.remote_address NOT LIKE '::ffff:172.%'
  AND pos.remote_address NOT LIKE '10.%'
  AND pos.remote_address NOT LIKE '::ffff:10.%'
  AND pos.remote_address NOT LIKE 'fdfd:%'
  AND pos.remote_address NOT LIKE 'fc00:%'
  AND pos.state != 'LISTEN' -- Ignore most common application paths
  AND p0.path NOT LIKE '/Applications/%.app/Contents/%'
  AND p0.path NOT LIKE '/Library/Apple/System/Library/%'
  AND p0.path NOT LIKE '/Library/Application Support/%/Contents/%'
  AND p0.path NOT LIKE '/System/Applications/%'
  AND p0.path NOT LIKE '/System/Library/%'
  AND p0.path NOT LIKE '/Users/%/Library/%.app/Contents/MacOS/%'
  AND p0.path NOT LIKE '/Users/%/code/%'
  AND p0.path NOT LIKE '/Users/%/src/%'
  AND p0.path NOT LIKE '/Users/%/bin/%'
  AND p0.path NOT LIKE '/System/%'
  AND p0.path NOT LIKE '/Users/%/Library/Caches/JetBrains/%/tmp/GoLand/___%'
  AND p0.path NOT LIKE '/opt/homebrew/Cellar/%/bin/%'
  AND p0.path NOT LIKE '/usr/libexec/%'
  AND p0.path NOT LIKE '/usr/sbin/%'
  AND p0.path NOT LIKE '/usr/local/kolide-k2/%'
  AND p0.path NOT LIKE '/private/var/folders/%/go-build%/%' -- Apple programs running from weird places, like the UpdateBrainService
  AND NOT (
    s.identifier LIKE 'com.apple.%'
    AND s.authority = 'Software Signing'
  )
  AND NOT exception_key IN (
    '0,AGSService,AGSService,Developer ID Application: Adobe Inc. (JQ525L2MZD),com.adobe.ags',
    '500,Authy,Authy,Apple iPhone OS Application Signing,com.authy',
    '500,Fleet,~/Library/Caches/JetBrains/Fleet',
    '500,IterableRichNotifications,IterableRichNotifications,Apple iPhone OS Application Signing,com.plexapp.plex.IterableRichNotifications',
    '500,Java Updater,Java Updater,Developer ID Application: Oracle America, Inc. (VB5E2TV963),com.oracle.java.Java-Updater',
    '500,Kindle,Kindle,TestFlight Beta Distribution,com.amazon.Lassen',
    '500,Paintbrush,Paintbrush,Developer ID Application: Michael Schreiber (G966ML7VBG),com.soggywaffles.paintbrush',
    '500,Plex,Plex,Developer ID Application: Plex Inc. (K4QJ56KR4A),tv.plex.desktop',
    '500,PlexMobile,PlexMobile,Apple iPhone OS Application Signing,com.plexapp.plex',
    '500,Realm,Realm,Apple iPhone OS Application Signing,camera.youpi.metareal',
    '500,trunk,trunk,Developer ID Application: Trunk Technologies, Inc. (LDR5F9BL92),trunk-cli',
    '500,java,java,Developer ID Application: Oracle America, Inc. (VB5E2TV963),com.oracle.java.8u401.java',
    '500,bash,bash,,bash',
    '500,Sky Go,Sky Go,Developer ID Application: Sky UK Limited (GJ24C8864F),com.bskyb.skygoplayer',
    '500,Skitch,Skitch,Developer ID Application: Skitch Inc (J8RPQ294UB),com.skitch.skitch',
    '500,cloud_sql_proxy,cloud_sql_proxy,,a.out',
    '500,git-remote-http,git-remote-http,,git-remote-http-55554944748a32c47cdc35cfa7f071bb69a39ce4',
    '500,melange,melange,,a.out',
    '500,node,node,Developer ID Application: Node.js Foundation (HX7739G8FX),node',
    '500,sdaudioswitch,sdaudioswitch,,sdaudioswitch',
    '500,snyk-ls_darwin_arm64,snyk-ls_darwin_arm64,,a.out',
    '500,syncthing,syncthing,,syncthing'
  )
  AND NOT alt_exception_key IN (
    '0,velociraptor,velociraptor,0u,0g',
    '0,velociraptor,velociraptor,0u,80g',
    '500,taplo,taplo,500u,20g',
    '500,nodegizmo,nodegizmo,500u,20g',
    '500,apko,apko,0u,0g',
    '500,apko,apko,500u,20g',
    '500,wolfibump,wolfibump,500u,20g',
    '500,wolfictl,wolfictl,0u,0g',
    '500,istioctl,istioctl,500u,20g',
    '500,aws,aws,0u,0g',
    '500,cargo,cargo,500u,80g',
    '500,chainctl,chainctl,0u,0g',
    '500,chainctl,chainctl,500u,20g',
    '500,chainlink,chainlink,500u,20g',
    '500,cilium,cilium,500u,123g',
    '500,cloud-sql-proxy,cloud-sql-proxy,500u,20g',
    '500,cosign,cosign,0u,500g',
    '500,snyk-macos-arm64,snyk-macos-arm64,500u,20g',
    '500,cosign,cosign,500u,20g',
    '500,cosign,cosign,500u,80g',
    '500,git-credential-osxkeychain,git-credential-osxkeychain,500u,80g',
    '500,cpu,cpu,500u,20g',
    '500,crane,crane,0u,500g',
    '500,crane,crane,500u,80g',
    '500,gh-dash,gh-dash,500u,20g',
    '500,git,git,0u,500g',
    '500,taplo-full-darwin-aarch64,taplo-full-darwin-aarch64,500u,20g',
    '500,git-remote-http,git-remote-http,500u,20g',
    '500,git-remote-http,git-remote-http,500u,80g',
    '500,istioctl,istioctl,,a.out',
    '500,gitsign,gitsign,500u,20g',
    '500,go,go,500u,80g',
    '500,vexi,vexi,500u,20g',
    '500,.man-wrapped,.man-wrapped,0u,500g',
    '500,pprof,pprof,500u,80g',
    '500,pulumi-resource-gcp,pulumi-resource-gcp,500u,20g',
    '500,sdaudioswitch,sdaudioswitch,500u,20g',
    '500,sdzoomplugin,sdzoomplugin,500u,20g',
    '500,vim,vim,0u,500g',
    '500,wolfictl,wolfictl,500u,20g'
  )
  AND NOT s.authority IN (
    'Developer ID Application: ANCHORE, INC. (9MJHKYX5AT)',
    'Developer ID Application: Adguard Software Limited (TC3Q7MAJXF)',
    'Developer ID Application: Adobe Inc. (JQ525L2MZD)',
    'Developer ID Application: AgileBits Inc. (2BUA8C4S2C)',
    'Developer ID Application: Bitdefender SRL (GUNFMW623Y)',
    'Developer ID Application: Brave Software, Inc. (KL8N8XSYF4)',
    'Developer ID Application: Canonical Group Limited (X4QN7LTP59)',
    'Developer ID Application: Corsair Memory, Inc. (Y93VXCB8Q5)',
    'Developer ID Application: Denver Technologies, Inc (2BBY89MBSN)',
    'Developer ID Application: Ecamm Network, LLC (5EJH68M642)',
    'Developer ID Application: Elasticsearch, Inc (2BT3HPN62Z)',
    'Developer ID Application: Farhan Ahmed (4RZN52RN5P)',
    'Developer ID Application: Fortinet, Inc (AH4XFXJ7DK)',
    'Developer ID Application: Google LLC (EQHXZ8M8AV)',
    'Developer ID Application: Hashicorp, Inc. (D38WU7D763)',
    'Developer ID Application: Kandji, Inc. (P3FGV63VK7)',
    'Developer ID Application: Kolide, Inc (X98UFR7HA3)',
    'Developer ID Application: Logitech Inc. (QED4VVPZWA)',
    'Developer ID Application: Michael Schreiber (G966ML7VBG)',
    'Developer ID Application: Microsoft Corporation (UBF8T346G9)',
    'Developer ID Application: PSI Services LLC (73AT498HPV)',
    'Developer ID Application: Panic, Inc. (VE8FC488U5)',
    'Developer ID Application: Quiet Riddle Ventures LLC (U68MSDN6DR)',
    'Developer ID Application: Rapid7 LLC (UL6CGN7MAL)',
    'Developer ID Application: Reflect App, LLC (789ULN5MZB)',
    'Developer ID Application: Slack Technologies, Inc. (BQR82RBBHL)',
    'Developer ID Application: Spotify (2FNC3A47ZF)',
    'Developer ID Application: SteelSeries (6WGL6CHFH2)',
    'Developer ID Application: Sublime HQ Pty Ltd (Z6D26JE4Y4)',
    'Developer ID Application: Tailscale Inc. (W5364U7YZB)',
    'Developer ID Application: Tenable, Inc. (4B8J598M7U)',
    'Developer ID Application: Valve Corporation (MXGJJ98X76)',
    'Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3)',
    'Developer ID Application: Zwift, Inc (C2GM8Y9VFM)'
  )
  AND NOT alt_exception_key LIKE '500,terraform-provider-%,terraform-provider-%,500u,20g'
  AND NOT alt_exception_key LIKE '500,plugin_host-%,plugin_host-%,500u,20g'
  AND NOT p0.path LIKE '/private/var/folders/%/T/GoLand/%'
  AND NOT (
    exception_key = '500,Python,Python,,org.python.python'
    AND p0_cmd LIKE '% main.py'
    AND p0_cwd LIKE "%/neko"
  )
  AND NOT (
    exception_key IN (
      '500,Python,Python,,org.python.python',
      '500,Python,Python,,Python',
      '500,Python,Python,,',
      '500,Python,Python,Developer ID Application: Python Software Foundation (BMM5U3QVKW),org.python.python',
      '500,Python,Python,0u,80g',
      '500,Python,Python,Developer ID Application: Ned Deily (DJ3H93M7VJ),org.python.python'
    )
    AND (
      p0_cmd LIKE '%/gcloud.py%'
      OR p0_cmd LIKE '%/google-cloud-sdk/bin/%'
      OR p0_cmd LIKE '%/google-cloud-sdk/platform/%'
      OR p0_cmd LIKE '%pip install%'
      OR p0_cmd LIKE '%googlecloudsdk/core/metrics_reporter.py%'
      OR p0_cmd LIKE '%/bin/aws%'
      OR p0_cmd LIKE "%/gsutil/gsutil %"
      OR p0_cwd LIKE "/Users/%/github/%"
      OR p0_cwd LIKE "/Users/%/src/%"
    )
  ) -- theScore and other iPhone apps
  AND NOT (
    s.authority = 'Apple iPhone OS Application Signing'
    AND p0.cwd = '/'
    AND p0.path = '/private/var/folders/%/Wrapper/%.app/%'
  ) -- nix socket inheritance
  AND NOT (
    p0.path LIKE '/nix/store/%/bin/%'
    AND p1.path LIKE '/nix/store/%/bin/%'
  )
GROUP BY
  p0.cmdline
