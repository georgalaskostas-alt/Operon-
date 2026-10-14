# OPERON Enterprise — implementation plan

## Goal
A configurable industrial shift collaboration and competency platform, built from the existing offline-first Flutter application.

## Current boundary
The repository currently stores operator data locally. The workflow model in `lib/enterprise/operations_workflow.dart` is an offline, deterministic proof of concept **only**. It does not provide authentication, cross-device sync, real-time notifications, or server-enforced permissions.

## Planned user roles
Operator, shift foreman, coordinator, department supervisor, unit engineer. Roles are illustrative: actual reporting, approval, and emergency escalation paths require customer validation.

## Phase 1: multi-user foundation
1. Define tenant/site/unit/shift/user membership, permission matrix, task ownership, workflow templates and audit events.
2. Implement a secure server API and database with enforced row-level authorization, authenticated identities and immutable audit records.
3. Add local outbox, retry, idempotency keys, version/conflict resolution and reconnect synchronization.
4. Add push notifications with acknowledgements, escalation and offline fallback.
5. Test concurrent editing, permission denial, audit integrity and recovery from connectivity loss.

## Phase 2: approvals
Configurable workflow templates per item type; submit/review/return/close actions; separation of duties; engineering and supervisor review as applicable. Urgent safety reporting must never wait on app approval.

## Phase 3: WALP
Question bank, curriculum by position, exam attempts, practical assessments, evidence, assessor sign-off, multi-level approval and expiry/reassessment. Company-authorized personnel—not AI—determine official competency certification.

## Phase 4: approved knowledge and AI Academy
Versioned documents, permission-aware retrieval, citations to source passages, answer abstention on missing evidence, evaluation sets and audit logs. No invented live process readings or operational instructions.

## Enterprise acceptance
Security and privacy review, IP/data rights review, pilot with synthetic data, availability and support requirements, measurable operational outcomes, and formal customer approval before production use.
