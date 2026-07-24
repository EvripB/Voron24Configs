# OrcaSlicer handoff and TradRack lane workflow

This directory is the version-controlled handoff point for OrcaSlicer assets.
The actual presets still live on the owner's PC; do not treat an uploaded 3MF
or generated G-code as a complete preset backup.

## Sources of truth

- Happy Hare's live [`mmu_vars.cfg`](../../mmu/mmu_vars.cfg) is authoritative
  for which spool is assigned to a gate, including its name, material, and
  display color.
- A validated Orca filament preset is authoritative for print temperatures,
  cooling, flow ratio, pressure advance, and maximum volumetric speed.
- Do not copy Happy Hare's saved gate temperature into Orca as a print setting.
  It is inventory/runtime metadata and may be stale.
- The current tool-to-gate map is one-to-one: Orca slot 1 is T0/G0, slot 2 is
  T1/G1, and so on through slot 12 as T11/G11.
- Gates 12 and 13 are not commissioned and must not be added to Orca.

Spoolman support and Happy Hare automapping are currently off, so this is a
manual synchronization workflow. Enabling Spoolman later would improve spool
inventory, but would not by itself rewrite the filament slots in an open Orca
project.

## Lane snapshot

This is a dated snapshot for comparison, not a second live database. Read
`mmu_vars.cfg` again before relying on it after a spool change.

Snapshot date: 2026-07-24

| Orca slot | Tool/gate | Happy Hare name | Material | Orca RGB |
| ---: | --- | --- | --- | --- |
| 1 | T0/G0 | eSun White | ABS+ | `#FFFFFF` |
| 2 | T1/G1 | eSun RED | ABS+ | `#F24343` |
| 3 | T2/G2 | Creality Blue | ABS | `#020298` |
| 4 | T3/G3 | Creality Black | PLA | `#000000` |
| 5 | T4/G4 | Sunlu Silk Grey | PLA | unset |
| 6 | T5/G5 | Sunlu Silk Copper | PLA | `#F48322` |
| 7 | T6/G6 | Organge Fluorecent | PLA | `#FC5F00` |
| 8 | T7/G7 | unset | unset | unset |
| 9 | T8/G8 | unset | unset | unset |
| 10 | T9/G9 | eSun FireEngine RED | ABS+ | `#FF0000` |
| 11 | T10/G10 | eSun Black | ABS+ | `#000000` |
| 12 | T11/G11 | DevilDesign Transparent | PETG | `#FFFFFF` |

The live record has no color for G4 and no name, material, or color for G7 and
G8. Resolve those omissions in Happy Hare rather than guessing in Orca. G9's
saved 200 C value for ABS+ and G11's 200 C value for PETG also deserve an
inventory-metadata check, but must not be used to overwrite validated print
temperatures. Happy Hare stores transparency as an alpha component for G11;
Orca's ordinary swatch may only retain the RGB portion.

## Routine synchronization

1. Update the spool identity, material, and color in Happy Hare first.
2. In the TradRack Orca printer project, use slot `N + 1` for Happy Hare
   tool/gate `N`.
3. Select the validated Orca preset for that exact material or product. Do not
   merely rename an ABS-derived preset to PLA or PETG.
4. Set the Orca swatch from the first six hexadecimal color digits in Happy
   Hare.
5. Before slicing, verify every tool actually referenced by the model. Empty
   lanes may remain unassigned, but the twelve-slot order must not be shifted.
6. Audit the generated G-code's referenced tools, material names, temperatures,
   and validated TradRack start sequence before printing.

## Current Orca audit

The 2026-07-23 0.28 mm crab project is useful runtime evidence, but it is not a
safe preset backup:

- Its nominal `PLA - TradRack` entries still identify internally as ABS and
  retain ABS-derived density, glass-transition, cooling, and some bed values.
- Its PETG entries override some visible values but still inherit from the
  Generic ABS system preset.
- All twelve slots use the same 20 mm3/s maximum volumetric speed and the same
  cooling range, so each real filament/nozzle/hotend combination still needs
  an intentional audit.
- Slot 7 is PETG/yellow in that project while live G6 is PLA/orange.
- Slots 8 and 9 are populated in the project even though live G7 and G8 have no
  saved filament identity.
- Multiple color swatches differ from the live Happy Hare map.

Create clean PLA and PETG presets from the appropriate system material rather
than repairing only their visible names.

The original native user-filament files uploaded on 2026-07-24 confirmed the
same issue:

- `ABS - TradRack` correctly inherits `Generic ABS @System` and explicitly
  zeros the seven Happy-Hare-owned cooling-move and loading/unloading fields.
- `PLA - TradRack` and `PETG - TradRack` both still inherit
  `Generic ABS @System`. Changing their visible type and temperatures did not
  change the hidden parent.
- `Generic PLA @System - Copy` correctly inherits Generic PLA, but it does not
  yet contain the TradRack zero-motion overrides and is not a finished preset.
- No correctly based PETG user preset was present.

When repairing through Orca's UI, use distinct temporary names so overwriting
an existing preset cannot preserve its old ABS parent. Always verify the saved
JSON contains `inherits: Generic PLA @System` or
`inherits: Generic PETG @System` before retiring the old files.

The staging copies in `codex_uploads/OrcaSlicer/filament_profiles/` were then
corrected directly, changing only those two parent links. JSON validation
confirmed the intended material identities, existing 220 C / 60 C temperature
overrides, 25 mm3/s limits, and all seven zero-motion fields were preserved.
They still require import and a normal load/save check in Orca on Windows
before being treated as the final archived presets.

## Assets to archive

After correcting the presets on the PC:

1. Save a reusable no-model 12-slot starter project as
   `TradRack-12T-lane-template.3mf`. This preserves project-level slot order,
   colors, and prime-tower placement.
2. Export the TradRack and direct-feed printer presets.
3. Export the associated process and filament presets.
4. Upload those assets for inspection before adding them here. Keep their
   native Orca export extensions and include a short manifest with the Orca
   version and export date.

An exported bundle is accepted only after its regenerated G-code preserves the
validated start order and leaves filament loading, unloading, cutting, ramming,
and cooling moves under Happy Hare control.

## Prime-tower project state

OrcaSlicer 2.4 stores the prime-tower position per plate in the project, not as
a normal printer- or process-preset default. Preserve it in the same reusable
starter 3MF as the twelve filament slots.

Orca's exported `wipe_tower_x`/`wipe_tower_y` values describe an internal
tower anchor; the plate-move UI can instead show the visual center of the
generated tower. Do not copy a number between those two coordinate systems.
The prior candidate internal anchor `X188 Y52` was calculated to put the
successful crab tower's extrusion around X183.0-253.0 and Y46.3-99.2, but it
is not a universal UI position.

Position the actual tower footprint shown in Preview so that it plus the
configured 5 mm mesh margin stays inside X/Y40-260. Recheck after changing
tower width, brim, type, rotation, or purge geometry, because those can change
the footprint around Orca's anchor. The generated `MESH_MIN` or `MESH_MAX`
landing exactly on a configured limit is a reason to inspect for clipping.

The saved crab internal anchor, X216.092 Y22.9382, produced a footprint around
X211.1-281.1 and Y17.2-70.1, so it was both right and forward of the configured
mesh area.

Position alone does not fix adaptive meshing. Orca's generated object
definition contains the model but not the prime tower, and Klipper's adaptive
mesh is derived from those defined objects.

Use Orca's own adaptive-mesh bounds for the TradRack profile instead. Orca
calculates these from the complete first-layer extrusion hull, which includes
the model, supports, skirt, brim, and prime tower:

| Orca printer setting | Value |
| --- | --- |
| Bed mesh minimum | `40,40` |
| Bed mesh maximum | `260,260` |
| Probe point distance | `27.5,27.5` |
| Mesh margin | `5` |

The TradRack printer's `PRINT_START` line should pass the calculated values to
Klipper:

```text
PRINT_START EXTRUDER={nozzle_temperature_initial_layer[initial_tool]} BED={bed_temperature_initial_layer_single} SKIP_PRIME=1 MESH_MODE=ORCA MESH_MIN={adaptive_bed_mesh_min[0]},{adaptive_bed_mesh_min[1]} MESH_MAX={adaptive_bed_mesh_max[0]},{adaptive_bed_mesh_max[1]} PROBE_COUNT={bed_mesh_probe_count[0]},{bed_mesh_probe_count[1]} MESH_ALGORITHM=[bed_mesh_algo]
```

`PRINT_START` stores this active mesh under the runtime profile name
`adaptive_orca` and uses the explicit bounds with `ADAPTIVE=0` because Orca
has already applied the margin and selected the probe count and interpolation
algorithm. Calls that omit `MESH_MODE=ORCA` retain Klipper's native adaptive
behavior, so the direct-feed profile does not need this line.
