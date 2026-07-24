# Safe runbooks

These procedures are intentionally conservative. Preconditions matter more than
the command list.

## 1. Read-only baseline

Use this first for diagnosis or when print state is active/unknown.

1. Establish print state and the owner's intended scope.
2. Inspect active includes and effective definitions.
3. Read current logs and generated G-code as needed.
4. Inspect Git without exposing remote URLs:

   ```bash
   git -C /home/pi/printer_data/config status --short
   git -C /home/pi/printer_data/config diff --stat
   git -C /home/pi/printer_data/config diff --cached --stat
   ```

5. Report evidence and uncertainty. Do not turn observation into a runtime test
   without authorization.

Never use commands that print a credential-bearing remote URL.

## 2. Safe configuration change

Preconditions: printer idle, exact requested change understood, and any needed
restart separately authorized.

1. Find every active definition and override for the setting.
2. Preserve unrelated working-tree changes.
3. Store any filesystem backup outside active include/configuration paths.
4. Change the smallest possible surface and one diagnostic variable at a time.
5. Review the exact diff.
6. Define success, failure, and rollback before a restart.
7. Apply a restart only when safe and authorized.
8. Check startup logs and effective runtime configuration.
9. Update `CURRENT.md`, `DECISIONS.md`, `WORKLOG.md`, or `HISTORY.md` as
   appropriate.

Do not create `.cfg` backup copies where a wildcard include might load them.
Do not use destructive Git rollback to discard the owner's work.

## 3. MMU load, grip, or slippage diagnosis

Preconditions depend on the test:

- For a full load/unload, the Bowden path must be connected and clear, the
  toolhead must be safe to move, and the hotend must be at an appropriate
  temperature.
- For selector/gate-only work, explicitly confirm the command will not attempt
  to reach the extruder.
- Never run cutter or selector motion while hands or tools are in the mechanism.

Observation sequence:

1. Record gate, filament, spool drag, selector alignment, and visible residue.
2. With explicit authorization, read sensors before changing filament state:

   ```text
   MMU_SENSORS DETAIL=1
   ```

3. With explicit authorization, `MMU_CHECK_GATE GATE=N` checks gate
   pickup/encoder behavior near the MMU. It moves the MMU mechanism and is not
   a substitute for a full toolhead load test.
4. For a full controlled test, record gear command distance, encoder distance,
   sensor transitions, XY position, temperature, and the exact failure phase.
5. On a paused print, do not press `RESUME` merely to retry loading. First
   restore a known filament state and understand whether Happy Hare will retry
   the toolchange or Klipper will resume motion. The current
   `retry_tool_change_on_error: 0` setting means an automatic MMU retry is
   disabled; `RESUME` can continue print motion without replaying the failed
   toolchange.
6. Inspect mechanical causes before compensating in software:
   selector alignment, drive pressure, ground filament, PTFE ID/OD transitions,
   ECAS entrance, connector lips, bends, spool drag, and Bowden seating.
7. Reduce aggressive movement before increasing motor current. Do not hide a
   physical obstruction by repeatedly increasing homing distance or FlowGuard
   allowance.

## 4. Orca TradRack preset audit

Perform this offline; slicing a test does not authorize printing it.

1. Export the printer, process, and filament presets from Orca.
2. Verify 12 tools and single-extruder multimaterial.
3. Verify each preset's true material identity, temperatures, cooling, and
   nozzle-specific maximum volumetric speed.
4. Confirm Happy Hare owns loading/unloading/cutting:
   - toolchange retraction: 0
   - filament ramming: disabled
   - external loading/unloading speeds: 0
   - cooling moves/speeds for toolchange handling: 0
5. Confirm the TradRack start sequence matches `CURRENT.md`.
6. Confirm the direct-feed profile contains no unconditional MMU setup or load.
7. Slice a small test and inspect generated G-code, referenced tools, material
   names, temperatures, purge volumes, tower bounds, and effective pressure
   advance.
8. Only then plan an explicitly authorized printer test.

## 5. Git backup and recovery

The Git root is `/home/pi/printer_data/config`.

`BACKUP_CFG` is not an independent filesystem snapshot. The hardened
`autocommit.sh` verifies repository integrity and branch state, fetches without
merging, refuses a remote-ahead/diverged state, stages all current changes,
commits when needed, and pushes. It is fail-fast and does not copy or delete
the live Moonraker database.

Before using it:

1. For irreplaceable local changes, take a separate filesystem snapshot before
   invoking the macro. Git history is not a substitute for that snapshot.
2. Run `git fsck --full`.
3. Review status and both staged and unstaged diffs.
4. Confirm no credential or private file is being added.
5. Then use `BACKUP_CFG` or explicit Git commands.

If corruption is detected:

1. Stop normal Git operations.
2. Copy the complete live configuration to a private rollback location.
3. Obtain a separate clean clone and compare it with the live working tree.
4. Repair only the confirmed damaged metadata or objects.
5. Run `git fsck --full` and re-check every local difference.

Never reset, clean, replace the live working tree, or rewrite history merely to
make Git look clean.

## 6. Hardware identity and geometry

1. Printer must be idle; use a cold toolhead unless the measurement explicitly
   requires heat.
2. Photograph and label the component before disassembly.
3. State the exact measurement datums, not just the resulting number.
4. Separate CAD-derived, config-derived, and physically measured values.
5. Do not infer a manufacturer from compatible geometry.
6. Treat cutter/load validation as a separate motion test with its own safety
   plan.
