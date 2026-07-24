# Raspberry Pi rebuild guide

Last reconciled: 2026-07-24

This guide rebuilds the current printer host from a fresh SD card while
preserving the existing Spider and TradRack-controller firmware. It was built
from a read-only live audit and official upstream documentation. It has **not**
been validated by performing a destructive reimage.

Do not execute backup, service, networking, update, or restore commands during
an active print. The steps below are a future recovery procedure, not work to
perform while the Blobifier part is printing.

The exact audited software snapshot is in
[`HOST_INVENTORY.md`](HOST_INVENTORY.md).

## Recovery strategy

1. Reinstall the ordinary stack from the latest supported 64-bit MainsailOS
   image.
2. Restore the public configuration repository.
3. Recreate external dependencies in a controlled order.
4. Restore machine-specific data only from an encrypted private backup.
5. Validate software without movement before enabling printer hardware.
6. Do not flash a physical MCU merely because the Raspberry Pi was rebuilt.

The recorded commit hashes are compatibility anchors. They are especially
important for Klipper because the host, Spider, TradRack controller, and Linux
host MCU were all on the `v0.13.0-573` generation at the audit.

Use the fresh image's Moonraker, Mainsail, Crowsnest, Sonar, and Nginx versions
first. Their audited revisions are rollback evidence if a compatibility
problem appears; do not automatically downgrade a healthy new base. Klipper
and Happy Hare are pinned during initial recovery because they directly touch
unchanged MCU firmware and the restored MMU configuration.

## Part A — prepare before a failure

Perform this only while the printer is idle.

### 1. Record how Git authentication will be recreated

The current token exists only in local, untracked Git metadata and a local
rollback copy. It was not found in tracked files or Git history, and the owner
reports that no one else has Raspberry Pi access. It can continue to be used
by `BACKUP_CFG`; rotation is not a recovery prerequisite.

For a future fresh image, choose one of:

- configure a new local token after cloning the public repository;
- use an SSH key stored privately; or
- use a secure credential helper.

Keep the current `.git/config` and Git-repair rollback directory local/private.
Never copy their authentication value into a tracked file or documentation.

The preferred clean remote is:

```text
git@github.com:EvripB/Voron24Configs.git
```

Use it only after the Raspberry Pi has a working GitHub SSH key. This is an
optional future authentication method, not a required change to the current
working setup.

### 2. Back up the public configuration

Review the repository before pushing:

```bash
git -C /home/pi/printer_data/config status --short
git -C /home/pi/printer_data/config diff --stat
git -C /home/pi/printer_data/config diff --cached --stat
git -C /home/pi/printer_data/config fsck --full
```

After the review, run `BACKUP_CFG` or use an equivalent explicit commit and
push.

`BACKUP_CFG` protects only the configuration repository. It is not an SD-card,
Moonraker-database, G-code, network, credential, or Codex backup.

### 3. Create an encrypted private backup

Use offline media or another computer. Do not put this archive anywhere inside
the public repository, and do not put Moonraker database backups in a
Moonraker-served directory.

Required:

- `/home/pi/printer_data/database/moonraker-sql.db`, copied only while
  `moonraker.service` is stopped
- `/home/pi/printer_data/.moonraker.uuid`
- `/home/pi/printer_data/moonraker.asvc`
- NetworkManager connection profiles
- the SSH key used for Git, or a plan to create a new one
- a clean record of the Git remote, without credentials

Preserve until verified unnecessary:

- legacy Moonraker `data.mdb` and `lock.mdb`
- the current
  `/home/pi/klipper/klippy/extras/gcode_shell_command.py`
- `/boot/firmware/config.txt` as a comparison reference
- `/var/lib/alsa/asound.state`

Optional:

- `/home/pi/gcode_files/`
- `/home/pi/printer_data/codex_uploads/`
- useful recent logs
- Piper voice models
- an encrypted copy of `/home/pi/.codex/`

To make the SQLite copy consistent, stop Moonraker while the printer is idle,
copy the file to private media, then start Moonraker again. The official
Moonraker documentation also provides database backup/restore APIs. Treat
every database backup as sensitive and unencrypted.

Do not archive Python virtual environments, VS Code Server, package caches,
generated WAV files, or installed Git repositories. They are larger and less
reliable than reinstalling from source.

### 4. Verify the private backup

Before relying on it:

1. List the archive without extracting it over live files.
2. Record file sizes and SHA-256 checksums.
3. Confirm the SQLite database, UUID, network recovery method, and Git
   authentication plan are present.
4. Store a second copy on a different device.

## Part B — rebuild a failed Raspberry Pi

### 1. Flash and bootstrap MainsailOS

1. Flash the latest supported 64-bit MainsailOS image for Raspberry Pi 4.
2. In Raspberry Pi Imager, create the user `pi`, enable SSH, and configure the
   required network.
3. Keep the Spider and TradRack controller unpowered or disconnected during
   host reconstruction.
4. Boot, connect through SSH, verify date/time and free space, and record the
   newly installed versions.
5. Do not use “Update All” yet. Establish the recovery baseline first.

MainsailOS already supplies Klipper, Moonraker, Mainsail, Crowsnest, Sonar,
Nginx, camera support, and their ordinary service environments.

### 2. Stop configuration-dependent services

Before placing the real configuration:

```bash
sudo systemctl stop klipper moonraker
```

Leave Nginx and SSH running so the host remains reachable.

### 3. Restore the public configuration repository

Preserve the fresh image's starter configuration under an unused backup name,
then clone the public repository to the exact expected path:

```bash
mv /home/pi/printer_data/config /home/pi/printer_data/config.factory
git clone https://github.com/EvripB/Voron24Configs.git /home/pi/printer_data/config
```

If `config.factory` already exists, choose another unused name instead of
overwriting it. Keep the clone's URL credential-free. Configure SSH write
access only after the read-only restore is working.

Verify:

```bash
git -C /home/pi/printer_data/config fsck --full
git -C /home/pi/printer_data/config status --short
```

Do not start Klipper yet: Happy Hare links, the shell-command extension, and
the host MCU are still missing.

### 4. Protect MCU protocol compatibility

If the Spider and TradRack controller still run the audited firmware, recover
Klipper at commit:

```text
644cda5ecaa39d0dcf797624c19d5425cb8121ec
```

On the fresh Klipper checkout, fetch and temporarily check out that commit
before connecting the controllers:

```bash
git -C /home/pi/klipper fetch --tags origin
git -C /home/pi/klipper switch --detach 644cda5ecaa39d0dcf797624c19d5425cb8121ec
```

A detached compatibility checkout is intentional during recovery. Plan a
coordinated host-and-MCU update later; do not mix that maintenance with the
rebuild.

### 5. Rebuild the Raspberry Pi host MCU

The active printer configuration requires `[mcu rpi]`.

1. Copy the tracked build configuration:

   ```bash
   install -m 0644 \
     /home/pi/printer_data/config/host-rebuild/klipper/host-mcu.config \
     /home/pi/klipper/.config
   ```

2. Install and enable Klipper's official service:

   ```bash
   cd /home/pi/klipper
   sudo cp ./scripts/klipper-mcu.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable klipper-mcu.service
   ```

3. Run `make menuconfig` and confirm the architecture is **Linux process**.
   Save without changing the captured configuration.
4. Following Klipper's official Raspberry Pi MCU procedure, build and install:

   ```bash
   cd /home/pi/klipper
   make flash
   ```

5. Confirm `/usr/local/bin/klipper_mcu` exists and the unit uses
   `/tmp/klipper_host_mcu`.

Compare the new `/boot/firmware/config.txt` with the settings recorded in
[`HOST_INVENTORY.md`](HOST_INVENTORY.md). Merge only missing SPI, I²C, UART,
audio, camera, USB-host, and Bluetooth settings. Never replace the complete
new boot file with the old one. Reboot once after any boot-setting change and
before host-MCU validation.

### 6. Reinstall Happy Hare

Clone and select the audited Happy Hare revision:

```bash
git clone https://github.com/moggieuk/Happy-Hare.git /home/pi/Happy-Hare
git -C /home/pi/Happy-Hare switch --detach a880ac0adccf532cf98a20567c47e10efdee5576
```

Because the tracked `mmu` configuration is already restored, use Happy Hare's
safe reinstall path. Skip its network self-update and service restart during
the staged recovery:

```bash
cd /home/pi/Happy-Hare
./install.sh -z -s
```

This should recreate the Klipper modules, Moonraker component, and absolute
configuration symlinks. Then inspect:

```bash
git -C /home/pi/printer_data/config status --short
find -L /home/pi/printer_data/config -type l -print
```

The second command should print only genuinely broken symlinks; investigate
each result. If the installer changed customized tracked files, compare them
carefully instead of discarding either version.

### 7. Restore the Klipper shell-command extension

Install KIAUH's **G-Code Shell Command** extension through its extension
manager, or restore the privately backed-up `gcode_shell_command.py` to:

```text
/home/pi/klipper/klippy/extras/gcode_shell_command.py
```

For the exact audited source, verify:

```text
SHA-256 59370a1e2fb604d4672c1c41b9e266906e596fdcdfafe46f5cf7904895841d29
```

Without this file, Klipper cannot load the shell-command sections used by
`BACKUP_CFG`, `SAY`, and audio volume control. Recheck it after any future
Klipper repair or update. KIAUH itself is not otherwise required by the
current printer.

### 8. Recreate Talking Voron

Install the ordinary dependencies:

```bash
sudo apt-get update
sudo apt-get install -y alsa-utils curl python3-venv
```

Deploy the tracked source:

```bash
mkdir -p /home/pi/talking_voron
install -m 0644 \
  /home/pi/printer_data/config/host-rebuild/talking-voron/ttsserver.py \
  /home/pi/talking_voron/ttsserver.py
install -m 0755 \
  /home/pi/printer_data/config/host-rebuild/talking-voron/say.sh \
  /home/pi/talking_voron/say.sh
```

Create a fresh environment and download the active voice:

```bash
python3 -m venv /home/pi/talking_voron/venv
/home/pi/talking_voron/venv/bin/python -m pip install --upgrade pip
/home/pi/talking_voron/venv/bin/python -m pip install \
  -r /home/pi/printer_data/config/host-rebuild/talking-voron/requirements.txt
cd /home/pi/talking_voron
./venv/bin/python -m piper.download_voices en_US-amy-medium
```

The fully pinned package snapshot is available as
`requirements.snapshot.txt`, but the minimal `piper-tts==1.4.1` requirement is
more likely to resolve cleanly on a future Python version.

Install but do not yet start the service:

```bash
sudo install -m 0644 \
  /home/pi/printer_data/config/host-rebuild/systemd/ttsserver.service \
  /etc/systemd/system/ttsserver.service
sudo systemctl daemon-reload
sudo systemctl enable ttsserver.service
```

The captured server listens on every interface. Restore it only on a trusted
LAN and put loopback-only/file-playback hardening on the post-recovery list.

### 9. Restore the Wi-Fi watchdog

Sonar is part of MainsailOS but is intentionally disabled by the tracked
`sonar.conf`. The current setup instead uses the custom watchdog:

```bash
mkdir -p /home/pi/wifi_checker
install -m 0755 \
  /home/pi/printer_data/config/host-rebuild/wifi-watchdog/wifi_watchdog.sh \
  /home/pi/wifi_checker/wifi_watchdog.sh
sudo install -m 0644 \
  /home/pi/printer_data/config/host-rebuild/systemd/wifi_watchdog.service \
  /etc/systemd/system/wifi_watchdog.service
sudo install -m 0644 \
  /home/pi/printer_data/config/host-rebuild/systemd/wifi_watchdog.timer \
  /etc/systemd/system/wifi_watchdog.timer
sudo systemctl daemon-reload
sudo systemctl enable wifi_watchdog.timer
```

Test it only with local console access available: it can deliberately cycle
`wlan0` and restart NetworkManager.

### 10. Verify the base web and camera stack

The fresh image should already contain Mainsail, Moonraker, Nginx, Crowsnest,
Sonar, and camera packages. Confirm:

- `config/mainsail.cfg` resolves to `~/mainsail-config/client.cfg`
- tracked `crowsnest.conf` is present
- `/dev/video0` appears when the camera is connected
- port 8080 is assigned to Crowsnest
- Moonraker sees its configured update-manager components

Moonraker Timelapse remains installed-but-inactive unless it is deliberately
commissioned later.

### 11. Restore private Moonraker and file state

With Moonraker stopped:

1. Restore `moonraker-sql.db` to `/home/pi/printer_data/database/`.
2. Restore `.moonraker.uuid` and `moonraker.asvc` if retaining the old
   identity and service permissions.
3. Set ownership to `pi:pi`.
4. Restore `/home/pi/gcode_files/` if it was archived.
5. Verify that `/home/pi/printer_data/gcodes` is a symlink to
   `/home/pi/gcode_files`; create it only if no conflicting file or directory
   exists.
6. Keep legacy LMDB files aside unless a specific recovery need is found.

Do not place the old `.git/config` in the public repository. A fresh clone can
be given new local authentication; retain the old metadata only inside a
private recovery archive if it is still useful.

### 12. Restore development access last

Reconnect through VS Code Remote SSH; VS Code will reinstall its server and
extensions. Reauthenticate Codex rather than placing old auth files in the
public repository. The printer's durable knowledge is already in
`config/docs/printer/`.

If the old Moonraker disconnect helper is still useful, deploy its tracked
source:

```bash
install -m 0755 \
  /home/pi/printer_data/config/host-rebuild/diagnostics/collect_moonraker_disconnect_debug.sh \
  /home/pi/collect_moonraker_disconnect_debug.sh
```

Its output under `/home/pi/disconnect_debug/` can contain network and printer
log details. Keep that output private.

The cloned-but-inactive Moonraker Timelapse repository is not required for
functional recovery. Recreate it at the revision in `HOST_INVENTORY.md` only
if retaining that dormant installation is useful, and leave its configuration
commented until separately commissioned.

## Part C — validation before movement

### 1. Static checks

With printer electronics still disconnected:

```bash
bash -n /home/pi/talking_voron/say.sh
bash -n /home/pi/wifi_checker/wifi_watchdog.sh
/home/pi/talking_voron/venv/bin/python -m py_compile \
  /home/pi/talking_voron/ttsserver.py
git -C /home/pi/printer_data/config fsck --full
find -L /home/pi/printer_data/config -type l -print
```

Confirm file ownership and that no private backup was placed under
`printer_data/config` or `gcode_files`.

### 2. Host-service checks

Start and inspect only the host-side dependencies first:

```bash
sudo systemctl start klipper-mcu ttsserver
systemctl is-active klipper-mcu ttsserver nginx crowsnest
```

Verify:

- `/tmp/klipper_host_mcu` exists
- `/home/pi/talking_voron/say.sh "Rebuild test"` speaks once through localhost
- the Mainsail page loads
- the camera stream loads
- no unexpected service restart loop appears in the journal

Start Moonraker and confirm its database and file roots load. Klipper may
correctly report missing physical MCUs until they are connected.

### 3. Connect controllers without motion

1. Power down before reconnecting USB/power to the Spider and TradRack
   controller.
2. Power up and start Klipper.
3. Confirm all three MCU version/protocol reports match the intended recovery
   generation.
4. Confirm Happy Hare loads and inspect its sensors/state without sending
   selector, cutter, load, unload, heater, or motion commands.
5. Confirm the active configuration contains exactly 12 operational gates,
   0-11.

Do not flash the Spider or MMU controller unless a genuine protocol mismatch
remains after the host has been restored to the recorded Klipper commit.

### 4. Controlled return to service

Only after the non-moving checks pass:

1. Validate emergency stop and temperature readings.
2. Perform supervised homing with the bed clear.
3. Validate the host accelerometer separately.
4. Test Talking Voron, camera, and Git backup independently.
5. Perform a small direct-feed print before an MMU print.
6. Perform an MMU sensor/gate check before a full load or toolchange.

Record any deviation from this guide in
[`HOST_INVENTORY.md`](HOST_INVENTORY.md), [`CURRENT.md`](CURRENT.md), or
[`HISTORY.md`](HISTORY.md) as appropriate.

## Official references

- [Mainsail installation overview](https://docs.mainsail.xyz/setup/)
- [MainsailOS included components](https://github.com/mainsail-crew/MainsailOS)
- [Klipper Raspberry Pi MCU procedure](https://www.klipper3d.org/RPi_microcontroller.html)
- [Moonraker installation and database backup](https://moonraker.readthedocs.io/en/latest/installation/)
- [Happy Hare installation](https://github.com/moggieuk/Happy-Hare/wiki/Installation)
- [KIAUH G-Code Shell Command extension host](https://github.com/dw-0/kiauh)
- [Piper CLI and voice download](https://github.com/OHF-Voice/piper1-gpl/blob/main/docs/CLI.md)
