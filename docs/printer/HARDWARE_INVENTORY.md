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
| Main controller | FYSETC Spider v1.1, STM32F446 MCU, with TMC2209 drivers | User-confirmed from the board and chip markings; the active Klipper USB identity also reports `stm32f446xx`. |
| Host | Raspberry Pi 4 | User-confirmed historically and runtime-validated on Debian 12 Bookworm. |
| 24 V power supply | Mean Well LRS-200-24 | User-confirmed as still installed. |
| Standalone 5 V supply | None installed | User-confirmed. The original-BOM Mean Well RS-25-5 was not installed; the Raspberry Pi's present power route remains unconfirmed. |
| Mains inlet fuse | Probably 10 A | The owner's purchase email specifies 10 A, but the installed fuse has not been physically inspected. Treat 10 A as purchase-record evidence, not a verified fuse rating. |
| Display | RGB Mini 12864 | Config-verified and present in the original BOM; physical revision remains unconfirmed. |
| Toolhead connection | Conventional cable harness | User-confirmed; the printer does not currently use a CAN toolhead. |
| Electronics-bay cooling | Two Gdstime GDA6020 dual-ball-bearing fans, 24 V / 0.1 A | User-confirmed; one fan is installed on each side. The two-fan group is controlled by the configured controller-fan output. |

### Motion system

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| A/B motors | Two LDO-42STH40-2004MAC(VRN) motors | User-confirmed from retained box labels. The configured 400 full steps per rotation corroborate their 0.9-degree setup. |
| Z motors | Four LDO-42STH48-2004AC(VRN) motors | User-confirmed from the original motor set and current installation. |
| Linear rails | Eight RobotDigg MGN9H 350 mm rails | User-confirmed; all eight original rails remain installed. The machine retains the earlier dual-MGN9 X-axis arrangement and has not been converted to the later single-MGN12 X rail. |
| X/Y endstops | Hall-effect XY-endstop board | User-confirmed. The active configuration uses separate X and Y endstop inputs. |

### Toolhead and extrusion

| Component | Current identity | Evidence and notes |
| --- | --- | --- |
| Toolhead housing | A4T | User-confirmed. |
| Toolhead fans | Two 4010 blower fans for part cooling and one 2510 axial hotend fan | User-confirmed. The active configuration corroborates separate part-cooling and temperature-controlled hotend-fan outputs; exact fan manufacturers and electrical ratings are not recorded. |
| Extruder | BMGWW/WW-BMG | User-confirmed. |
| Extruder motor | LDO-36STH20-1004AHG | User-confirmed from the installed motor identity. |
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
| Bed SSR | A-Senco `SSR-500`-series DC/AC solid-state relay | Manufacturer and family are user-confirmed. The original purchase record identifies `SSR-500-1DA48-10`, rated for a 230 V AC, 10 A load; the full installed label and rating have not been physically rechecked. |
| Bed thermal protection | Not independently identified | Any thermal protection associated with the Keenovo mat was supplied as part of the heater assembly rather than installed separately by the owner. Its type, location, trip temperature, and wiring have not been verified. |
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
- The original-BOM Mean Well `RS-25-5` is not installed. Do not include it in
  a rebuild parts list unless a future inspection shows that a separate 5 V
  supply has since been added.
- The bed SSR manufacturer is A-Senco; this is not an uncertain seller-name
  inference. Only its full installed suffix/rating and the bed's
  thermal-protection details remain unresolved.

## Original-BOM candidates needing confirmation

These are useful leads, not assertions about current installation.

| Subsystem | Original-BOM candidate or conflict | Confirmation needed |
| --- | --- | --- |
| Motion belts | 9 mm and 6 mm GT2 belts, loops, pulleys, and idlers. | Confirm current belt brands only if useful for maintenance; dimensions are largely implied by the Voron design. |
| Frame and rails | LDO/Fermiolab-era 300 mm frame and IGUS chain components appear in the BOM. | Confirm current frame supplier and which cable chains remain installed. |
| Enclosure panels | Coroplast and clear acrylic panel sets appear in the original BOM. | Confirm current panel materials if enclosure thermal behavior is investigated. |
