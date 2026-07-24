# Printer knowledge index

Last reconciled: 2026-07-23

This is the authoritative, compact knowledge set for the printer. It was
distilled from the ChatGPT handoff candidates, this Codex session, active
configuration, generated G-code, and current logs.

## Read order

- [CURRENT.md](CURRENT.md) — stable current state and operating constraints
- [WORKLOG.md](WORKLOG.md) — active work, monitoring, and near-term backlog
- [DECISIONS.md](DECISIONS.md) — durable choices and their rationale
- [RUNBOOKS.md](RUNBOOKS.md) — approved safe procedures
- [HISTORY.md](HISTORY.md) — condensed milestones and superseded facts

For ordinary work, `CURRENT.md` and `WORKLOG.md` are enough. Read the other
files only when relevant.

## Evidence labels

- **Config-verified** — present in active configuration
- **Runtime-validated** — observed in current logs or generated G-code
- **User-confirmed** — physical fact or outcome supplied by the owner
- **Unresolved** — cannot yet be established safely

Evidence confidence and temporal state are separate. A historically verified
fact can still be superseded.

## Source-of-truth rules

- Exact current settings: active `.cfg` files
- Runtime MMU state, lane metadata, calibrations, and counters:
  `mmu/mmu_vars.cfg`
- Recent behavior: `/home/pi/printer_data/logs/` on the printer host
- Orca behavior: exported presets and generated G-code
- Physical identity: owner observation, photographs, measurements, or purchase
  records

The original seven candidate files remain under
`codex_uploads/knowledge-handoff/` outside this Git repository. They are a
reconstructed archive, not raw transcripts, and should only be consulted for
historical research.

The workspace-level `/home/pi/printer_data/AGENTS.md` is a local routing
pointer to the tracked `config/AGENTS.md`. Recreate that small pointer after a
full host restore if Codex is opened from the `printer_data` directory.

## Maintenance

- Keep volatile lists and counters in their existing machine-readable sources
  instead of copying them here.
- Update `CURRENT.md` when stable operating state changes.
- Move completed or abandoned tasks from `WORKLOG.md` into `HISTORY.md`.
- Record rationale in `DECISIONS.md`, not just the final value.
- Keep all tracked content safe for a public repository.
