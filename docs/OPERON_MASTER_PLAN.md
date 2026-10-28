# OPERON — Master Product Plan & Feature Registry

**Version:** 1.0 · **Date:** 2026-10-28 · **Status:** Living project charter / implementation inventory  
**Repository:** `georgalaskostas-alt/Operon-` · **Development branch:** `agent/initial-app-setup`  
**Data classification:** Design and synthetic demonstration only. No real refinery data, credentials, P&IDs, operating limits or proprietary documents.

> **Purpose:** This document is the authoritative planning checklist for OPERON: what we intend to build, what exists in code, what has been tested, what remains unfinished, and the next implementation priorities. A screen or prototype is not equivalent to a production-ready feature.

## 1. Vision and product boundary

OPERON is a **unified refinery operations, collaboration, competency and engineering-intelligence platform**. It serves operators, foremen, coordinators, engineers, department supervisors and executives, while preserving traceability across shifts, equipment, maintenance requests, procedures and knowledge.

Core principle: **record once, review appropriately, reuse across authorized workflows**. A single operational record may link to equipment, watch items, actions, shift handovers, engineering review, SAP notification drafts and management reports.

**Do not replace SAP.** SAP remains the system of record for official maintenance notifications, work orders, planning, materials and costs. OPERON simplifies intake, drafting, coordination and status visibility, subject to approved SAP integration.

**Do not replace DCS, SIS, PI System, PTW/LOTO systems or mandatory safety reporting.** OPERON is not a control or safety system. Urgent safety reporting never waits for application workflow approval.

## 2. Organization and role hierarchy

The user-described organizational chain:

1. Group Refineries Director (Διευθυντής Διυλιστηρίων Ομίλου)
2. Refinery Director (Διευθυντής Διυλιστηρίου)
3. Operations Director (Διευθυντής Λειτουργίας)
4. Department Supervisor (Προϊστάμενος Τμήματος)
5. Engineer (Μηχανικός)
6. Coordinator (Συντονιστής)
7. Unit Foreman (Εργοδηγός)
8. Operators (Χειριστές)

**Organizational data model:** Group → Refinery → Department → Unit → Shift/position. One department supervisor oversees **multiple units**; each unit has its **own foreman**. Example departments: Conversion (including FCC, Alkylation, Vacuum as described), Dispatch/Movement, Distillation. Exact unit assignment must be configurable and validated with the site.

**Important:** The hierarchy is for visibility and reporting; technical approvals, functional responsibility, competence authorization and emergency escalation require their own configurable permission matrices. Do not automatically route every item through all eight roles.

**Current:** Operator, Foreman, Coordinator, Supervisor and unitEngineer appear in the development workflow/RLS foundation. **Gap:** Full eight-level hierarchy, multiple refineries, multi-unit department visibility, executive roles and organizational authorization.

## 3. Status definitions

- **IMPLEMENTED — LOCAL:** Present in Flutter code using local storage; not necessarily cloud synchronized.
- **IMPLEMENTED — CLOUD DEV:** Present in the development Supabase backend/UI, using synthetic data.
- **TESTED — LIMITED:** Automated checks and/or a stated device test; not a site acceptance test.
- **PARTIAL:** A usable foundation exists, but important requirements remain.
- **PLANNED:** Product requirement or design direction; not implemented.
- **DEPENDENT:** Requires corporate approval, infrastructure, SAP/PI integration, licensed content or validated operating procedures.

All statuses below refer to the development repository as inspected on 2026-10-28; future changes must update this register.

## 4. Feature registry — complete scope

| ID | Module / capability | Current status | Evidence / present scope | Outstanding work |
|---|---|---|---|---|
| OP-01 | Premium Flutter shell, dashboard, Greek/English | IMPLEMENTED — LOCAL | `lib/main.dart`, `dashboard_screen.dart`, localization, theme | UX testing, accessibility, production polish |
| OP-02 | Quick Entry, free-text interpretation and review | IMPLEMENTED — LOCAL | `quick_entry_parser.dart`, `quick_entry_review_screen.dart` | Structured unified record, validation, accuracy tests |
| OP-03 | Digital Logbook / immutable-style event timeline | IMPLEMENTED — LOCAL | `logbook_screen.dart`, local store | Server-side immutable audit/event model, cloud sync |
| OP-04 | Equipment registry, state, history and timeline | IMPLEMENTED — LOCAL | `equipment_screen.dart`, `equipment_intelligence_screen.dart`, `equipment_timeline_screen.dart` | Master equipment hierarchy, SAP/PI tag mapping, verified status sources |
| OP-05 | Equipment operational knowledge | IMPLEMENTED — LOCAL | `equipment_knowledge_screen.dart`, local knowledge model | Approved references, source/version control, review |
| OP-06 | Watch Center / active watch items | IMPLEMENTED — LOCAL | `watch_center_screen.dart` | Shared ownership, expiry, escalation, cross-shift sync |
| OP-07 | Pending actions and carried/overdue tasks | IMPLEMENTED — LOCAL | `actions_screen.dart`, local store | Unified cloud action ownership, due dates, lifecycle |
| OP-08 | Operator notes, pinning, resolution | IMPLEMENTED — LOCAL | `notes_screen.dart` | Permissions, sharing policy, retention |
| OP-09 | Timers, reminders, acknowledgement/snooze | IMPLEMENTED — LOCAL | `timers_screen.dart`, notification service | Reliability tests, permissions, background behavior, server alerts |
| OP-10 | Camera/OCR handwritten notes with review | IMPLEMENTED — LOCAL | `scan_notes_screen.dart`, `note_ocr_service.dart` | OCR accuracy benchmarks, secure photo handling, explicit approval |
| OP-11 | Procedures, versioned references and checklists | IMPLEMENTED — LOCAL / PARTIAL | `procedures_screen.dart`, `procedure_run_screen.dart` | Approved document governance, controlled revisions, signatures |
| OP-12 | Process circuits, upstream/downstream, P&ID references | IMPLEMENTED — LOCAL / PARTIAL | `process_circuits_screen.dart` | Verified engineering topology, approved P&ID integration |
| OP-13 | Local Shift Handover and acknowledgement | IMPLEMENTED — LOCAL | `handover_screen.dart`, handover models | Connect to shared cloud handovers and action records |
| OP-14 | Shared cloud workflows, role reviews and audit events | IMPLEMENTED — CLOUD DEV / TESTED — LIMITED | `shared_workflows_screen.dart`, SQL migration, server RPCs | Site-approved approval matrix, end-to-end concurrency/UX tests |
| OP-15 | Realtime unit workflow subscription | PARTIAL | Realtime subscription code and publication configured | **Cross-device test NOT completed**; reconnect, deduplication, offline recovery |
| OP-16 | Cloud shift handover creation and 30-record list | IMPLEMENTED — CLOUD DEV / PARTIAL | `20261024_001_shift_handovers.sql`, shared workflows UI | **Latest iPhone handover test pending**; linked tasks, receiver acknowledgement, editing rules |
| OP-17 | Account login, unit membership, RLS | IMPLEMENTED — CLOUD DEV / TESTED — LIMITED | `operon_cloud.dart`, membership/RLS migration | Corporate SSO, MFA, lifecycle, security review |
| OP-18 | Operations Center role/approval demo | IMPLEMENTED — LOCAL | `operations_center_screen.dart`, `operations_workflow.dart` | Distinguish from cloud workflow; avoid duplicated business logic |
| OP-19 | Local grounded OPERON assistant | IMPLEMENTED — LOCAL / LIMITED | `operon_assistant.dart`: deterministic responses from local records | True local LLM, RAG, evaluation, source-grounded retrieval |
| OP-20 | Shared operational record linking all modules | PLANNED | Architecture decision | Common IDs, source events, relationships, revision/audit |
| OP-21 | SAP Notification Assistant | PLANNED | Confirmed use case: operator reports **verbally via unit foreman**; coordinator lacks time for SAP notifications | Structured intake → foreman review → coordinator approval → secure SAP notification creation → returned SAP number |
| OP-22 | SAP work order status visibility | DEPENDENT | Strategic extension only | Read-only status via authorized integration; SAP remains owner |
| OP-23 | Department Command Center | PLANNED | Multi-unit supervisor concept | Unit overview, exceptions, recurring issues, ownership, daily brief |
| OP-24 | Operations Director Dashboard | PLANNED | Cross-department oversight | Aggregated risks, delays, cross-unit dependencies |
| OP-25 | Refinery Director Dashboard | PLANNED | Site-wide executive view | Verified site KPIs, decisions, escalations |
| OP-26 | Group Refineries Dashboard | PLANNED | Multi-refinery view | Normalized KPIs, comparisons with context, data segregation |
| OP-27 | Escalation rules and management reporting | PLANNED | Product design | Severity/age/repetition rules, explicit owner, acknowledgements |
| OP-28 | WALP competency and certification platform | PLANNED (existing roadmap) | `docs/ENTERPRISE_ROADMAP.md` phase 3 | See section 5 |
| OP-29 | AI Academy and approved knowledge RAG | PLANNED | `docs/ENTERPRISE_ROADMAP.md`, `docs/ROADMAP.md` | Approved sources, citations, abstention, evaluation, access control |
| OP-30 | Engineering Copilot / incident investigation | PLANNED | Strategic concept from related refinery engineering discussions | Evidence-first investigations, hypotheses, provenance, human review |
| OP-31 | Semantic engineering model | PLANNED | Strategic concept | Equipment/tag/circuit/document graph, controlled mapping |
| OP-32 | PI System / PI Vision integration | DEPENDENT | Strategic concept, **not implemented** | IT-approved read-only connector, historian quality/timestamp, tag authorization |
| OP-33 | Controlled P&ID change proposals | DEPENDENT | Strategic concept | Engineering review, approved document control, version history |
| OP-34 | Secure offline/cloud sync | PARTIAL | Local persistence + separate cloud shared workflows | Outbox, retries, idempotency, conflict resolution, encrypted sync |
| OP-35 | Push notifications, cross-device alerts | PLANNED | Local reminders exist; Realtime subscription exists | Push delivery, acknowledgements, escalation, delivery tests |
| OP-36 | Enterprise deployment and assurance | PLANNED | Existing architecture/roadmaps | SSO, MDM, backups, audit retention, security/privacy/IP reviews, monitoring, DR |

**Note:** OP-30–OP-33 are **strategic candidates**, not evidence that the separate FCC Assistant project has already been merged into OPERON.

## 5. WALP — Operator knowledge, qualification and competency

**Working label:** WALP. The repository already calls the competency phase **WALP**. Its exact formal expansion, corporate meaning and official certification policy **must be confirmed with the company**; do not invent a standard or claim accreditation.

### 5.1 Purpose

WALP will provide an auditable view of each operator's **knowledge level and verified competence** by refinery, unit, job position, subject and authorization scope. It must distinguish:

1. **Training completed** — material attended/read.
2. **Knowledge demonstrated** — examination results against an approved question bank.
3. **Practical competence demonstrated** — supervised field assessment and evidence.
4. **Authorization/certification granted** — signed decision by company-authorized assessors/approvers.
5. **Validity maintained** — expiry, refresher, reassessment and revocation where applicable.

**No AI-generated score or quiz alone may certify a person as qualified for safety-critical duties.** An AI tutor may coach and explain approved material, but official assessment and sign-off follow controlled policy.

### 5.2 Required WALP features

| WALP ID | Feature | Status | Acceptance intent |
|---|---|---|---|
| W-01 | Competency matrix by refinery/unit/position | PLANNED | Required competencies and levels explicitly defined per role |
| W-02 | Controlled curriculum and approved learning sources | PLANNED | Source, revision, owner and effective date recorded |
| W-03 | Question bank and assessment blueprint | PLANNED | Reviewed questions, topic/level coverage, versioning |
| W-04 | Knowledge exams | PLANNED | Authenticated attempt, controlled timing, scoring, audit |
| W-05 | Practical field assessment | PLANNED | Assessor, criteria, observed evidence and result |
| W-06 | Knowledge/competency gap analysis | PLANNED | Missing requirements by person/role without overclaiming |
| W-07 | Learning path and reassessment | PLANNED | Approved remediation and scheduled reassessment |
| W-08 | Assessor sign-off and multi-level approvals | PLANNED | Separation of duties and verified authority |
| W-09 | Qualification validity, expiry and renewals | PLANNED | Clear effective/expiry dates and reminders |
| W-10 | Operator personal competency dashboard | PLANNED | User sees own requirements, progress and verified status |
| W-11 | Foreman/engineer/supervisor training overview | PLANNED | Authorized aggregate view, privacy-preserving |
| W-12 | AI Academy / tutor | PLANNED | Source-cited explanations, safe abstention, no auto-certification |
| W-13 | Training effectiveness and quality assurance | PLANNED | Item analysis, assessment reliability, appeals/corrections |
| W-14 | Exportable controlled certification record | PLANNED | Immutable evidence links, approvers and revision history |

### 5.3 Example competency domains (illustrative, NOT approved syllabus)

- Process fundamentals and unit-specific operating concepts.
- Equipment identification, process circuits, instruments and P&ID interpretation.
- Approved procedures, abnormal-condition recognition and escalation.
- Shift communication, logbook and handover quality.
- Maintenance notification reporting and boundaries of authority.
- Applicable site safety, emergency response and permit awareness **only from approved training material**.

### 5.4 Privacy and governance

Individual knowledge profiles are personnel data. Define lawful basis, access, retention, correction/appeal process, auditability and HR/training integration with the employer. Avoid unsupported ranking of individuals. Only authorized assessors may grant/revoke formal qualifications. No real employee records in the public/development repository.

## 6. SAP Notification Assistant — workflow and boundaries

**Observed current workflow:** operator informs the **unit foreman verbally**; the coordinator is responsible for entering **SAP Maintenance Notifications**, and workload/time is a bottleneck.

**Target:** Preserve urgent verbal reporting and foreman oversight, while capturing a structured report early and preparing a notification draft so the coordinator need not retype everything.

1. Operator or foreman creates a structured operational record (unit, equipment, observation, time, attachments if allowed).
2. Foreman reviews completeness and validates routing.
3. OPERON prepares a **draft** notification; any AI-generated text is clearly labeled and editable.
4. Coordinator checks technical-object mapping, priority and required SAP fields and approves submission.
5. **Only after approved corporate integration**, a secure server-side connector creates an SAP Maintenance Notification.
6. OPERON records the official SAP notification number and displays authorized status updates.
7. SAP remains authoritative; no automatic creation of work orders or safety approvals.

**Open requirements:** SAP ECC vs S/4HANA, available interfaces/API, notification types, functional locations/equipment identifiers, approval ownership, attachment policies, duplicate detection, idempotency, SAP error recovery and IT/security approval.

## 7. Unified information model — planned

Design canonical entities with immutable source links: `organization`, `site`, `department`, `unit`, `shift`, `membership`, `equipment`, `operational_record`, `action`, `watch_item`, `handover`, `handover_ack`, `workflow`, `audit_event`, `maintenance_request`, `sap_notification_link`, `procedure_version`, `training_requirement`, `assessment_attempt`, `practical_evidence`, `competency_decision`, `qualification_validity`.

Do not migrate all existing local data into cloud automatically. Design a controlled migration, access matrix and data lineage first.

## 8. Implementation progress and verification

**Verified from repository:**
- Flutter application and local operator modules listed in section 4 exist.
- Supabase initialization is optional via `OPERON_SUPABASE_URL` and `OPERON_SUPABASE_PUBLISHABLE_KEY`; absence leaves local mode available.
- Cloud workflow migrations and handover migration are committed.
- Cloud workflow RPCs and RLS were previously applied to the development Supabase project.
- Recent user-reported local verification after the handover UI commit: **`flutter analyze` — no issues; `flutter test` — 16 tests passed**.
- Realtime subscription exists in code but **has not been validated across two devices**.
- Latest cloud shift-handover UI **has not yet been confirmed tested on the primary iPhone**.
- No real SAP, PI, enterprise SSO, production deployment or official WALP assessment is integrated.

**Do not infer** production readiness from successful unit tests or a working development screen.

## 9. Prioritized execution roadmap

| Phase | Goal | Exit / acceptance criteria |
|---|---|---|
| P0 | Baseline, feature registry and regression checks | Inventory agreed; tests green; no real site data |
| P1 | Complete shared Shift Handover | Linked open actions; next-shift receipt acknowledgement; RLS, audit and device tests |
| P2 | Unified operational record | One source record linked to logbook, equipment, actions, watch and handover; migration tests |
| P3 | SAP Notification Assistant — draft only | Operator/foreman intake, coordinator review, validated draft, duplicate checks, no SAP connection required |
| P4 | Organization and department model | Multi-unit department supervisor, foreman per unit, complete hierarchy, permission tests |
| P5 | WALP foundation | Approved competency matrix, question bank, exams, assessor workflow, auditable evidence |
| P6 | Department/Executive dashboards | Verified aggregates, drill-down, escalation and access control |
| P7 | AI Academy / engineering intelligence | Approved sources, grounded citations, abstention, evaluation and privacy controls |
| P8 | Enterprise integrations | SAP/PI pilots only with written authorization and supported APIs |
| P9 | Production hardening | Security, privacy, availability, backup/restore, MDM, support and formal site acceptance |

Phases may be parallelized after data-model and authorization dependencies are resolved. The order is a planning proposal, not a fixed promise.

## 10. Outcome measures and business case

Measure baseline versus pilot:
- Time from operator observation to first digital record.
- Time from first record to SAP Notification creation.
- Coordinator active minutes per notification and **total team effort**, not just shifted workload.
- Draft completeness, SAP rejection/duplicate rates.
- Unacknowledged handovers and carried actions.
- Overdue actions and time to assignment/closure.
- Recurring equipment issues and source-linked investigations.
- Training completion, validated knowledge gaps, assessor turnaround, expired qualifications.
- User adoption, reliability, synchronization errors and security incidents.

Never claim cost savings, avoided incidents or competence improvements before evidence from a controlled pilot.

## 11. Non-negotiable guardrails

1. Synthetic data only until employer approval.
2. No confidential plant documents, employee records, credentials or process readings in public GitHub.
3. No safety-critical AI control, PTW/LOTO assertion, procedural sign-off or autonomous certification.
4. SAP and authoritative engineering systems retain system-of-record ownership.
5. Server-side role enforcement, least privilege, auditability, version checks and traceability.
6. No invented live measurements; distinguish observed data, user reports, inference and AI drafts.
7. Human review for maintenance submissions, technical conclusions and WALP certification.
8. Corporate IT/OT cybersecurity and privacy approvals before any production connectivity.

## 12. Immediate next actions

- [ ] Install and test latest cloud Shift Handover on primary iPhone with synthetic data.
- [ ] Implement cloud handover ↔ open workflow/action links.
- [ ] Implement receiver acknowledgement, audit event and permission checks.
- [ ] Validate workflow Realtime on a second accessible device or controlled equivalent.
- [ ] Specify canonical operational record and safe local/cloud migration.
- [ ] Document SAP notification fields and existing site workflow **without entering confidential data**.
- [ ] Confirm formal definition of WALP, approved assessors, competency levels and certification rules.
- [ ] Draft department/unit role-permission matrix.
- [ ] Keep this document updated at each merged milestone.

## 13. Change control

Update the **status, evidence, pending work and tests** for each affected ID in every relevant feature PR. Do not mark `IMPLEMENTED` solely because a UI mockup exists. Any change in scope (e.g., AI, SAP integration, WALP certification) must retain explicit safety, privacy and authorization boundaries.

**Related repository docs:** `docs/PRODUCT_SPEC.md`, `docs/ROADMAP.md`, `docs/ENTERPRISE_ROADMAP.md`, `docs/ARCHITECTURE.md`, `docs/DATA_ARCHITECTURE.md`, `docs/MULTIUSER_FOUNDATION.md`.
