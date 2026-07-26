# Current printer state

Last reconciled: 2026-07-27

This file records stable current facts. Active configuration remains the
implementation source of truth.

## Printer and host

- **Config-verified, user-confirmed:** Voron 2.4, 300 mm class, CoreXY.
  Configured travel is X300, Y300, Z280.
- **User-confirmed, config-verified:** FYSETC Spider v1.1 main controller with
  an STM32F446 MCU and TMC2209 drivers, using a conventional toolhead cable
  harness rather than CAN.
- **Runtime-validated:** Raspberry Pi 4 host running Debian 12 Bookworm.
- **User-confirmed:** the installed 24 V supply is a Mean Well LRS-200-24.
  There is no standalone 5 V supply. The Raspberry Pi is powered through its
  USB-C input by an official Raspberry Pi USB-C power supply, selected for its
  current capacity and known compatibility with the Pi.
- **User-confirmed, config-verified:** the current nozzle is a generic
  AliExpress 0.4 mm brass nozzle; it is neither hardened nor CHT. Klipper
  pressure advance is 0.02.
- **User-confirmed:** current extruder is BMGWW/WW-BMG driven by an
  LDO-36STH20-1004AHG motor.
- **User-confirmed, config-verified:** A/B use two
  LDO-42STH40-2004MAC(VRN) motors in the configured 0.9-degree setup; Z uses
  four LDO-42STH48-2004AC(VRN) motors.
- **User-confirmed:** the 300 mm frame is LDO, motion uses Gates GT2 belts,
  the cable chains are IGUS, and the enclosure panels are acrylic.
- **User-confirmed:** X and Y home against a Hall-effect XY-endstop board.
- **User-confirmed:** all eight original RobotDigg MGN9H 350 mm rails remain
  installed. The X axis retains the earlier dual-MGN9 arrangement and has not
  been converted to a single MGN12 rail.
- **User-confirmed, config-corroborated:** the toolhead housing is an A4T with
  two 4010 part-cooling blowers and one 2510 axial hotend fan.
- **User-confirmed:** current hotend is a Trianglelab Dragon Hotend V2.0 High
  Flow with a Trianglelab Melt Zone Extender (MZE). The configured and
  user-confirmed thermistor is an ATC Semitec 104GT-2.
- **User-confirmed, config-verified:** a Crossbow-style cutter is installed and
  cuts through Y-axis toolhead motion.
- **User-confirmed:** the current heater cartridge is a generic 24 V / 70 W
  AliExpress unit; its manufacturer and exact model are unknown.
- **User-confirmed:** the bed stack is a 300 x 300 x 8 mm MIC6 plate, Keenovo
  290 x 290 mm 230 V AC heater, Graviflex magnet, and removable spring steel.
  The active Energetic plate has smooth and textured PEI sides; it is damaged
  but serviceable. An unused Fermiolab single-sided plate is the spare.
- **User-confirmed:** the bed relay is an A-Senco `SSR-500`-series unit. The
  purchase record identifies `SSR-500-1DA48-10`, 230 V AC / 10 A. This is the
  recorded service identity and no further SSR-identification task is active.
  The heater assembly's thermal-protection details remain unknown.
- **User-confirmed, config-corroborated:** the electronics bay is cooled by
  two Gdstime GDA6020 dual-ball-bearing 24 V / 0.1 A fans, one on each side.

Implementation: [printer.cfg](../../printer.cfg). Detailed physical inventory:
[HARDWARE_INVENTORY.md](HARDWARE_INVENTORY.md).

## Homing, mesh, and macros

- **Config-verified:** safe Z homing is X206 Y297.
- **User-confirmed, config-verified:** QGL and bed meshing use an Omron
  TL-Q5MC2-Z inductive probe mounted at X0 Y+20 relative to the nozzle. It is
  not the printer's Z reference; Z homes against the mechanical endstop.
- **Runtime-validated, user-confirmed (2026-07-25):** after centering the
  nozzle over the mechanical Z-endstop pin, a cold paper
  `Z_ENDSTOP_CALIBRATE` saved `stepper_z.position_endstop` as 1.200 mm,
  replacing 1.160 mm. The unchanged 200x80 mm ABS test then produced a
  top-notch first layer across the bed, confirming that the prior uniform
  gaps came from the 0.040 mm Z-reference error.
- **Runtime-loaded, runtime-validated (2026-07-25):** the bed-mesh envelope
  spans X15-285 and Y40-260 with an 11x9 grid and 5 mm adaptive margin. The
  Y40 boundary keeps the Crossbow depressor outside the probing path. A hot
  105 C full-width test completed safely with this geometry, and the
  subsequent firmware restart loaded the new limits cleanly.
- **Runtime-validated, user-confirmed (2026-07-25):** the first full-width
  mesh exposed a +0.327 mm front-right spike caused by raised peeled-coating
  edges on the underside of the Energetic sheet. After trimming those edges,
  cleaning the sheet, and reseating it in the same orientation, the repeated
  full mesh measured only 0.1025 mm peak-to-valley and the spike disappeared.
- **Runtime-loaded, pending print validation (2026-07-24):** `PRINT_START`
  supports two mesh paths. Calls that omit `MESH_MODE` retain Klipper native
  adaptive meshing; the TradRack Orca profile supplies Orca's complete
  first-layer bounds with `MESH_MODE=ORCA` and names the resulting runtime
  profile `adaptive_orca`.
- **User-confirmed (2026-07-25):** the TradRack Orca profile now matches
  Klipper's X15-285/Y40-260 mesh limits while retaining 27.5 mm probe-point
  distance and a 5 mm margin.
- **Config-verified:** custom `PRIME_LINE`, `REQUIRE_TRADRACK`, and Talking
  Voron speech/temperature-warning functionality are active.
- **Runtime-validated, user-confirmed:** `MMU_HOME_SAFE` provides an update-safe
  Mainsail homing control that moves only when Happy Hare reports filament as
  confirmed unloaded (`filament_pos == 0`).
- The new macro configuration loaded cleanly after restart. A two-tool Orca
  export has also passed the generated-parameter and tower-coverage audit; an
  actual probing run still needs validation, and tower placement still needs
  to be retained in a reusable starter 3MF; see [WORKLOG.md](WORKLOG.md).

Implementation: [printer.cfg](../../printer.cfg) and
[macros.cfg](../../macros.cfg).

## TradRack and Happy Hare

- **User-confirmed:** the TradRack has 14 physical lanes, but the enclosure can
  hold only 12 filaments.
- **Config-verified:** exactly 12 gates are enabled: gates 0-11. Gates 12 and
  13 are outside the operating scope. Old statistics keys do not make them
  active.
- **User-confirmed, config-verified:** Trianglelab shipped the TradRack 1.0e
  kit with a Binky encoder and FYSETC ERB v2 controller. The ERB uses its
  RP2040 MCU and is connected over USB.
- **User-confirmed, config-verified:** twelve Filamentalist FV3 passive
  rewinders provide spool handling, one for each commissioned gate, inside the
  actively heated filament enclosure. Happy Hare is correctly configured with
  no separate filament-storage buffer (`has_filament_buffer: 0`).
- **User-confirmed, config-verified:** the Annex Belay mechanism supplies the
  one-sided tension input on ERB `gpio12`. Happy Hare—not Annex's standalone
  Belay Klipper module—owns synchronization and FlowGuard. The active
  configuration has no `[belay]` section or Belay update manager.
- **Config-verified:** the remaining sensing includes the Binky encoder, a
  sensor immediately before the extruder gears, and a sensor after the
  extruder gears. No shared gate switch or twelve per-gate switches are
  assigned in the active ERB aliases.
- **Config-verified:** sync feedback and FlowGuard are enabled. Blobifier and
  standalone purging are disabled; the slicer purge tower currently owns
  in-print flushing.
- **Config-verified, runtime-observed:** Happy Hare has
  `unload_tool_on_cancel = False`. Cancelling a print parks the toolhead but
  intentionally leaves the selected filament loaded; use a normal
  `MMU_UNLOAD` when an unload is wanted after cancellation.
- **Config-verified:** Spoolman integration is off. Gate material/color
  metadata is stored by Happy Hare and is not automatically synchronized to
  Orca.
- **User-confirmed:** all PTFE from TradRack through the WW-BMG entrance is
  ID3/OD4. The only ID2/OD4 segment is approximately 14 mm long between the
  extruder and hotend.

Current CAD-derived geometry:

| Measurement | Value |
| --- | ---: |
| Extruder grip point to nozzle | 88.7 mm |
| Post-extruder sensor to nozzle | 76.5 mm |
| Toolhead entry sensor to extruder grip point | 9.3 mm |

Current headline movement settings:

| Operation | Speed | Acceleration |
| --- | ---: | ---: |
| Pull from spool | 350 mm/s | 300 mm/s² |
| Long unload | 350 mm/s | 300 mm/s² |
| Short move | 80 mm/s | 600 mm/s² |
| Extruder load/unload | 16 mm/s | Happy Hare runtime default |
| Synchronized load/unload | 18 mm/s | Happy Hare runtime default |

Other important current values:

- MMU gear run/hold current: 1.10 A / 0.20 A
- Gear homing speed: 20 mm/s
- Extruder homing speed: 18 mm/s
- Extruder force homing: enabled, maximum 80 mm
- Toolhead homing maximum: 50 mm
- **Runtime-validated, user-confirmed:** gate unload buffer remains 80 mm and
  gate homing maximum is 100 mm, restoring 20 mm of slow-homing reserve. A
  full T10 manual unload completed successfully with the new limit.
- **Config-verified, runtime-validated:** FlowGuard relief remains 80 mm and
  encoder mode remains automatic. After the loose WW-BMG latch was corrected,
  the Blobifier-tray retry ran for 39 minutes 49 seconds with extruder
  synchronization enabled, cycled normally between tension and neutral, and
  reached Z2 without another FlowGuard trip. Retain 80 mm unless the warning
  becomes reproducible with the extruder latch and filament path confirmed
  secure.
- Crossbow configured blade/retract/pushback inputs: 69.2 / 64.2 / 60 mm.
  Blade minus retract leaves a nominal 5 mm before runtime adjustments; actual
  executed moves can be shorter.
- Cutter pin: X4 Y20; fully compressed at X4 Y34
- **Runtime-validated, user-confirmed:** full unloads invoke
  `_CROSSBOW_SAFE_APPROACH`. From X20 or left it clears laterally to X20
  before moving to Y15; from right of X20 it moves diagonally to X20 Y15. The
  stock cutter then moves laterally to X4 and performs its Y15-Y34 stroke. A
  complete T10 manual unload validated the integrated cut and transport path.
- **Runtime-validated, user-confirmed:** immediately after cutting,
  `_CROSSBOW_SAFE_DEPARTURE` moves laterally from the cutter's X4 Y15 park
  position to X20 Y15 through Happy Hare's `user_post_form_tip_extension`.
  This clears the fixed depressor before Happy Hare restores diagonally toward
  the saved position. A supervised X4 Y15 to X20 Y15 departure and subsequent
  X150 Y280 restore test validated the route.
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
- **Runtime-validated, user-confirmed, 2026-07-26:** gate 2 completed twelve
  supervised full load/unload cycles with the calibrated selector-servo
  down/grip angle at 1 degree. The trial used three cycles each at the former
  130/100-load and 180/150-unload baseline, 300/100, 300/200, and the selected
  350 mm/s at 300 mm/s² final setting. Gate 2's nearly full Filamentalist spool
  remained controlled, all encoder and toolhead sensing completed without a
  warning, and the final setting reduced the observed standalone cycle from
  about 65 seconds to about 49 seconds. This validates the new long-transport
  setting on gate 2 only; monitor other gates during production toolchanges.
- An earlier nonfatal unload encoder discrepancy remains something to monitor,
  but it did not interrupt the completed print.

Runtime evidence: `logs/mmu.log` in the `printer_data` root.

The archived source documents, ERB v2 pin map, supplier kit lists, and
printer-specific pin reconciliation are indexed in
[TRADRACK_REFERENCE.md](TRADRACK_REFERENCE.md).

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
- The manual lane-sync convention, current audit, and preset handoff procedure
  are recorded in [`slicer/orca/README.md`](../../slicer/orca/README.md).

## Host services

- **Runtime-validated:** MainsailOS 2.2.2 on 64-bit Debian 12 Bookworm,
  Raspberry Pi 4. The dated software/service snapshot is in
  [HOST_INVENTORY.md](HOST_INVENTORY.md).
- **Config-verified:** Crowsnest uses ustreamer on `/dev/video0`, port 8080,
  1920x1080, with a 30 FPS maximum.
- **Runtime-validated:** the Raspberry Pi Linux host MCU, Talking Voron
  service, and custom 30-second Wi-Fi watchdog timer are active. Sonar is
  installed but disabled by configuration.
- **Config-verified, host-audited:** `BACKUP_CFG`, Talking Voron, and audio
  volume control require the non-upstream Klipper G-Code Shell Command
  extension.
- **User-confirmed historically:** direct Ethernet is configured around
  `192.168.50.2/24`; verify live interface state before network changes.
- Configuration Git root: `/home/pi/printer_data/config`.
- The repository is public; tracked documentation must contain no credentials.
- **Host-audited, owner-confirmed private:** Git write authentication is stored
  in the untracked local `origin` metadata and one local Git-repair rollback
  copy. It was not found in tracked files or audited Git history, and no one
  else has access to the Raspberry Pi. This is not evidence of a public leak
  and does not block `BACKUP_CFG`.

The full installation and private-backup boundary are documented in
[RPI_REBUILD.md](RPI_REBUILD.md). Dynamic versions and cumulative counters
remain snapshots rather than configuration truth.

## Physical facts still needing confirmation

- Bed thermal-protection type, trip rating, location, and wiring
