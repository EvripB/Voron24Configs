# TradRack and ERB v2 reference

Last reconciled: 2026-07-26

This is the durable, searchable reference for the uploaded TradRack build
documents, Trianglelab kit lists, Happy Hare ERB v2 MCU page, FYSETC ERB v2
repository, Annex Belay project, and Filamentalist FV3 project. It records
facts useful for this printer without treating every vendor example as
installed truth.

The unchanged source PDFs, images, extracted text, and offline repository
snapshots are under:

`/home/pi/printer_data/codex_uploads/tradrack/`

That operational-data directory is not part of the public configuration Git
repository. Include it in the future private host backup if the original
binaries must survive an SD-card loss. This tracked file preserves the compact
facts even without that private archive.

## Evidence boundary

- Active Klipper and Happy Hare configuration is authoritative for current
  software state.
- Owner observations are authoritative for installed physical state.
- The Annex manual is an Alpha 0.1 mechanical build reference dated
  2023-11-30. Its controller section is unfinished.
- The Trianglelab package list records what the 14-channel kit was supplied
  with; it does not prove that every supplied item is still installed.
- **User-confirmed:** Trianglelab shipped this TradRack kit with the FYSETC
  ERB v2. Any Easy-BRD v1.1 references in the uploaded source material are
  stale or unrelated to this printer and must be ignored.
- The Happy Hare connection image is an ERCF v2 example. Connector identities
  and pin functions are useful, but the illustrated physical wiring is not a
  photograph of this TradRack.
- Reference firmware screenshots do not establish the bootloader or firmware
  options currently flashed on the installed board.

## Current printer-specific implementation

| Item | Current implementation | Evidence |
| --- | --- | --- |
| MMU | TradRack 1.0e | Active Happy Hare configuration |
| Physical lanes | 14 | Owner-confirmed |
| Commissioned gates | 12: gates 0-11 only | Active configuration and owner-confirmed enclosure capacity |
| MMU controller | Trianglelab-supplied FYSETC ERB v2, RP2040 | Owner-confirmed, active pin aliases, and USB serial identity |
| Controller link | USB serial | `/dev/serial/by-id/usb-Klipper_rp2040_E663B034CB66C42F-if00` |
| Filament encoder | Binky | Config-verified and owner-confirmed |
| Spool handling | Twelve Filamentalist FV3 passive rewinders in the actively heated filament enclosure | Owner-confirmed; one per commissioned gate and `has_filament_buffer: 0` |
| Sync feedback | One-sided Annex Belay tension switch controlled by Happy Hare | Owner-confirmed; active on ERB `gpio12`; standalone Belay module absent |
| Toolhead sensors | Pre-extruder on Spider `PB13`; post-extruder on Spider `PB14` | Active configuration |
| Gate switches | ERB 12-input bank is not used as twelve pre-gate switches | All `MMU_PRE_GATE_*` aliases are commented out |
| Shared gate sensor | Not assigned | `MMU_GATE_SENSOR` alias is empty |
| Lane LEDs | Twelve exit LEDs | ERB `gpio21` drives `neopixel:mmu_leds (1-12)` |

Implementation:
[mmu.cfg](../../mmu/base/mmu.cfg) and
[mmu_hardware.cfg](../../mmu/base/mmu_hardware.cfg).

The original 14-channel hardware does not change the operating boundary:
never load, check, or calibrate gates 12 or 13 unless the owner explicitly
commissions them and the active configuration is updated.

## Annex Belay hardware and software boundary

### Current implementation

The owner confirmed that the moving tension mechanism is an Annex Belay.
Current configuration establishes the following software boundary:

- `sync_feedback_tension_pin: ^mmu:gpio12`
- `sync_feedback_compression_pin:` is unassigned.
- `sync_feedback_enabled: 1`
- FlowGuard is enabled and consumes Happy Hare's modeled feedback state.
- The active printer configuration has no `[belay ...]` section.
- The active Moonraker configuration has no `[update_manager belay]`.
- No Belay module is installed in the active Klipper extras directory, and no
  `~/belay_klippy_module` source tree is present.

Old Moonraker backup files contain a historical Belay update-manager stanza.
They are not active includes and do not establish current use. Happy Hare is
the sole owner of secondary-extruder synchronization and FlowGuard on this
printer. Do not install the standalone Annex module or use its
`QUERY_BELAY`/`ENABLE_BELAY`/`DISABLE_BELAY` commands unless this architecture
is deliberately changed and the duplicate-control risk is reviewed.

### Upstream operating principle

Belay sits between two sections of 4 mm Bowden tube. One tube terminates in a
moving slider, and an Omron lever microswitch reports the slider state. Long
filament paths, spool resistance, or a small mismatch between the primary and
secondary extruders can otherwise accumulate slack or tension. The upstream
standalone module responds by changing the secondary extruder's movement
multiplier according to slider state and extrusion direction.

The upstream standalone defaults are 1.05 and 0.95. Those values explain the
project's reference behavior but are not Happy Hare configuration values and
must not be copied into this printer without a separate tuning decision.
Upstream describes the project as open alpha at the archived commit.

### Upstream BOM, assembly, and service facts

The upstream Belay hardware requires:

| Item | Quantity | Notes |
| --- | ---: | --- |
| Omron D2F-L lever microswitch | 1 | Other compatible TradRack variants may work |
| Bowden collets | 2 | Printed parts support ECAS04, 5 mm, or 6 mm collets |
| Collet clips | 2 | Required for 5/6 mm collets; unnecessary for ECAS04 |
| M2 x 12 pan-head self-tapping screws | 2 | Longer screws protrude |

Important assembly and inspection points from the upstream quick-start guide:

- Install the slider with its arrow visible in the documented orientation.
- Insert the entry tube while the slider is at the end of its travel. The tube
  must extend past the slider and into the sensor housing; a visible gap in
  the filament path means the tube is not fully seated.
- Secure the microswitch wires to the housing with a zip tie so cable strain
  cannot act on the solder joints.
- The switch uses only signal and ground. A three-pin 3.3 V endstop header is
  convenient, but the supply pin is not connected.
- During printing, the slider should remain near the middle of its travel and
  should not repeatedly hit an end stop. On this printer, observe Happy Hare's
  sync-feedback and FlowGuard state rather than the upstream Belay commands.

The complete upstream CAD, STLs, assembly images, software, configuration
reference, and license are retained in the local offline source snapshot.

## Filamentalist FV3 passive rewinders

### Current implementation

The owner has twelve Filamentalist FV3 rewinders, one for each commissioned
gate 0-11, inside the actively heated filament enclosure. They are passive,
filament-driven spool rewinders. Happy Hare therefore uses
`has_filament_buffer: 0`: the FV3 units manage spool take-up but are not a
separate filament-storage buffer in Happy Hare's model.

The upstream repository also contains an optional passive Filamentalist
enclosure. It is not the owner's actively heated enclosure and must not be
used as evidence for the installed enclosure construction, heater, controls,
or temperature limits.

FV3 has optional tensioner-mounted pre-gate sensor parts. Those options are not
installed truth for this printer: the active ERB pre-gate aliases are
commented out and no twelve-switch bank is configured.

### Upstream per-rewinder BOM

This table preserves the upstream v1.1.1 sourcing essentials. It is a rebuild
reference, not a physical inventory of each installed unit.

| Item | Quantity | Upstream detail |
| --- | ---: | --- |
| 8 mm axle rod or tube | 1 | 7.93-7.97 mm or 5/16 inch works best; 50 mm works, up to about 75 mm improves rim-roller stability |
| 688 bearing | 1 | Tensioner arm |
| 608 bearings | 4 | Drive/idler axles; four 688 bearings are the documented alternative |
| HF081412 one-way bearing | 1 | 8 mm bore, 12 mm long, 14.2 mm diameter, octagonal style |
| ECAS04 fitting | 1 | Use a locking clip; omit the fitting's rubber seal |
| O-rings | 2 | Metric 3.5 x 20 mm ID or AS568 size 211 |
| Compression spring | 1 | 304 stainless, 6 mm OD, 0.6 mm wire, 7.5 mm compressed, 15 mm free |
| M3 x 4 x 5 heat-set insert | 1 | Voron-standard size |
| M3 x 30 SHCS and M3 washer | 1 each | Spring-tension adjustment |
| M3 x 12-16 SHCS | 6-10 | Rim-roller axle locking; enclosure mounting can require four more |
| M3 x 12 FHCS | 4 | Idler wheels, tensioner bearing axle, and pivot |
| M3 x 8 FHCS | 12-14 | Twelve for 2020 center mount; fourteen for enclosure mount |
| Number 84 rubber bands | 4 | Two per standard FV3 rim roller; thin bicycle inner tube is an alternative |

The source recommends inexpensive rubber-sealed 608-2RS or 688-2RS bearings.
Their slight resistance is intentional because it helps the one-way bearing
unlock. The shared FAQ recommends lightweight bicycle inner tube with a
0.6-0.7 mm wall when replacing the rim-roller rubber, or number 84 bands for
the standard FV3's 23 mm roller face.

### Printing and service guidance

The upstream FV3 readme recommends:

| Setting | Recommendation |
| --- | --- |
| Material | ABS or ASA |
| Layer height | 0.2 mm |
| Infill | 40%, using a linear-style pattern |
| Walls | 4 |
| Solid top/bottom layers | 5 |
| Approximate material | 154 g for 2020 center mount; 175 g for enclosure mount |
| Approximate print time | 7 h 34 min for 2020 center mount; 9 h 10 min for enclosure mount |

The design relies on multiple press fits for bearings and ECAS hardware.
Upstream strongly recommends printing the supplied bearing-specific
calibration tool first and correcting extrusion multiplier or slicer scaling
before printing replacement parts. PETG or PLA may work, but upstream did not
design or validate the parts for those materials.

The shared FAQ reports successful use with 95A TPU. It does not recommend 85A
soft TPU because unloading can kink or jam it, especially with a heavy spool.
Lower unload acceleration reduces spool-inertia risk. Treat those statements
as upstream capability guidance, not validation of all twelve installed
lanes.

The complete v1.1.1 assembly PDF, current and archived STLs, parametric Fusion
360 file, STEP models, readme, FAQ, and repository provenance are preserved in
the local sparse snapshot.

## FYSETC ERB v2 board

### Published electrical features

- RP2040 MCU.
- Maximum published input: 28 V.
- Onboard 5 V regulator rated at 3 A.
- USB and CAN bus communication.
- Two onboard TMC2209 stepper drivers with integrated heatsink.
- Twelve general-purpose gate-sensor/switch IO positions.
- Dedicated encoder, servo, endstop, sensor, and RGB headers.
- A four-position power/communications connector whose two signal conductors
  can be selected for USB or CAN with jumpers.

### Dedicated headers

The pinout labels each three-pin header in signal, ground, supply order:

| Header | Signal | Supply | Current use |
| --- | --- | --- | --- |
| Encoder | `gpio22` | 3.3 V | Binky encoder; active |
| Servo | `gpio23` | 5 V | TradRack selector servo; active |
| Endstop | `gpio24` | 3.3 V | Selector home microswitch; active |
| Sensor | `gpio25` | 3.3 V | Not assigned by the active Happy Hare aliases |
| RGB | `gpio21` | 5 V | Twelve TradRack exit LEDs; active |

Do not infer physical connector polarity from wire color. Use the board
silkscreen/pinout and verify ground and supply before connecting a device.

### Stepper-driver pins

| Function | Gear/filament-drive motor | Selector motor |
| --- | ---: | ---: |
| Enable | `gpio8` | `gpio14` |
| Direction | `gpio9` | `gpio15` |
| Step | `gpio10` | `gpio16` |
| UART | `gpio11` | `gpio17` |
| Diagnostic | `gpio13` | `gpio19` |

The active configuration uses both motors and their UART connections. Their
diagnostic pins are aliased but the optional StallGuard/touch configuration is
commented out.

### Twelve-position IO bank

Each position provides 3.3 V, ground, and one RP2040 signal:

| Position | GPIO | Alternate functions shown on the FYSETC pinout |
| ---: | ---: | --- |
| 1 | `gpio12` | SPI1 RX, I2C0 SDA, UART0 TX |
| 2 | `gpio18` | SPI0 SCK, I2C1 SDA |
| 3 | `gpio2` | SPI0 SCK, I2C1 SDA |
| 4 | `gpio3` | SPI0 TX, I2C1 SCL |
| 5 | `gpio4` | SPI0 RX, I2C0 SDA, UART1 TX |
| 6 | `gpio5` | SPI0 CSn, I2C0 SCL, UART1 RX |
| 7 | `gpio6` | SPI0 SCK, I2C1 SDA |
| 8 | `gpio7` | SPI0 TX, I2C1 SCL |
| 9 | `gpio26` | ADC0, I2C1 SCL |
| 10 | `gpio27` | ADC1, I2C1 SDA |
| 11 | `gpio28` | ADC2 |
| 12 | `gpio29` | ADC3 |

Happy Hare's stock ERB v2 aliases map these positions to pre-gate sensors
0-11. On this printer those aliases are commented out and `gpio12` is instead
used by the Belay tension switch. This is the documented explanation for why
the apparent twelve-input bank does not represent twelve currently free pins.

### Jumpers and communication

| Jumper | Published behavior |
| --- | --- |
| `JP1` | Closed inserts the 120 ohm CAN termination resistor. Its state is irrelevant when CAN is unused. |
| `JP2` | Closed enables USB 5 V powering. FYSETC warns against connecting 24 V while this is closed because a 5 V failure could expose the host. Verify the installed state physically before changing power wiring. |
| `JP3` and `JP4`, positions 1-2 | Route USB `DM`/`DP` over the green four-position connector. |
| `JP3` and `JP4`, positions 2-3 | Route CAN-L/CAN-H over the green four-position connector. |

The published wiring examples therefore allow:

- Separate 24 V power plus USB-C data.
- One green cable carrying 24 V, ground, USB DM, and USB DP.
- One green cable carrying 24 V, ground, CAN-L, and CAN-H.

The current printer uses the USB serial path. The exact installed jumper and
cable routing should still be verified from board photographs before any
rewiring.

### Published firmware recovery

FYSETC's direct-flash procedure is:

1. Power the ERB from 24 V and connect USB-C to the Raspberry Pi.
2. Hold `BOOTSEL`.
3. Press `RST` for about 0.5 seconds.
4. Release `RST`; after about three seconds, release `BOOTSEL`.
5. Confirm USB ID `2e8a:0003 Raspberry Pi RP2 Boot`.
6. Build Klipper for RP2040 and flash with
   `make flash FLASH_DEVICE=2e8a:0003`.
7. Reset or power-cycle the ERB and confirm its `/dev/serial/by-id` entry.

Happy Hare's archived screenshot shows the direct USB build as:

- Extra low-level options enabled.
- Raspberry Pi RP2040 architecture.
- No bootloader.
- W25Q080 flash with clock divider 2.
- USB serial communication.

FYSETC's repository also recommends a Katapult bootloader and provides
separate Katapult/16 KiB-offset screenshots. These are alternatives, not proof
of what is currently installed. Do not flash the working controller merely to
match a reference image.

## Annex Alpha 0.1 mechanical reference

### Manual page index

| Pages | Topic |
| ---: | --- |
| 4 | Safety warnings |
| 5 | Printed-part guidelines |
| 6 | FAQ, grease, and thread-retention guidance |
| 7 | Torque table |
| 8 | Complete TradRack overview |
| 9-13 | Base frame |
| 15-21 | Selector drive end |
| 23-44 | Selector module |
| 46-49 | Filament-lane modules |
| 51-53 | Selector idler end |
| 54-57 | Belt routing and tension |
| 58 | Cable cover |
| 60-62 | Cable chain |
| 64-65 | Controller overview; unfinished in this alpha manual |

### Printed-part guidelines

| Setting | Annex recommendation |
| --- | --- |
| Process | FDM |
| Material | ASA |
| Nozzle | 0.4 or 0.5 mm |
| Layer height | 0.1 or 0.2 mm |
| Extrusion width | 0.4-0.5 mm |
| Infill | At least 40% at 0.6 mm width |
| Infill patterns | Grid, gyroid, honeycomb, triangle, or cubic |
| Walls | At least 3 |
| Solid top/bottom | At least 5 layers at 0.2 mm |

These are source recommendations and do not establish which material was used
for the currently installed printed parts.

### Torque reference

| Fastener path | Torque |
| --- | ---: |
| M2 plastic to plastic | 0.25 Nm |
| M2.5 metal to metal | 0.4 Nm |
| M3 metal to brass insert | 1 Nm |
| M3 plastic to plastic | 0.4 Nm |
| M3 metal to metal | 1 Nm |
| M5 metal to brass insert | 0.4 Nm in one manual row and 3 Nm in another |
| M5 metal to metal | 3 Nm |
| M5 metal to plastic | 1 Nm |

The manual contains two conflicting M5 metal-to-brass-insert rows. Preserve
that ambiguity rather than selecting one without identifying the joint.

### Mechanical cautions and dimensions

- Disconnect power before electrical work.
- Annex recommends lithium-based grease only for the needle bearings, applied
  sparingly and kept off plastic. It explicitly rejects silicone- and
  PTFE-based lubricant for those bearings.
- Apply VC3/VC125 only where the manual calls for vibration-resistant
  fasteners.
- Extrusion length determines lane capacity; use the project calculator. The
  manual's 280 mm example is for a particular K3 side mount, not a universal
  TradRack requirement.
- The MGN9 rail is shown about 18 mm from the extrusion reference edge; that
  dimension is labeled non-critical. Alignment tools are recommended.
- On the selector motor, leave a 1 mm pulley gap with the 9 mm pulley, or
  2 mm with a 6 mm pulley.
- The selector-home Omron D2F switch is used without its lever. The manual
  recommends soldering the two outer switch legs before assembly.
- Leave the selector-cart mounting bolts roughly 5 mm proud and initially
  loose so the selector can slide into place, then tighten through the top.
- Observe the filament-switch lever orientation.
- The filament-drive motor uses a 5 x 40 mm shaft protruding about 6 mm past
  the rear of its printed part, plus the printed spacer plate.
- The gear train is a 50-tooth drive gear and 17-tooth motor gear; use VC3 on
  their set screws and adjust gear mesh with the mounting bolts.
- Grease the BMG idler needle bearings.
- The tensioner uses the BMG spring and plastic washer with an M3 x 30 screw
  and printed collar, not the original BMG thumbscrew.
- The servo spline screw should be the supplied 4-6 mm M2.5 screw. The manual
  orients the servo wires to the left.
- Each lane module uses an ECAS04 fitting, 623-2RS bearing, and M3 x 8 screw.
- The idler end uses a 5 x 30 mm shaft, 5 x 7 x 0.5 mm shim, and 9 mm 2GT
  toothed idler. With a 6 mm idler, the documented right-to-left order is
  printed spacer, one shim, idler, and two shims.
- Route the belt in the documented five stages, fold its end around an M3 bolt
  to anchor it, and tension it by loosening the selector-motor bolts, adjusting
  the thumbscrew, and retightening the motor.
- Do not fully tighten the cable-chain M5 bolts until the chain travels freely
  end to end. Flip the chain ends if necessary and install the rigid end at the
  bottom.

## Trianglelab supplement

The three-page supplement records the following kit guidance:

- The kit includes parts for a Binky encoder, toolhead sensor, ERF toolhead
  cutter, and Belay extruder-sync sensor.
- Happy Hare is the recommended controller software.
- Trianglelab recommends the Binky/BinkyRack encoder for reliability and
  additional features.
- The selector-home microswitch may need its lever removed.
- The longer 40 mm motor is the filament-drive motor; the thinner motor is the
  selector motor.
- The project and BOM were described as beta and subject to kit/order changes.
- Carrot Patch is the referenced optional spool-holder/buffer.
- The package is described as sufficient for a working 14-channel Happy Hare
  MMU, including toolhead sensing, cutter hardware, and sync feedback.
- Trianglelab recommends the Happy Hare installation guide.
- Community mods are optional; the base TradRack can function without them.

The supplement also contains Easy-BRD-specific statements. They are
deliberately excluded from the current hardware reference because the owner
confirmed that Trianglelab shipped this kit with an ERB v2. The unchanged PDF
remains in the source archive only for provenance.

The applicable ERB v2 mapping has Belay on `gpio12`, Binky on `gpio22`, and no
gate switch assigned.

## Trianglelab 14-channel kit package list

The supplier list records these totals and specifications:

### Electronics and drive

The supplier PDF's Easy-BRD controller line and separate stepper-driver rows
do not describe the delivered kit and are ignored. The controller entry below
uses the owner's direct confirmation.

| Component | Specification | Total |
| --- | --- | ---: |
| Selector motor | 1.8-degree NEMA17, 20 mm, 17.7 Ncm, 1 A | 1 |
| Filament-drive motor | 1.8-degree NEMA17, 40 mm, 42 Ncm, 1.2 A | 1 |
| Servo | OS-1171MG, 17 g | 1 |
| Controller | FYSETC ERB v2, RP2040, two onboard TMC2209 drivers | 1 |
| Microswitch wire | Red/black silicone wire, 1 m | 1 |
| Microswitches | QIAOH D2F-J01FL | 5 |
| Extruder gear set | Pair with needle bearings | 1 |
| Gear shaft | 50-tooth gear shaft | 1 |
| Motor spur gear | 17 tooth | 1 |
| Small shaft | D3 x 20 mm | 1 |
| Thumbscrew kit | Springs and spacers | 1 |
| MR85 bearings | 5 x 8 x 2.5 mm | 2 |

### Frame and motion

| Component | Specification | Total |
| --- | --- | ---: |
| Extrusion | Black 2020, 285 mm | 1 |
| Shafts | D5 x 30 mm and D5 x 40 mm | 1 each |
| MR115 bearings | 5 x 11 x 4 mm | 2 |
| 623ZZ bearings | 3 x 10 x 4 mm | 16 |
| Linear rail | MGN9 with C carriage | 1 |
| Timing belt | 2GT, 9 mm, at least 680 mm | 1 |
| Drive pulley | 2GT 20T, 9 mm wide, 5 mm bore | 1 |
| Toothed idler | 2GT 20T, 9 mm wide, 5 mm bore | 1 |
| Cable chain | 10 x 10, R28, 17 links | 1 |

### Fasteners and fittings

| Component | Total |
| --- | ---: |
| M5 x 10 SHCS | 30 |
| M3 x 8 SHCS | 60 |
| M3 x 10 SHCS | 9 |
| M3 x 12 SHCS | 5 |
| M3 x 16 SHCS | 16 |
| M3 x 20 SHCS | 3 |
| M3 x 25 SHCS | 3 |
| M3 x 30 SHCS | 2 |
| M3 x 8 FHCS | 7 |
| M3 x 20 FHCS | 1 |
| M2.5 x 16 SHCS | 1 |
| M2.5 x 5 SHCS | 1 |
| M2 x 12 self-tapping screws | 7 |
| 5 x 7 x 0.5 mm shims/washers | 8 |
| M3 nylon washer | 1 |
| M3 DIN934 nuts | 2 |
| M3 DIN125 washers | 8 |
| M3 L4 D5 threaded inserts | 45 |
| M3 ball-spring T-nuts | 12 |
| M5 ball-spring T-nuts | 29 |
| ECAS04 Bowden fittings | 16 |
| Collet-and-clip sets | 2 |

### Filament path, cutter, and harness

| Component | Specification | Total |
| --- | --- | ---: |
| PTFE | OD4 / ID3, 10 m | 1 length |
| Zip ties | 4-inch nylon | 10 |
| Cutter blades | Number 4 blade cut to 26 mm | 2 |
| Compression spring | OD4, L15, 0.4 mm wire | 1 |
| Ball bearings | 5.5 mm | 2 |
| Ball bearing | 4 mm | 1 |
| Heat-shrink kit | 1.5 and 2.0 mm | 1 |
| Driver gear | Gear with needle bearings and shaft | 1 |
| Binky | Board with screws and wiring | 1 |
| Motion cable | 24 AWG, 8 conductors, 7.5 mm OD | 1 |
| MicroFit male pins | — | 12 |
| MicroFit female pins | — | 12 |
| MicroFit plugs | 2-, 3-, and 4-position | 1 each |
| MicroFit receptacles | 2-, 3-, and 4-position | 1 each |

## Trianglelab Carrot Patch package list

This is an optional 14-channel spool-holder/buffer kit, not the current
Filamentalist v3 implementation:

| Component | Total |
| --- | ---: |
| 608ZZ bearings | 14 |
| M3 threaded inserts | 57 |
| M5 x 30 BHCS | 14 |
| M5 nylock nuts | 14 |
| M3 x 8 SHCS | 28 |
| M3 x 16 SHCS | 14 |
| M3 x 20 SHCS | 14 |
| Bowden clips | 28 |
| Bowden fittings | 28 |
| OD4 / ID2.5 PTFE | 3 m |

## Offline-source provenance

| Source | Snapshot |
| --- | --- |
| Trianglelab Drive documents | Four unchanged local PDFs; hashes are in `codex_uploads/tradrack/README.md` |
| Uploaded Happy Hare images | Unchanged local images; hashes are in the same README |
| FYSETC ERB repository | Commit `b878bf741eacb0285a8144d542b47f2c99d8439d`, complete `V2.0/` subtree |
| Happy Hare wiki | Commit `82617f3794bb371491ae37bd862dfe2b6ddb074a`, compact ERB v2 MCU snapshot |
| Annex Belay repository | Commit `0670df1c70473ea9a29cb506f468224e844887dc`, complete shallow repository |
| Carrot Collective ERCF v2 repository | Commit `aa1e1c9cbf3d5f4104a77bf17d468486419d4613`, sparse FV3 subtree plus shared FAQ |

Online origins:

- [Trianglelab Google Drive](https://drive.google.com/drive/folders/15uikqsmkMnKs-W1NVWu3owomo34ZEpQp)
- [Happy Hare MCU Reference](https://github.com/moggieuk/Happy-Hare/wiki/Mcu-Reference#fysetc-erb-v2)
- [FYSETC ERB v2 repository](https://github.com/FYSETC/FYSETC-ERB/tree/main/V2.0)
- [Annex Engineering Belay](https://github.com/Annex-Engineering/Belay/tree/main)
- [Filamentalist FV3](https://github.com/Carrot-collective/ERCF_v2/tree/master/Recommended_Options/Filamentalist_Rewinder/Filamentalist_FV3_Rewinder)

## Future use

- Start here for ERB connector identity, controller recovery, TradRack
  mechanical service, Belay inspection, or Filamentalist FV3 replacement
  parts.
- Use the original PDF page when a picture, orientation, or table allocation
  matters.
- Before electrical work, compare this reference with the live configuration
  and a current board photograph.
- Before replacing mechanical parts, verify installed dimensions rather than
  assuming the supplier package item remains unchanged.
- Keep the source archive within the future encrypted private host backup.
