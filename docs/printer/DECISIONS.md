# Durable decisions

Last reconciled: 2026-07-25

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
20. Until a deliberately validated integration replaces it, synchronize
    TradRack lanes to Orca manually. Happy Hare is authoritative for gate
    identity, material, and color; validated Orca presets are authoritative for
    print temperatures, cooling, flow, and volumetric limits. Orca slot 1 maps
    to T0/G0 through slot 12 mapping to T11/G11. Preserve the project-level
    arrangement in a reusable 12-slot 3MF and archive native preset exports.
21. For the TradRack Orca profile, use Orca's explicit adaptive-bed-mesh bounds
    so the first-layer hull includes the prime tower as well as the model.
    Preserve Klipper native adaptive meshing as the default for calls that do
    not request Orca bounds. This avoids both the uncovered-tower fault and the
    405 probe samples of an unconditional full 9x9 mesh.
22. Rebuild the host from the latest supported 64-bit MainsailOS rather than
    copying an old SD-card software image indefinitely. When the physical MCUs
    have not been reflashed, first pin the recovered Klipper host to the
    recorded compatible commit; do not turn an OS recovery into an
    unplanned Spider/MMU firmware update.
23. Keep reproducible, credential-free custom host source in the public
    configuration repository, but keep Moonraker databases, network profiles,
    SSH/Git credentials, Codex state, and large operational data in a separate
    encrypted private backup.
24. Treat `BACKUP_CFG` as a configuration Git operation only. It is not a
    complete Raspberry Pi backup. Local authentication stored in untracked Git
    metadata is not a public-repository leak and does not by itself block the
    backup; credentials must simply remain out of tracked content.
25. Approach the front-left Crossbow cutter from in front of its depressor.
    Use Happy Hare's `user_pre_unload_extension` to call the tracked
    `_CROSSBOW_SAFE_APPROACH` macro rather than modifying Happy Hare's cutter
    implementation. When starting at X20 or left, clear laterally to X20
    before changing Y; when starting right of X20, move diagonally to X20 Y15.
    Then move laterally to the configured X4 cutter lane. This prevents the
    protruding lever from approaching the fixed depressor from behind while
    avoiding unnecessary orthogonal travel from the rest of the bed.
26. Depart the Crossbow cutter laterally before restoring a saved toolhead
    position. Use Happy Hare's `user_post_form_tip_extension` to call the
    tracked `_CROSSBOW_SAFE_DEPARTURE` macro, moving from X4 Y15 to X20 Y15
    before any diagonal restore. This keeps the cutter-specific behavior
    update-safe and avoids changing the global MMU parking route.
27. Retain `flowguard_max_relief` at 80 mm. The two 80.19/80.20 mm compression
    trips occurred before the loose WW-BMG latch was discovered. After
    securing the latch, the same Blobifier-tray region ran for 39 minutes
    49 seconds to Z2 with synchronization enabled, normal tension/neutral
    cycling, and no recurrence. The loose latch is the leading explanation,
    not proven causation; reconsider the threshold or a sync-disabled
    comparison only if the fault becomes reproducible with the extruder and
    filament path confirmed secure.
