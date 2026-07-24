# Durable decisions

Last reconciled: 2026-07-23

These are current choices, not a list of every experiment.

## Architecture

1. Keep the Raspberry Pi, FYSETC Spider, and conventional toolhead harness.
   Adopt CAN only if a concrete future requirement justifies the migration.
2. Use TradRack with Happy Hare rather than ERCF, BoxTurtle, or EMU.
3. Treat the hardware as **14 physical lanes but 12 operational gates**.
   Gates 0-11 are the complete supported scope because the enclosure holds
   twelve filaments. Do not calibrate or use gates 12-13.
4. Keep TradRack in the heated dry box and use USB for the MMU controller.
   Removable power/data integration is preferred.
5. Use Filamentalist v3 without a separate filament-storage buffer.

## Filament path and MMU

6. Use BMGWW with the Crossbow cutter and both toolhead filament sensors.
   Do not assert the exact outer housing or hotend manufacturer until physically
   verified.
7. Let Happy Hare own loading, unloading, and cutting. Orca should request tool
   changes but should not independently perform tip shaping or toolchange
   retract/load/unload motions.
8. Keep long spool moves conservative. Current 130 mm/s at 100 mm/s² loading
   and 180 mm/s at 150 mm/s² unloading prioritize reliable Filamentalist spool
   handling over minimum swap time.
9. Do not mask a mechanical filament-path fault with progressively larger
   homing distances, motor current, or protection thresholds.

## Slicer and print start

10. Use OrcaSlicer, with separate printer profiles for TradRack and direct-feed
    operation. The direct-feed profile must not assume Happy Hare is enabled.
11. Preserve the complete validated TradRack start order recorded in
    `CURRENT.md`, including Happy Hare setup/check before heating and initial
    tool loading after `PRINT_START`.
12. Continue using the slicer purge tower for flushing until a purge
    bucket/Blobifier design is deliberately implemented and validated.
13. Treat maximum volumetric speed as a filament/hotend/nozzle combination.
    A future 0.6 mm CHT setup requires its own tested values rather than
    inheriting the current 0.4 mm filament limits blindly.

## Print quality and thermal safety

14. Keep Klipper pressure advance at 0.02 for the current tested configuration.
    The 0.04 experiment caused corner/end gaps and is not a current default.
15. Retain 25% top/bottom infill-wall overlap for the profile where reducing it
    to 10% did not improve the observed roughness.
16. Do not repeat slow PLA printing with a 100 °C bed in a closed enclosure.
    Earlier tests ended in heat creep; use material-appropriate temperatures
    and ventilation.

## Maintenance and records

17. Separate host software updates from MCU flashing. Flash an MCU only for an
    intentional firmware change or demonstrated compatibility requirement.
18. Treat the Git repository as public. Keep credentials, authentication
    secrets, and other sensitive data out of tracked files and command output.
19. During an active print, default to read-only observation. Runtime changes
    require explicit authorization for that specific action.
