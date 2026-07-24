# Host rebuild assets

These are credential-free source snapshots for custom Raspberry Pi components
that are not recreated by a normal MainsailOS installation.

They are **not** the live files. Editing this directory does not change the
running printer. Deployment and validation are documented in
[`../docs/printer/RPI_REBUILD.md`](../docs/printer/RPI_REBUILD.md).

Captured from the live host on 2026-07-24:

| Asset | Live destination | SHA-256 of captured live file |
| --- | --- | --- |
| `talking-voron/ttsserver.py` | `/home/pi/talking_voron/ttsserver.py` | `826732c27347a41860e6abe0fe72b5fadc3a027a31012876d70ba836242c414c` |
| `talking-voron/say.sh` | `/home/pi/talking_voron/say.sh` | `95176e60ee43e1c327800b38e80cee8a7fa675be67c45866c4220b75a95b2005` |
| `systemd/ttsserver.service` | `/etc/systemd/system/ttsserver.service` | `f15a80531fd4293de372a82644e52d629f9757cf4b49adf5cde5628c5b72e4df` |
| `wifi-watchdog/wifi_watchdog.sh` | `/home/pi/wifi_checker/wifi_watchdog.sh` | `b2a405aa0f4ebd556e40630a5a09d18bf835761315ee69e9f8011ab3aee78f7e` |
| `systemd/wifi_watchdog.service` | `/etc/systemd/system/wifi_watchdog.service` | `06474ce751e413222d70bc93b5fc145c7bb116be7ecfda0b58edfd85daf7da95` |
| `systemd/wifi_watchdog.timer` | `/etc/systemd/system/wifi_watchdog.timer` | `e30e5bafc14c4338ecd7343045f13a8db24958f338878128420521fd9c1a153f` |
| `klipper/host-mcu.config` | `/home/pi/klipper/.config` | `8cc82b73f827059a2cb3580018525a8c7f0659fb5cdce75c03ed251f4e6ee094` |
| `diagnostics/collect_moonraker_disconnect_debug.sh` | `/home/pi/collect_moonraker_disconnect_debug.sh` | `84d887e0ecfa6937c79dfe25c21fa629b05069721ad7a32904c997f0140209e9` |

The Piper voice models, generated WAV cache, Python virtual environment,
Moonraker database, network profiles, SSH keys, Git credentials, and Codex
state are deliberately absent. Download reproducible voice models again and
keep machine-specific state in an encrypted private backup.

The diagnostic helper is safe to publish, but the logs it generates can
contain IP addresses, network details, and printer logs. Keep its
`/home/pi/disconnect_debug/` output private.

The current Talking Voron server binds to all interfaces and accepts a request
that names an audio file. That behavior is preserved here for an exact source
snapshot, but it should only be restored on a trusted network. A separate
hardening review should restrict it to loopback and constrain file playback
before treating it as suitable for an untrusted LAN.

