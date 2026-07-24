# Condensed history

This file preserves milestones and superseded context without making old
settings look current. The original ChatGPT handoff was a structured
reconstruction, not a raw transcript export, so some early dates and component
identities remain approximate.

## 2025

- Investigated extrusion behavior and roughly 6 mm Z-banding.
- Operated a 0.6 mm high-flow nozzle and discussed approximately 30 mm³/s flow.
  Those results do not define the current 0.4 mm setup.

## January-February 2026

- Compared MMU and toolhead architectures.
- Selected TradRack with Happy Hare.
- Retained the Raspberry Pi, Spider, and conventional cable-harness
  architecture.
- Planned BMGWW, a cutter, and dual toolhead sensors.

## March-April 2026

- Built fourteen physical TradRack lanes and integrated the system into the dry
  box.
- Chose USB control for the MMU controller and removable power/data integration.
- Addressed PTFE alignment and hotend/extruder geometry questions.
- Installed the reported 24 V / 70 W heater.

## May-June 2026

- Investigated cutter park geometry, FlowGuard behavior, encoder slippage,
  pressure advance, and top-surface quality.
- Rejected PA 0.04 for the tested profile; current PA returned to 0.02.
- Recorded heat creep during inappropriate high-bed-temperature enclosed PLA
  tests.
- Completed the Debian 12 Bookworm host migration.
- Added Talking Voron temperature warnings and tuned camera settings.
- Established the policy that host updates do not automatically require MCU
  flashing.

## Early July 2026

- Finalized the Filamentalist no-separate-buffer strategy and conservative long
  spool-move settings.
- Settled the active MMU gear current at 1.10 A.
- Established VS Code/Codex access and public Git-based configuration backup.

## July 18-23, 2026

- Created the Orca profile `Voron 2.4 300 - TradRack 12T`.
- Confirmed that only gates 0-11 are operational despite fourteen physical
  lanes.
- Recalibrated selector offsets for all twelve supported gates.
- Reconciled toolhead geometry to 88.7 / 76.5 / 9.3 mm.
- Diagnosed recurrent load failures at the BMGWW/ECAS entrance. The next print
  succeeded after filing the housing; longer-term repeatability remains under
  observation.
- Completed the three-color articulated hermit-crab print with 89/89
  toolchange operations and no job pause.
- Imported and audited the ChatGPT knowledge-handoff candidates.
- Repaired four zero-byte objects in the configuration Git repository after
  preserving a complete rollback copy. Repository integrity then passed.
- Replaced the candidate archive as operational memory with the compact
  authoritative documents indexed here.

## July 24, 2026

- Hardened `autocommit.sh` so Git or network failures stop before later steps,
  concurrent runs are refused, remote changes cannot be merged unexpectedly,
  and no-change runs remain successful.
- Removed the ineffective live Moonraker database copy/delete cycle and
  increased the Mainsail shell-command timeout from 30 to 120 seconds.
- Validated the workflow against a disposable local remote.
- Reviewed the generated `mmu_vars.cfg` changes against the completed-print log
  and backed up the authoritative knowledge set with that current MMU state.

## Superseded statements

- Current nozzle is not unknown: configuration is 0.4 mm.
- Active lane count is not unknown: it is twelve, gates 0-11.
- Old 60.7 mm extruder-to-nozzle geometry and its 70.2 mm park warning are
  superseded by the current 88.7 mm measurement.
- The historical 1.27 A MMU current is superseded by 1.10 A.
- Talking Voron integration and Orca TradRack start order are implemented.
- Earlier load failures are no longer an active blocker, although unload
  slippage remains under observation.
- Exact A4T/Stealthburner-derived housing and hotend manufacturer remain
  unresolved rather than assumed.
