# OPERON Data Architecture

## Storage direction
OPERON is offline-first. SQLite is the durable local store on iOS and Android. SharedPreferences is retained only as a one-time legacy migration source.

## Schema v2
`app_state` is a compatibility snapshot while domain repositories are progressively normalized.

`audit_events` is an append-only operational audit projection with indexed timestamp and equipment TAG. Existing IDs are never overwritten.

`repository_meta` records repository-level migration metadata. `operator_timers` stores timers durably in SQLite instead of SharedPreferences.

## Migration
On first SQLite load, if no SQLite snapshot exists, OPERON reads the legacy snapshot, writes it transactionally to SQLite, and records a migration marker. The legacy value is intentionally not deleted automatically after a successful migration so a failed rollout does not destroy the previous local state. The migration marker prevents a deleted/empty SQLite snapshot from silently re-importing that legacy value. An explicit repository reset removes the legacy snapshot and keeps migration marked complete so cleared data cannot resurrect.

## Next normalization
Move domain data into dedicated tables: equipment, log entries, actions, watch items, notes, shifts, handovers, knowledge revisions, process circuits/nodes, and procedure runs/step records.

Each migration must preserve IDs, timestamps, sources, shift linkage, and audit traceability.

## Safety / integrity
- Do not silently overwrite historical audit events.
- Database persistence is not proof of physical plant state.
- Safety-critical procedure, PTW and LOTO truth remains in approved site systems/processes.
- Schema upgrades must be explicit and migration-tested before production rollout.
