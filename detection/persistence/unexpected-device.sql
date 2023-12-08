-- Finds unexpected device names, sometimes used for communication to a rootkit
--
-- references:
--   * https://attack.mitre.org/techniques/T1014/ (Rootkit)
--
-- Confirmed to catch revenge-rtkit
--
-- false positives:
--   * custom kernel modules
--
-- tags: persistent filesystem state
-- platform: linux
SELECT -- Remove numerals from device names
  -- Ugly, but better than dealing with multiple rounds of nesting COALESCE + REGEX_MATCH
  DISTINCT REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(REPLACE(REPLACE(path, "0", ""), "1", ""), "2", ""),
                "3",
                ""
              ),
              "4",
              ""
            ),
            "5",
            ""
          ),
          "6",
          ""
        ),
        "7",
        ""
      ),
      "8",
      ""
    ),
    "9",
    ""
  ) AS path_expr,
  file.*
FROM
  file
WHERE
  (
    path LIKE '/dev/%'
    OR directory LIKE '/dev/%'
  )
  AND path_expr NOT IN (
    '/dev/acpi_thermal_rel',
    '/dev/autofs',
    '/dev/block/',
    '/dev/block/:',
    '/dev/bsg/',
    '/dev/bsg/:::',
    '/dev/btrfs-control',
    '/dev/bus/',
    '/dev/bus/usb',
    '/dev/cdrom',
    '/dev/cec',
    '/dev/char/',
    '/dev/char/:',
    '/dev/console',
    '/dev/core',
    '/dev/cpu/',
    '/dev/cpu_dma_latency',
    '/dev/cpu/microcode',
    '/dev/cros_ec',
    '/dev/cuse',
    '/dev/disk/',
    '/dev/disk/by-diskseq',
    '/dev/disk/by-dname',
    '/dev/disk/by-id',
    '/dev/disk/by-label',
    '/dev/disk/by-partlabel',
    '/dev/disk/by-partuuid',
    '/dev/disk/by-path',
    '/dev/disk/by-uuid',
    '/dev/dm-',
    '/dev/dma_heap/',
    '/dev/dma_heap/system',
    '/dev/dmmidi',
    '/dev/dri/',
    '/dev/dri/by-path',
    '/dev/dri/card',
    '/dev/dri/renderD',
    '/dev/drm_dp_aux',
    '/dev/dvd',
    '/dev/ecryptfs',
    '/dev/fb',
    '/dev/fd/',
    '/dev/full',
    '/dev/fuse',
    '/dev/gpiochip',
    '/dev/hidraw',
    '/dev/HID-SENSOR-e..auto',
    '/dev/hpet',
    '/dev/hugepages/',
    '/dev/mtd/',
    '/dev/mtd/by-name',
    '/dev/hugepages/libvirt',
    '/dev/hvc',
    '/dev/hwrng',
    '/dev/ic-',
    '/dev/iio:device',
    '/dev/initctl',
    '/dev/input/',
    '/dev/input/by-id',
    '/dev/input/by-path',
    '/dev/input/event',
    '/dev/input/js',
    '/dev/input/mice',
    '/dev/input/mouse',
    '/dev/kfd',
    '/dev/kmsg',
    '/dev/kvm',
    '/dev/libmtp--',
    '/dev/libmtp--.',
    '/dev/log',
    '/dev/loop',
    '/dev/loop-control',
    '/dev/lp',
    '/dev/mapper/',
    '/dev/mapper/control',
    '/dev/mcelog',
    '/dev/md',
    '/dev/md/',
    '/dev/md/ssdraid',
    '/dev/md/ssraid',
    '/dev/media',
    '/dev/mei',
    '/dev/mem',
    '/dev/midi',
    '/dev/mmcblk',
    '/dev/mqueue/',
    '/dev/mtd',
    '/dev/mtdro',
    '/dev/net/',
    '/dev/net/tun',
    '/dev/ngn',
    '/dev/null',
    '/dev/nvidia',
    '/dev/nvidia-caps/',
    '/dev/nvidia-caps/nvidia-cap',
    '/dev/nvidiactl',
    '/dev/nvidia-modeset',
    '/dev/nvidia-uvm',
    '/dev/nvidia-uvm-tools',
    '/dev/nvme',
    '/dev/nvme-fabrics',
    '/dev/nvmen',
    '/dev/nvmenp',
    '/dev/nvram',
    '/dev/port',
    '/dev/ppp',
    '/dev/pps',
    '/dev/psaux',
    '/dev/ptmx',
    '/dev/ptp',
    '/dev/pts/',
    '/dev/pts/ptmx',
    '/dev/random',
    '/dev/rfkill',
    '/dev/rpool/',
    '/dev/rpool/keystore',
    '/dev/rtc',
    '/dev/sda',
    '/dev/sdb',
    '/dev/serial/',
    '/dev/serial/by-id',
    '/dev/serial/by-path',
    '/dev/sg',
    '/dev/sgx_provision',
    '/dev/sgx_vepc',
    '/dev/shm/',
    '/dev/shm/i-log-',
    '/dev/shm/jack_db-',
    '/dev/shm/libpod_lock',
    '/dev/shm/libpod_rootless_lock_',
    '/dev/shm/pulse-shm-',
    '/dev/snapshot',
    '/dev/snd/',
    '/dev/snd/by-id',
    '/dev/snd/by-path',
    '/dev/snd/controlC',
    '/dev/snd/hwCD',
    '/dev/snd/midiCD',
    '/dev/snd/pcmCDc',
    '/dev/snd/pcmCDp',
    '/dev/snd/seq',
    '/dev/snd/timer',
    '/dev/sr',
    '/dev/stderr',
    '/dev/stdin',
    '/dev/stdout',
    '/dev/tpm',
    '/dev/tpmrm',
    '/dev/tty',
    '/dev/ttyACM',
    '/dev/ttyAMA',
    '/dev/ttyprintk',
    '/dev/ttyS',
    '/dev/ttyUSB',
    '/dev/ubuntu-vg/',
    '/dev/udmabuf',
    '/dev/uhid',
    '/dev/uinput',
    '/dev/urandom',
    '/dev/usb/',
    '/dev/usb/hiddev',
    '/dev/usbmon',
    '/dev/userfaultfd',
    '/dev/userio',
    '/dev/vboxdrv',
    '/dev/vboxdrvu',
    '/dev/vboxnetctl',
    '/dev/vboxusb/',
    '/dev/vcs',
    '/dev/vcsa',
    '/dev/vcsu',
    '/dev/vda',
    '/dev/vfio/',
    '/dev/vfio/vfio',
    '/dev/vg/',
    '/dev/vga_arbiter',
    '/dev/vg/root',
    '/dev/vg/swap',
    '/dev/vgubuntu/',
    '/dev/vgubuntu/root',
    '/dev/vgubuntu/swap_',
    '/dev/vhci',
    '/dev/vhost-net',
    '/dev/vhost-vsock',
    '/dev/video',
    '/dev/vl/',
    '/dev/vl/by-id',
    '/dev/vl/by-path',
    '/dev/vlloopback',
    '/dev/vportp',
    '/dev/watchdog',
    '/dev/wmi/',
    '/dev/wmi/dell-smbios',
    '/dev/zd',
    '/dev/zero',
    '/dev/zfs',
    '/dev/zram',
    '/dev/zvol/',
    '/dev/zvol/rpool'
  )
  AND NOT path LIKE '/dev/mapper/%'
  AND NOT path LIKE '/dev/shm/byobu-%'
  AND NOT path LIKE '/dev/shm/sem.rpc%'
  AND NOT path LIKE '/dev/mqueue/us.zoom.aom.%'
  AND NOT path LIKE '/dev/shm/aomshm.%'
  AND NOT path LIKE '/dev/shm/u%-Shm_%'
  AND NOT path LIKE '/dev/shm/.com.google.Chrome.%'
  AND NOT path LIKE '/dev/shm/u%-ValveIPC%'
  AND NOT path LIKE '/dev/%-vg/%-lv'
