# Current printer state

Last reconciled: 2026-07-23

This file records stable current facts. Active configuration remains the
implementation source of truth.

## Printer and host

- **Config-verified, user-confirmed:** Voron 2.4, 300 mm class, CoreXY.
  Configured travel is X300, Y300, Z280.
- **User-confirmed:** FYSETC Spider v1.1 main controller with TMC2209 drivers,
  using a conventional toolhead cable harness rather than CAN.
- **Runtime-validated:** Raspberry Pi 4 host running Debian 12 Bookworm.
- **Config-verified:** current configured nozzle is 0.4 mm and Klipper pressure
  advance is 0.02.
- **User-confirmed:** current extruder is BMGWW/WW-BMG.
- **User-confirmed, config-verified:** a Crossbow-style cutter is installed and
  cuts through Y-axis toolhead motion.
- **User-confirmed:** heater cartridge is reported as 24 V / 70 W.
- **Unresolved:** exact installed outer toolhead housing and exact hotend
  manufacturer/model. The measured geometry is Dragon-HF-style, but that does
  not establish the manufacturer.

Implementation: [printer.cfg](../../printer.cfg).

## Homing, mesh, and macros

- **Config-verified:** safe Z homing is X206 Y297.
- **Config-verified:** bed mesh spans X/Y 40-260, uses a 9x9 probe grid, and
  has a 5 mm adaptive margin.
- **Config-verified:** `PRINT_START` uses Klipper native adaptive meshing.
- **Config-verified:** custom `PRIME_LINE`, `REQUIRE_TRADRACK`, and Talking
  Voron speech/temperature-warning functionality are active.
- Prime-tower placement and adaptive-mesh coverage still need a permanent
  slicer-side solution; see [WORKLOG.md](WORKLOG.md).

Implementation: [printer.cfg](../../printer.cfg) and
[macros.cfg](../../macros.cfg).

## TradRack and Happy Hare

- **User-confirmed:** the TradRack has 14 physical lanes, but the enclosure can
  hold only 12 filaments.
- **Config-verified:** exactly 12 gates are enabled: gates 0-11. Gates 12 and
  13 are outside the operating scope. Old statistics keys do not make them
  active.
- **Config-verified:** TradRack 1.0e with a Binky encoder and USB-connected MMU
  controller.
- **User-confirmed, config-verified:** Filamentalist v3 spool handling with no
  separate filament-storage buffer (`has_filament_buffer: 0`).
- **Config-verified:** sensing includes the gate sensor, Binky encoder, a
  tension input, a sensor immediately before the extruder gears, and a sensor
  after the extruder gears. The Belay identity of the tension mechanism is
  **user-confirmed**.
- **Config-verified:** sync feedback and FlowGuard are enabled. Blobifier and
  standalone purging are disabled; the slicer purge tower currently owns
  in-print flushing.
- **Config-verified:** Spoolman integration is off. Gate material/color
  metadata is stored by Happy Hare and is not automatically synchronized to
  Orca.

Current CAD-derived geometry:

| Measurement | Value |
| --- | ---: |
| Extruder grip point to nozzle | 88.7 mm |
| Post-extruder sensor to nozzle | 76.5 mm |
| Toolhead entry sensor to extruder grip point | 9.3 mm |

Current headline movement settings:

| Operation | Speed | Acceleration |
| --- | ---: | ---: |
| Pull from spool | 130 mm/s | 100 mm/s² |
| Long unload | 180 mm/s | 150 mm/s² |
| Short move | 80 mm/s | 600 mm/s² |
| Extruder load/unload | 16 mm/s | Happy Hare runtime default |
| Synchronized load/unload | 18 mm/s | Happy Hare runtime default |

Other important current values:

- MMU gear run/hold current: 1.10 A / 0.20 A
- Gear homing speed: 20 mm/s
- Extruder homing speed: 18 mm/s
- Extruder force homing: enabled, maximum 80 mm
- Toolhead homing maximum: 50 mm
- Gate unload buffer and gate homing maximum: 80 mm
- FlowGuard relief: 80 mm; encoder mode: automatic
- Crossbow configured blade/retract/pushback inputs: 69.2 / 64.2 / 60 mm.
  Blade minus retract leaves a nominal 5 mm before runtime adjustments; actual
  executed moves can be shorter.
- Cutter pin: X4 Y20; fully compressed at X4 Y34
- Automatic retry after a failed toolchange: disabled

Selector offsets, encoder calibration, Bowden calibration, gate metadata, and
statistics are intentionally not duplicated here because they are mutable.
Read their live values from:

- [mmu_hardware.cfg](../../mmu/base/mmu_hardware.cfg)
- [mmu_parameters.cfg](../../mmu/base/mmu_parameters.cfg)
- [mmu_macro_vars.cfg](../../mmu/base/mmu_macro_vars.cfg)
- [mmu_vars.cfg](../../mmu/mmu_vars.cfg)

## Current MMU validation

- **Runtime-validated, user-confirmed, 2026-07-23:** the three-color articulated
  hermit-crab print completed.
- Happy Hare recorded 89/89 toolchange operations, zero pauses during the job,
  and a 59.7-second average complete swap.
- This validates the current T0/T1/T10 paths and start sequence. It does not
  validate every gate or every material.
- An earlier nonfatal unload encoder discrepancy remains something to monitor,
  but it did not interrupt the completed print.

Runtime evidence: `logs/mmu.log` in the `printer_data` root.

## OrcaSlicer workflows

- **User-confirmed:** OrcaSlicer 2.4.0 is the current slicer.
- **Runtime-validated:** TradRack printer profile:
  `Voron 2.4 300 - TradRack 12T`.
- Single-extruder multimaterial is enabled with 12 tools.
- Happy Hare owns loading, unloading, and Crossbow cutting. The proven
  generated G-code has Orca toolchange retraction, filament ramming, external
  loading/unloading speeds, and cooling moves disabled or set to zero.
- Working TradRack start order:

  ```text
  REQUIRE_TRADRACK
  MMU_START_SETUP ...
  MMU_START_CHECK
  M190 ...
  M109 ...
  PRINT_START ... SKIP_PRIME=1
  MMU_START_LOAD_INITIAL_TOOL
  PRIME_LINE
  ```

- A separate direct-feed printer profile is required because the printer is
  often used with Happy Hare disabled and filament supplied outside TradRack.
- The Orca presets currently live only on the PC and are not version-controlled
  on the Pi.

## Host services

- **Config-verified:** Crowsnest uses ustreamer on `/dev/video0`, port 8080,
  1920x1080, with a 30 FPS maximum.
- **User-confirmed historically:** direct Ethernet is configured around
  `192.168.50.2/24`; verify live interface state before network changes.
- Configuration Git root: `/home/pi/printer_data/config`.
- The repository is public; tracked documentation must contain no credentials.

Software versions and cumulative counters are deliberately omitted because
they change. Read versions from repository metadata and the latest successful
Klipper/Moonraker startup logs.

## Physical facts still needing confirmation

- Exact hotend manufacturer/model
- Exact outer toolhead housing
- Exact currently installed extruder motor
- Final PTFE segment and connector dimensions near the extruder
- Current physical contents of every lane
