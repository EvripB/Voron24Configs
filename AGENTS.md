# Voron printer workspace instructions

These instructions apply to the printer configuration repository.

## Read first

For every printer task, read:

1. `docs/printer/CURRENT.md`
2. `docs/printer/WORKLOG.md`

Read `docs/printer/DECISIONS.md`, `docs/printer/RUNBOOKS.md`, or
`docs/printer/HISTORY.md` when the task involves rationale, an operational
procedure, or superseded work. The files in
`../codex_uploads/knowledge-handoff/` are source material, not current truth.

## Authority

- Active configuration and current runtime evidence are authoritative for
  software state.
- Recent direct observations from the owner are authoritative for physical
  state.
- These documents summarize reconciled knowledge but never override live
  evidence.
- Do not infer loaded filament solely from Happy Hare availability flags.
- `mmu/mmu_vars.cfg` is generated mutable state. Read it for current values;
  do not hand-edit it merely to synchronize documentation.

## Safety

- Establish whether a print is active before changing anything. If it is
  active or the state is unknown, remain read-only unless the owner explicitly
  authorizes a specific live action.
- Do not send printer G-code, mutate Moonraker state, restart services, run
  `FIRMWARE_RESTART`, reboot, update software, flash firmware, or change
  networking without explicit authorization.
- Cutter, homing, load, unload, and selector macros can move hardware. Never
  describe them as dry runs.
- TradRack currently has 14 physical lanes but only gates 0-11 are commissioned
  and configured. Never ask the owner to load, check, or calibrate gates 12 or
  13 unless the owner explicitly commissions them and `CURRENT.md` is updated.
- Preserve unrelated changes in the working tree. Do not use destructive Git
  operations such as reset, clean, or checkout-based rollback.
- The GitHub repository is public. Never store or echo credentials, tokens,
  private keys, Wi-Fi secrets, or credential-bearing remote URLs.

## Change discipline

- Find the effective definition and all overrides before editing.
- Keep backups outside active configuration/include paths.
- Change one independent variable at a time when diagnosing behavior.
- Review the diff and define validation and rollback before applying a runtime
  restart.
- After an accepted change, update the appropriate knowledge file:
  stable state in `CURRENT.md`, rationale in `DECISIONS.md`, task status in
  `WORKLOG.md`, and dated milestones in `HISTORY.md`.
