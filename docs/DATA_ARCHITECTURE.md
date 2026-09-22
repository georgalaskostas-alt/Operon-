# OPERON Data Architecture

## Storage direction
OPERON is offline-first. SQLite is the durable local store on iOS and Android. SharedPreferences is retained only as a one-time legacy migration source.

## Schema v1
`app_state` is a compatibility snapshot while domain repositories are progressively normalized.

`audit_events` is an append-only operational audit projection with indexed timestamp and equipment TAG. Existing IDs are never overwritten.

## Migration
On first SQLite load, if no SQLite snapshot exists, OPERON reads the legacy snapshot, writes it transactionally to SQLite, and records a migration marker. The legacy value is intentionally not deleted automatically so a failed rollout does not destroy the previous local state.

## Next normalization
Move domain data into dedicated tables: equipment, log entries, actions, watch items, notes, shifts, handovers, timers, knowledge revisions, process circuits/nodes, and procedure runs/step records.

Each migration must preserve IDs, timestamps, sources, shift linkage, and audit traceability.

## Safety / integrity
- Do not silently overwrite historical audit events.
- Database persistence is not proof of physical plant state.
- Safety-critical procedure, PTW and LOTO truth remains in approved site systems/processes.
- Schema upgrades must be explicit and migration-tested before production rollout.
