# Printer hardware inventory

Last reconciled: 2026-07-25

This file records physical printer hardware in more detail than
[`CURRENT.md`](CURRENT.md). It distinguishes confirmed installed parts from
original-build purchases that may have been replaced.

## Evidence and source boundary

- **User-confirmed** means the owner identified the currently installed part
  or its packaging.
- **Config-verified** means the active configuration corroborates the
  electrical or mechanical characteristics, but may not prove a manufacturer.
- **Original-BOM candidate** means the part appears in
  `codex_uploads/Voron_BOM.xlsx`, an original-build purchase workbook outside
  the public configuration repository. It is not treated as currently
  installed until confirmed.
- Prices, tracking numbers, seller history, and other transactional fields are
  intentionally excluded from this public inventory.

## Confirmed current hardware

### Printer and control

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| Printer | Voron 2.4, 300 mm class, CoreXY | User-confirmed and config-verified; configured travel is X300 Y300 Z280. |
| Main controller | FYSETC Spider v1.1 with TMC2209 drivers | User-confirmed and config-verified. |
| Host | Raspberry Pi 4 | User-confirmed historically and runtime-validated on Debian 12 Bookworm. |
| Display | RGB Mini 12864 | Config-verified and present in the original BOM; physical revision remains unconfirmed. |
| Toolhead connection | Conventional cable harness | User-confirmed; the printer does not currently use a CAN toolhead. |

### Toolhead and extrusion

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| Extruder | BMGWW/WW-BMG | User-confirmed; exact installed motor remains unresolved. |
| Hotend | Trianglelab Dragon Hotend V2.0 High Flow | User-confirmed from the original purchase and current installation. |
| Melt-zone extension | Trianglelab Melt Zone Extender (MZE) | User-confirmed addition to the Dragon HF. |
| Heater cartridge | Generic 24 V / 70 W cartridge | User-confirmed; purchased from AliExpress, manufacturer and model unknown. |
| Hotend thermistor | ATC Semitec 104GT-2 | User-confirmed and config-verified. |
| Nozzle | 0.4 mm | Config-verified; manufacturer and exact construction are not recorded. |
| Filament cutter | Crossbow-style cutter | User-confirmed and config-verified; actuated by Y-axis toolhead motion. |
| QGL/mesh probe | Omron TL-Q5MC2-Z inductive probe | User-confirmed from retained packaging. Configured offset is X0 Y+20. |
| Z reference | Mechanical Z-endstop pin | Config-verified and physically recalibrated on 2026-07-25. |

### Heated bed and print surfaces

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| Bed plate | 300 x 300 x 8 mm MIC6 aluminum plate | User-confirmed against the original BOM. |
| Bed heater | Keenovo 290 x 290 mm, 230 V AC silicone heater | User-confirmed against the original BOM. |
| Magnetic layer | Graviflex magnetic sheet | User-confirmed against the original BOM. |
| Removable substrate | Flexible spring-steel sheet | User-confirmed against the original BOM. |
| Primary print surface | Energetic double-sided smooth/textured PEI plate | User-confirmed; used for all current printing. It has some damage but remains serviceable. |
| Spare print surface | Fermiolab single-sided plate | User-confirmed; never used. Exact surface construction remains unconfirmed. |

### MMU and filament handling

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| MMU | TradRack 1.0e with Binky encoder | Config-verified. |
| Physical lanes | 14 | User-confirmed; only gates 0-11 are commissioned because the enclosure stores 12 filaments. |
| Spool handling | Filamentalist v3 | User-confirmed and config-verified; no separate filament-storage buffer. |
| Tension feedback | Belay mechanism | User-confirmed; used by Happy Hare sync feedback and FlowGuard. |
| Toolhead sensing | Pre-extruder and post-extruder filament sensors | User-confirmed and config-verified. |

## Service and replacement notes

- The Energetic smooth/textured PEI plate is the only plate currently used.
  It is damaged but still produces acceptable prints; replacement is sensible
  future maintenance rather than an immediate blocker.
- The Fermiolab single-sided plate is available as an unused spare.
- The original BOM's generic 24 V / 40 W heater-cartridge entry is not the
  current cartridge; the installed cartridge is the user-confirmed 24 V /
  70 W unit.
- The BOM identified the purchased probe as `PL-08N`, with FYSETC seller
  information. Retained packaging identifies the installed probe as an Omron
  `TL-Q5MC2-Z`; the packaging and owner inspection supersede the purchase-row
  description.

## Original-BOM candidates needing confirmation

These are useful leads, not assertions about current installation.

| Subsystem | Original-BOM candidate or conflict | Confirmation needed |
| --- | --- | --- |
| A/B motors | `Specs` lists LDO-42STH40-2004MAC(VRN); config comments instead name LDO-42STH40-1004MAH(VRN). | Read the installed motor labels or establish which source reflects the final build. |
| Z motors | Four LDO-42STH48-2004AC(VRN). | Confirm whether all four remain installed. |
| Extruder motor | Original sheets list both LDO-42STH20-1004ASH-MM(VRN) and LDO-36STH20-1004AHC(XH). | Identify the motor currently fitted to the BMGWW. |
| Linear rails | Eight RobotDigg MGN9H 350 mm rails were purchased. | Confirm installed rail brand, count, and whether any were replaced. |
| Motion belts | 9 mm and 6 mm GT2 belts, loops, pulleys, and idlers. | Confirm current belt brands only if useful for maintenance; dimensions are largely implied by the Voron design. |
| 24 V power supply | Mean Well LRS-200-24. | Confirm it remains installed. |
| 5 V power supply | Mean Well RS-25-5. | Confirm it remains installed. |
| Bed SSR | BOM identity is internally inconsistent between an Omron description and another part number. | Read the installed SSR label when the printer is powered down and safe to inspect. |
| Motion endstops | D2F-01L microswitches and a Hall-effect XY-endstop board were both purchased. | Confirm the currently installed X/Y endstop hardware. |
| Fans | Original BOM lists 60 x 60 x 20, 40 x 40 x 20 blower, and 40 x 40 x 10 axial 24 V fans. | Confirm current fan models only if replacement planning requires it. |
| Frame and rails | LDO/Fermiolab-era 300 mm frame and IGUS chain components appear in the BOM. | Confirm current frame supplier and which cable chains remain installed. |
| Enclosure panels | Coroplast and clear acrylic panel sets appear in the original BOM. | Confirm current panel materials if enclosure thermal behavior is investigated. |
