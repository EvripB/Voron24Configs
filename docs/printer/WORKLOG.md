# Active work

Last updated: 2026-07-24

No critical printer fault is currently open. The July 23 multicolor print
completed successfully.

## Next

### 1. Correct and export Orca presets

- Repair `PLA - TradRack` and `PETG - TradRack`; they were created from an ABS
  base and must be checked for material identity, temperatures, cooling, and
  maximum volumetric speed.
- Export and archive the actual Orca assets for:
  - `Voron 2.4 300 - TradRack 12T`
  - the direct-feed printer profile
  - the associated process and filament presets
- Proposed tracked destination: `slicer/orca/`.
- Audit generated G-code before printing. The current crab G-code proves the
  TradRack start sequence; the inherited-ABS preset problem is based on the
  owner's direct inspection in Orca.

### 2. Align Orca tools with the Happy Hare lane map

- Happy Hare/Mainsail currently stores gate names, materials, and colors in
  `mmu/mmu_vars.cfg`.
- Orca has a separate 12-tool list, and only the tools needed by the test were
  manually colored.
- Spoolman support is currently off and all saved spool IDs are unset.
- Decide between a documented manual synchronization workflow and a later
  Spoolman-based workflow. Do not assume automatic synchronization exists.

### 3. Make prime-tower placement persistent

- Record a default tower position that remains inside the printable and
  probeable region so it does not need to be moved for every project.
- The configured mesh limits are X/Y 40-260, but those numbers alone do not
  guarantee a safe tower footprint; account for probe offsets and verify the
  generated adaptive-mesh bounds.
- Ensure adaptive meshing covers both the model and the tower. The successful
  crab G-code defined the model for object exclusion but omitted the tower from
  its object definition.
- Choose deliberately between proper tower object bounds and a full-bed mesh;
  do not silently rely on probing only the model.

### 4. Review the completed crab print

- Inspect color contamination, tower stability, surface quality, and actual
  waste before reducing flushing further.
- Current test settings included a 0.7 flushing multiplier and flushing into
  object infill.
- Reliability result: 89/89 toolchange operations, zero job pauses, average
  complete swap 59.7 seconds.

## Monitor

### MMU unload slippage

One recent unload reported 1937.4 mm commanded versus 1916.3 mm encoder
movement, a nonfatal 21.1 mm discrepancy. It did not stop the successful print.

Action:

- Monitor future prints by gate and filament.
- Investigate only if the warning repeats or causes a failure.
- Check selector alignment, gear residue, spool drag, PTFE/connector
  transitions, and drive pressure before changing thresholds or current.

## Backlog

- Evaluate a purge bucket/Blobifier workflow to purge most transition material
  off-print and retain only the minimum priming structure. Blobifier is
  currently disabled.
- Physically confirm hotend, outer toolhead housing, extruder motor, and final
  PTFE connector dimensions.
- Validate the direct-feed profile and its physical feeder-state guard without
  weakening `REQUIRE_TRADRACK` in the TradRack profile.
- Revisit top-surface, overhang, travel, or historical Z-banding investigations
  only if the problem is reproducible with the current hardware/profile.
- Optional projects: G-code upload sanity checker and automated extrusion
  calibration research.

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
