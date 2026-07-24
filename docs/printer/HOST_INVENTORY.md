# Raspberry Pi host inventory

Audit date: 2026-07-24

This is a read-only snapshot of software and host-specific state that affects
the printer. It complements the active `.cfg` repository; it is not a request
to update or reinstall anything.

## Platform

| Item | Audited value |
| --- | --- |
| Computer | Raspberry Pi 4 Model B Rev 1.4 |
| Storage | 32 GB SD card; 29 GB root filesystem, 17 GB used, 12 GB free |
| Distribution | MainsailOS 2.2.2 |
| Operating system | Debian 12 Bookworm, 64-bit `aarch64` |
| Kernel | `6.12.93+rpt-rpi-v8` |
| Mainsail front end | v2.18.0 |
| Primary account/layout | `pi`, with printer data at `/home/pi/printer_data` |

The durable rebuild target is the latest supported 64-bit MainsailOS available
at recovery time. These versions are rollback evidence, not a reason to
reinstall an obsolete image.

## Printer software repositories

Commit prefixes identify the exact audited source. The version labels are
informational because upstream repositories will continue changing.

| Component | Path | Audited revision |
| --- | --- | --- |
| Klipper | `/home/pi/klipper` | `644cda5ecaa3` — `v0.13.0-573-g644cda5e` |
| Moonraker | `/home/pi/moonraker` | `1ed102edfb34` — `v0.10.0-19-g1ed102e` |
| Happy Hare | `/home/pi/Happy-Hare` | `a880ac0adccf` — `v3.4.2-22-ga880ac0a` |
| Crowsnest | `/home/pi/crowsnest` | `f606c69fb7ab` — `v5.0.6` |
| Mainsail config | `/home/pi/mainsail-config` | `ff3869a621db` — `v1.2.1-1-gff3869a` |
| Sonar | `/home/pi/sonar` | `0d1d7c89bbb9` — `v0.2.0-1-g0d1d7c8` |
| Moonraker Timelapse | `/home/pi/moonraker-timelapse` | `c7fff11e542b` — `v0.0.1-143-gc7fff11` |
| Printer configuration | `/home/pi/printer_data/config` | `55d240ea0243` at audit start, with later local work in progress |

The Spider, TradRack controller, and Raspberry Pi host MCU all reported the
same Klipper `v0.13.0-573` generation at the audit. If the physical MCUs have
not been reflashed, recovering with the audited Klipper commit first avoids an
unnecessary emergency MCU flash.

## Active services

The following important units are enabled:

- `klipper.service`
- `moonraker.service`
- `crowsnest.service`
- `nginx.service`
- `klipper-mcu.service`
- `ttsserver.service`
- `wifi_watchdog.timer`
- `sonar.service`

Klipper, Moonraker, Crowsnest, Nginx, the Linux host MCU, Talking Voron, and
the Wi-Fi watchdog timer were active during the audit. Sonar is installed and
enabled as a unit, but intentionally remains inactive because
[`sonar.conf`](../../sonar.conf) contains `enable: false`.

Core MainsailOS facilities such as SSH, NetworkManager, Avahi, time
synchronization, log rotation, and filesystem maintenance are also enabled.
They should be recreated by a fresh MainsailOS image rather than copied
piecemeal.

No `pi` user crontab entry was found. `BACKUP_CFG` is a manual action, not a
scheduled host backup.

## Dependencies outside the configuration repository

### Happy Hare

The active configuration depends on Happy Hare files outside the Git backup:

- Klipper MMU modules under `~/klipper/klippy/extras/` are symlinked into
  `~/Happy-Hare/extras/`.
- Moonraker's `mmu_server.py` component is symlinked into
  `~/Happy-Hare/components/`.
- Many files under `config/mmu/base/` and `config/mmu/optional/` are absolute
  symlinks into the Happy Hare checkout.
- The customized hardware, parameter, macro-variable, and generated
  `mmu_vars.cfg` state is in the public configuration repository.

Therefore restoring the configuration alone is insufficient. Happy Hare must
be installed and its links recreated before Klipper starts with the restored
configuration.

### Klipper Linux host MCU

`[mcu rpi]`, the ADXL345, and resonance testing require a Linux-process Klipper
MCU:

- unit: `/etc/systemd/system/klipper-mcu.service`
- binary: `/usr/local/bin/klipper_mcu`
- build configuration: `/home/pi/klipper/.config`
- serial endpoint: `/tmp/klipper_host_mcu`

The exact build configuration is preserved at
[`host-rebuild/klipper/host-mcu.config`](../../host-rebuild/klipper/host-mcu.config).
The host belongs to the `tty`, `spi`, `i2c`, `gpio`, `audio`, and `video`
groups needed by the current integrations.

Relevant current `/boot/firmware/config.txt` settings include:

```text
dtparam=spi=on
dtparam=audio=on
camera_auto_detect=1
arm_64bit=1
dtoverlay=dwc2,dr_mode=host
enable_uart=1
dtoverlay=disable-bt
dtparam=i2c_arm=on
```

These settings must be compared and merged into a future image. Never replace
a newer image's complete boot configuration with the old file.

### Klipper shell-command extension

The non-upstream file
`/home/pi/klipper/klippy/extras/gcode_shell_command.py` is required by:

- `BACKUP_CFG`
- Talking Voron `SAY`
- the audio volume command

Its audited SHA-256 is:

```text
59370a1e2fb604d4672c1c41b9e266906e596fdcdfafe46f5cf7904895841d29
```

It is the GPLv3 G-Code Shell Command extension attributed in the file to Eric
Callahan and distributed through KIAUH. It must be reinstalled after a fresh
Klipper installation and rechecked after Klipper updates.

### Talking Voron

Talking Voron is a custom, non-Git installation at
`/home/pi/talking_voron`:

- `ttsserver.py` runs as `ttsserver.service`.
- `say.sh` sends URL-encoded requests to `127.0.0.1:4601`.
- Python 3.11 virtual environment with `piper-tts==1.4.1`.
- Active voice: `en_US-amy-medium`.
- Also present but apparently unused:
  `en_GB-southern_english_female-low`.
- Generated WAV cache is disposable.
- Audio output uses ALSA `aplay`.

Credential-free source and service snapshots are preserved under
[`host-rebuild/talking-voron/`](../../host-rebuild/talking-voron/) and
[`host-rebuild/systemd/`](../../host-rebuild/systemd/). Voice models and the
virtual environment are deliberately not tracked.

The current server listens on `0.0.0.0:4601` and supports playing a
caller-supplied filename. Klipper uses it through localhost, but the service
is exposed to the LAN. Preserve this fact for recovery and perform a separate
hardening review rather than silently changing the live service.

### Wi-Fi watchdog

A custom watchdog, separate from Sonar, is active:

- script: `/home/pi/wifi_checker/wifi_watchdog.sh`
- unit: `/etc/systemd/system/wifi_watchdog.service`
- timer: `/etc/systemd/system/wifi_watchdog.timer`
- schedule: 30 seconds after boot and every 30 seconds thereafter
- behavior: tests `wlan0` and its default gateway, toggles the interface on
  failure, and may restart NetworkManager
- log: `/home/pi/printer_data/logs/wifi_watchdog.log`

Its source and units are preserved under
[`host-rebuild/`](../../host-rebuild/). A separate
`wifi_checker/sentinel/sentinel.sh` exists but no active service or schedule
was found for it.

### Camera

Crowsnest is active with the tracked
[`crowsnest.conf`](../../crowsnest.conf):

- `/dev/video0`
- ustreamer
- port 8080
- 1920×1080
- up to 30 FPS
- configured focus and dynamic-framerate controls

Installed camera packages include:

| Package | Version |
| --- | --- |
| `mainsail-ustreamer` | `6.61.bookworm` |
| `mainsail-spyglass` | `0.19.0.bookworm` |
| `mainsail-camera-streamer-raspi` | `0.4.2.2~bookworm` |

These are MainsailOS components; restore their configuration, not the current
binaries.

## Python environments and notable packages

Core virtual environments:

| Path | Purpose |
| --- | --- |
| `/home/pi/klippy-env` | Klipper host process |
| `/home/pi/moonraker-env` | Moonraker |
| `/home/pi/crowsnest-env` | Crowsnest tooling |
| `/home/pi/talking_voron/venv` | Piper Talking Voron |

Recreate all virtual environments through their installers. Do not archive and
restore an old venv across operating-system or Python changes.

Notable packages installed beyond the ordinary printer stack include
`bubblewrap`, `speedtest-cli`, `jq`, `plocate`/`locate`, `python3-pip`, and
`python3-venv`. `alsa-utils`, `curl`, `git`, `ffmpeg`, and Nginx are also
present. `bubblewrap` supports the local Codex environment; it is not required
for printing.

## Installed but inactive or optional

- Moonraker Timelapse is cloned and a configuration symlink exists, but its
  Klipper include, Moonraker component, and update-manager block are currently
  commented out.
- Blobifier files exist under `config/mmu/addons/`, but Blobifier is not yet
  included or active.
- VS Code Remote Server and OpenAI/Codex extensions are installed. They are
  development conveniences, not printer runtime dependencies.
- The current OpenAI Remote-SSH extension directories include
  `openai.chatgpt-26.721.30844-linux-arm64` and the older
  `openai.chatgpt-26.715.61943`. Reconnecting from VS Code should recreate the
  server; do not archive its roughly 4.2 GB installation.
- `/home/pi/collect_moonraker_disconnect_debug.sh` is a manual diagnostic
  helper with no discovered timer or service. Its credential-free source is
  preserved under `host-rebuild/diagnostics/`; generated diagnostic logs must
  remain private.
- `/home/pi/moonraker-sql.db_backup` is a July 13 standalone database artifact,
  not a current whole-host backup. `/home/pi/variables.cfg` is an empty legacy
  file. Neither should override current state during recovery.
- No KIAUH installation, Fluidd, Spoolman, Obico, OctoEverywhere,
  KlipperScreen, MoonCord, Docker, Podman, or Tailscale installation was found.

## What the public Git repository protects

The configuration repository protects:

- active printer, macro, LED, Moonraker, Crowsnest, Sonar, and MMU
  configuration
- mutable Happy Hare `mmu_vars.cfg` calibration and lane metadata
- `autocommit.sh` and the `BACKUP_CFG` macro
- authoritative printer documentation
- the credential-free custom host source snapshots added under
  `host-rebuild/`

It does **not** protect the target files of external symlinks, installed
software, service state, databases, credentials, or large operational data.

## Private backup scope

These items must stay outside the public Git repository:

| Path or state | Purpose | Treatment |
| --- | --- | --- |
| `/home/pi/printer_data/database/moonraker-sql.db` | Current Moonraker state, history, and client data | Back up privately with Moonraker stopped |
| Legacy `data.mdb` and `lock.mdb` | Older Moonraker LMDB state | Preserve privately until confirmed unnecessary |
| `/home/pi/printer_data/.moonraker.uuid` | Moonraker host identity | Private |
| `/home/pi/printer_data/moonraker.asvc` | Allowed service list | Private or regenerate |
| `/home/pi/gcode_files/` | 2.3 GB of G-code and thumbnails | Optional private archive |
| `/home/pi/printer_data/codex_uploads/` | 17 MB project/input archive | Optional private archive |
| `/home/pi/printer_data/logs/` | 140 MB diagnostics | Optional; not needed to rebuild |
| `/home/pi/printer_data/codex_backups/` | Local rollback material | Private; sanitize credentials |
| `/home/pi/moonraker-sql.db_backup` | Older standalone SQLite artifact | Preserve privately until superseded by a verified current backup |
| NetworkManager connection profiles | Wi-Fi and network credentials | Encrypted/private only |
| SSH private and host keys | Authentication and host identity | Encrypted/private only |
| Git credentials | GitHub write access | Recreate securely |
| `/home/pi/.codex/` | Authentication, sessions, and local state | Optional encrypted/private backup only |
| Piper voice models | Runtime voice data | Redownload, or privately archive |
| `/var/lib/alsa/asound.state` | Mixer state | Optional private reference |

Moonraker's SQLite database can contain sensitive information. Official
Moonraker documentation explicitly says database backups are not encrypted and
should not be kept in Moonraker-served storage.

## Local Git authentication

A credential-bearing HTTPS `origin` URL is present in two local, untracked Git
metadata files:

- the live configuration repository's `.git/config`
- the Git-repair rollback copy's nested `.git/config`

The credential is absent from tracked files and from the audited Git patch
history, so it was not found in the public repository. The owner reports that
no one else has access to the Raspberry Pi. On that basis this is local
authentication state, not evidence of compromise or a reason to stop using
`BACKUP_CFG`.

`.gitignore` is not relevant to the live file because it is Git's own
untracked metadata; the rollback copy is outside the repository root. Keep
both local/private. On a future fresh image, configure Git authentication
again rather than putting the credential into tracked content. Moving to SSH
or a credential helper remains optional housekeeping.

## Primary documentation

- [Mainsail installation overview](https://docs.mainsail.xyz/setup/)
- [MainsailOS project and included components](https://github.com/mainsail-crew/MainsailOS)
- [Klipper Raspberry Pi microcontroller](https://www.klipper3d.org/RPi_microcontroller.html)
- [Moonraker installation and database backup](https://moonraker.readthedocs.io/en/latest/installation/)
- [Happy Hare installation](https://github.com/moggieuk/Happy-Hare/wiki/Installation)
- [Crowsnest documentation](https://docs.mainsail.xyz/crowsnest/)
- [Sonar project](https://github.com/mainsail-crew/sonar)
- [Piper command-line installation and voices](https://github.com/OHF-Voice/piper1-gpl/blob/main/docs/CLI.md)
