# OPERON Architecture

## Principles
- Mobile-first, iOS + Android from one Flutter codebase.
- Offline-first operational workspace.
- Original operator records remain traceable.
- AI output is always distinguished from recorded plant facts.
- Safety-critical state requires authoritative source and/or human confirmation.

## Modules
Dashboard, Equipment, Logbook, Notes, Watchlist, Timers, Procedures, Process Circuits, Handover, OCR Intake, Private AI.

## Planned production layers
Flutter UI → application services → encrypted local store → optional authenticated sync API → PostgreSQL/object storage.

OCR pipeline: image → on-device OCR where available → equipment dictionary correction → review screen → explicit operator confirmation → structured record.

AI pipeline: local/open-weight model → retrieval layer → approved knowledge sources + operational records → citations/provenance in answers.

## Security
No plant documents or operational logs should be sent to a third-party AI provider by default. Production deployments require authentication, RBAC, encryption, audit events, backup/restore, retention policy, and site cybersecurity approval.
