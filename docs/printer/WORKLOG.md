# Active work

Last updated: 2026-07-25

An intermittent gate-10 transport and toolhead-reach fault is under
investigation. The July 23 multicolor print remains the successful 89/89
toolchange baseline.

## Next

### 1. Correct, align, and export Orca presets

- The PLA/PETG ABS-parent fault was repaired in the native JSON while
  preserving the existing temperatures, 25 mm3/s limits, and all seven
  TradRack zero-motion fields. The owner copied the corrected files into Orca
  on Windows; re-audit the eventual native export before archiving it.
  `ABS - TradRack` has already passed the same parent/ownership audit.
- Audit material-specific temperatures, cooling, flow, and maximum volumetric
  speed. The current values—ABS 20 mm3/s and PLA/PETG 25 mm3/s—are profile
  limits, not completed calibrations for every brand/color.
- **User-confirmed complete:** the fixed slot-1-to-T0/G0 through
  slot-12-to-T11/G11 convention now has the intended Orca colors and material
  profiles assigned. Recheck it only if lane contents change or a native
  preset export exposes a mismatch.
- Export and archive the actual Orca assets for:
  - `Voron 2.4 300 - TradRack 12T`
  - the direct-feed printer profile
  - the associated process and filament presets
- Save a reusable 12-slot starter 3MF so project-level lane colors and tower
  placement are retained.
- Use the workflow and tracked destination documented in
  [`slicer/orca/README.md`](../../slicer/orca/README.md).
- Audit generated G-code before printing. The current crab G-code proves the
  TradRack start sequence, not the correctness of every preset.

### 2. Make prime-tower placement persistent

- Orca 2.4 stores the tower position per project/plate, not in an ordinary
  printer or process preset. Put the lane setup and tower into the reusable
  TradRack starter 3MF.
- The prior X188 Y52 candidate refers to Orca's exported internal tower
  anchor, not necessarily the visual center shown by the plate-move UI.
  Position and verify the actual Preview footprint plus its margin inside
  X/Y40-260; recheck after changing tower or purge geometry.
- The backward-compatible `MESH_MODE=ORCA` implementation is loaded in
  `PRINT_START`, and the TradRack printer has mesh limits 40,40 to 260,260,
  probe distance 27.5,27.5, margin 5, and a start line that passes Orca's
  calculated bounds/count/algorithm. Direct-feed starts remain on Klipper
  native adaptive meshing.
- The configuration restarted cleanly on July 24. Slice a small two-tool job
  and verify its generated `PRINT_START` parameters and runtime mesh bounds
  before considering the Orca path print-validated.
- The first exported two-tool test correctly resolved `MESH_MIN`,
  `MESH_MAX`, `PROBE_COUNT=7,7`, and `MESH_ALGORITHM=bicubic`, but it also
  demonstrated the physical probe-limit constraint. With the tower at about
  X55.453 Y27.211, its first-layer extrusion reached Y21.183 while Orca had
  to clamp the mesh minimum to Y40. Moving the visual center to Y55 only moved
  the internal anchor to Y40.75 and left first-layer extrusion down to
  Y34.722.
- The corrected export with the tower's displayed center at Y70 passes the
  slicer-side audit. It resolves a mesh of X43.9577-186.268,
  Y42.7218-180.14, `PROBE_COUNT=7,6`, and `bicubic`; the tower's actual
  first-layer extrusion is X50.957-119.949 and Y49.722-90.278. The Happy Hare
  start order is preserved. Validate those bounds during the actual probing
  run before calling the new path runtime-validated.
- The measured positions and limitation are documented in
  [`slicer/orca/README.md`](../../slicer/orca/README.md).

### 3. Review the completed crab print

- Inspect color contamination, tower stability, surface quality, and actual
  waste before reducing flushing further.
- Current test settings included a 0.7 flushing multiplier and flushing into
  object infill.
- Reliability result: 89/89 toolchange operations, zero job pauses, average
  complete swap 59.7 seconds.

### 4. Calibrate ABS flow ratio; first-layer gaps resolved

- The July 25 FlowGuard test G-code uses `filament_flow_ratio = 0.926` for
  `ABS - TradRack`.
- The first layer showed visible gaps despite a live Z adjustment, while the
  second layer appeared correct and the encoder flowrate stabilized at 100%.
- The generated first layer is 0.20 mm high and 0.50 mm wide at up to
  105 mm/s. Its actual extrusion commands include the 0.926 filament ratio;
  `first_layer_flow_ratio = 1` is a multiplier and does not replace it.
- **Runtime-validated, user-confirmed:** a cold paper
  `Z_ENDSTOP_CALIBRATE` performed after correcting the mechanical endstop
  contact XY saved `stepper_z.position_endstop = 1.200`, replacing 1.160.
  The unchanged 200x80 mm test then produced a top-notch first layer across
  the bed. The severe uniform gaps were therefore a 0.040 mm Z-reference
  error, not evidence that the ABS filament ratio was wrong.
- Retain 0.926 for normal printing until Orca's Flow Rate Pass 1 and Pass 2
  calibrate the current ABS independently. Do not use the now-resolved first
  layer as a reason to increase either the base or first-layer flow ratio.

### 5. Complete and validate the Raspberry Pi recovery plan

Completed documentation:

- Read-only audit of the OS, packages, enabled units, repositories, Python
  environments, Happy Hare links, Linux host MCU, camera, Talking Voron,
  Wi-Fi watchdog, data roots, and optional development tools.
- Dated inventory:
  [`HOST_INVENTORY.md`](HOST_INVENTORY.md).
- Fresh-image recovery and non-moving validation procedure:
  [`RPI_REBUILD.md`](RPI_REBUILD.md).
- Credential-free source snapshots for custom services and the Linux host-MCU
  build configuration under [`host-rebuild/`](../../host-rebuild/).

Pending while the printer is idle:

- Create and verify an encrypted private backup of Moonraker's SQLite
  database, UUID/service state, network recovery data, Git authentication,
  and any desired G-code/uploads.
- Perform a separate Talking Voron hardening review. Its current service
  listens on all interfaces and accepts an audio filename.
- Treat the rebuild guide as audit-backed but not end-to-end tested until a
  spare-card recovery or actual reimage validates it.

## Monitor

### Intermittent gate-10 transport and toolhead reach

The July 24 attempts exposed more than one failure mode under otherwise
unchanged static configuration:

- Some long gate-10 moves produced almost no encoder movement, demonstrating
  intermittent pickup/drive/path loss near the TradRack.
- The cleanest later load produced full encoder movement but stopped just
  short of the pre-extruder sensor. This is consistent with variable slack or
  a downstream transition/sensor problem rather than encoder-measured
  underfeed on that attempt.
- The July 25 print-end unload cleared the Bowden path but initially failed to
  clear the encoder within the configured limit. Automatic recovery then
  confirmed the encoder clear and set the state to unloaded.
- **Runtime-validated, user-confirmed:** `gate_unload_buffer` remains 80 mm
  and `gate_homing_max` is 100 mm, restoring 20 mm of slow-homing reserve. A
  full T10 manual unload after the first-layer test cleared the encoder and
  completed successfully.
- Gate 10 has now produced both load and unload failures. A prior unload also
  showed 1937.4 mm commanded versus 1916.3 mm encoder movement. Treat these as
  part of the same intermittent transport investigation, not a separate
  monitor-only item.

Pending:

- Inspect gate-10 selector alignment, drive engagement, filament grinding,
  spool drag, and servo action.
- Inspect the long loose-ID Bowden, reducer/connector lips, PTFE seating, ECAS
  entrance, and pre-extruder sensor operation.
- Re-establish a known unloaded state before controlled comparisons with
  another gate and a fixed toolhead position.
- Continue to treat any future pickup or grinding faults as separate
  mechanical problems rather than increasing unload distance again.

### FlowGuard false compression trip

A sustained solid-infill segment produced a tension-only Belay/FlowGuard
`Compression stuck` warning at 80.19 mm of modeled relief. The preceding
open-sensor interval reached approximately 78.4 mm before tension returned,
leaving essentially no margin at the current 80 mm threshold.

Pending action, while the printer is idle:

- Verify Belay travel, switch actuation, PTFE seating, and sensor polarity.
- Before changing the relief limit, run a controlled comparison with
  `MMU_TEST_CONFIG SYNC_TO_EXTRUDER=0` on a small, low-flow, single-color
  print. This is a runtime-only test: restore it afterward with
  `MMU_TEST_CONFIG SYNC_TO_EXTRUDER=1`; no restart or configuration edit is
  required.
- If those checks pass, increase `flowguard_max_relief` from 80 mm to 100 mm,
  restart when separately authorized, and validate against sustained
  extrusion while retaining the encoder-based protection.

### Crossbow cutter approach

- **Runtime-validated, user-confirmed:** the update-safe
  `_CROSSBOW_SAFE_APPROACH` hook uses a two-stage X20-then-Y15 route when
  starting at X20 or left, and a direct diagonal to X20 Y15 when starting
  right of X20. A complete T10 manual unload validated the integrated
  extension, Crossbow cut, and return to the unloaded state.

## Backlog

- Evaluate a purge bucket/Blobifier workflow to purge most transition material
  off-print and retain only the minimum priming structure. Blobifier is
  currently disabled.
- Physically confirm the exact hotend manufacturer/model, outer toolhead
  housing, installed extruder motor, and final PTFE/connector path.
- Export and audit the direct-feed Orca profile, then perform its eventual
  physical feeder-state test. `REQUIRE_TRADRACK` behavior itself was already
  tested and must not be weakened in the TradRack profile.

## Recently completed

- Toolhead geometry, selector calibration, the successful crab print, Git
  repair, and knowledge reconciliation are recorded in `HISTORY.md`.
- Hardened `autocommit.sh`: fail-fast execution, integrity and branch checks,
  concurrent-run locking, remote divergence protection, safe no-change
  handling, and no live Moonraker database copy/delete cycle.
- Validated the hardened workflow against a disposable local remote, including
  successful push, no-change, database-preservation, and remote-ahead cases.
- Reviewed the generated `mmu/mmu_vars.cfg` changes against the MMU log and
  included the completed-print state with the first knowledge backup.
- Established and documented the manual Happy Hare-to-Orca lane mapping and
  preset handoff workflow; Spoolman remains a possible later inventory layer,
  not an assumed live Orca synchronizer.
- Established the reusable-project method and a safe candidate position for
  the current prime tower. Selected Orca's first-layer adaptive bounds instead
  of an unnecessarily slow unconditional full mesh.
