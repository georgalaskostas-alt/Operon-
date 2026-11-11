# OPERON — Strategic Vision, Product Charter & Progress Governance

**Version:** 1.0  
**Approved strategic direction:** 2026-11-12 (user confirmed agreement)  
**Document owner:** OPERON product leadership  
**Repository:** `georgalaskostas-alt/Operon-` · **Branch:** `agent/initial-app-setup`  
**Companion implementation registry:** [OPERON_MASTER_PLAN.md](OPERON_MASTER_PLAN.md)  
**Status:** Living strategic charter. Strategic approval does not mean enterprise customer approval.

> **North star:** OPERON — Industrial Operations Intelligence. A refinery operations platform connecting people, equipment, shifts, procedures and authorized operational data into traceable, reusable knowledge. Build the system operators want to use every shift and management can trust.

## 1. Mission and commercial intent

Build and validate an enterprise-ready industrial operations collaboration and intelligence platform, with HELLENiQ ENERGY as the proposed first strategic customer and potential development partner. Demonstrate measurable operational value through a controlled pilot before negotiating scaled deployment and commercial licensing.

**Not the pitch:** another notes app.  
**The pitch:** continuity, accountability, traceability, reduced duplicate work and preservation of operational knowledge.

**Five operational questions:** What happened? Who observed it, when and with what evidence? Who owns the next action? Who received and acknowledged the handover? What can be learned and improved?

**Boundaries:** Do not replace SAP, DCS, SIS, PI System, PTW/LOTO, safety reporting or authorized human approvals. SAP remains authoritative for maintenance records. No autonomous safety-critical AI control. No real corporate data without written permission.

## 2. Five strategic pillars

| Pillar | Desired product outcome | Success evidence | Current maturity |
|---|---|---|---|
| A. OPERATIONS | One quick, structured operational record linked to equipment, shift, open actions, handover and audit; operator and foreman journals; same-role receipt acknowledgment | End-to-end device workflow, cross-device consistency, handover completion and ownership metrics | Local modules and DEV shared workflows/handovers exist; integration and enterprise testing incomplete |
| B. MAINTENANCE | Structured operator/foreman intake, foreman review, coordinator-approved SAP notification draft, then approved connector and returned SAP number | Reduced retyping, shorter time-to-notification, better completeness, low duplicate/rejection rates | Planned; no production SAP connector |
| C. COMPETENCY / WALP | Controlled learning, verified knowledge, supervised practical assessment, authorized qualification, expiry and reassessment | Approved competency matrix, assessment evidence, assessor sign-off, audited qualifications | Planned; no automatic AI certification |
| D. INTELLIGENCE | Source-grounded operational search, approved knowledge assistant, evidence-first engineering analysis, future read-only PI linkage | Source citations, quality benchmarks, access enforcement, human-reviewed outputs | Limited local deterministic assistant; AI Academy, PI and advanced analysis planned |
| E. MANAGEMENT & ASSURANCE | Unit-to-department-to-refinery visibility with source-linked metrics, escalations and governance | Validated KPI definitions, permission tests, audit, adoption and reliability | Planned dashboards; partial role/RLS foundation |

## 3. Non-negotiable product principles

1. **Record once, reuse with permission.** Canonical operational record and linked entities, not duplicated independent notes.
2. **Operator-first UX.** Premium, legible, bilingual Greek/English where useful; few taps, quick entry, clear empty states and accessible controls. Target routine entry in <30 seconds **to be validated** without omitting required information.
3. **Role-aware and accountable.** Operator/foreman handovers separated; same-role colleague receipt, not self-acknowledgment; authorized higher-level visibility. Enforce on server, not only UI.
4. **Evidence over claims.** Clearly distinguish implemented, tested, pilot-validated and production-ready.
5. **Human authority.** No AI-generated certification, operating instruction overriding approved procedures, or unreviewed SAP submission.
6. **Enterprise security by design.** Least privilege, audit trail, SSO/MFA/MDM strategy, offline conflict handling, retention, backups, privacy, IT/OT approvals.
7. **Synthetic data until authorized.** Never put real refinery information, confidential P&IDs, personnel records or credentials in the public development repository.

## 4. Product priorities and acceptance gates

### P1 — OPERON Core: commercially demonstrable prototype
**Priority: CRITICAL.** Focus on quick capture, structured handover, owned actions, searchable history and premium consistent UI.

**Required exit gates:**
- [ ] Shared operator and foreman handovers: creation, role scoping, linked actions, read-only legacy history, same-role acknowledgment, audit, concurrency and error handling.
- [ ] Verify handover creation/receipt across two authenticated devices/accounts; test RLS negative cases and offline/reconnect.
- [ ] Canonical operational record specification and staged linkage to equipment, action, watch and handover.
- [ ] Consistent premium UI, Greek/English text review, accessibility and device usability tests.
- [ ] Automated tests, regression checks and demo script with synthetic data.
- [ ] Security review of RPC authorization and database policies.

### P2 — HELLENiQ ENERGY pilot proposal
**Gate:** Corporate sponsor and written approval. Request a designated operations sponsor, small cross-functional user group, agreed development time, IT/OT cybersecurity review, controlled data access, pilot KPIs and clear intellectual-property/commercial terms. FCC is a proposed pilot candidate, not an agreed location.

**Measure baseline versus pilot:** median entry time; handover acknowledgment coverage; overdue/unowned actions; time-to-notification; coordinator effort; record completeness; user adoption; reliability; data/security incidents. No fabricated ROI.

### P3 — Enterprise product
SSO, multi-unit hierarchy, robust sync, audit/retention, SAP notification draft and optionally authorized SAP integration, management dashboards, availability and recovery requirements.

### P4 — OPERON Intelligence
WALP, approved-source AI Academy, source-linked engineering investigations, approved read-only historian integration, cross-site scalability.

**Planning horizons, not delivery promises:** P1 0–8 weeks; pilot evaluation 8–12 weeks after approvals and readiness; enterprise 3–9 months; advanced intelligence 9–24 months. Re-estimate based on staffing, dependencies and evidence.

## 5. Baseline snapshot — 2026-11-12

**Source:** GitHub implementation inventory and user-reported Flutter/iPhone tests. This is a development baseline, not an independently audited release.

| Capability | Evidence and status | Remaining |
|---|---|---|
| Flutter iPhone prototype | Device screenshots, successful build/install reported; local modules exist | Formal device acceptance, accessibility and stability |
| Quick entry, local logbook, equipment, notes, OCR, timers, procedures | Present in repository per master registry | Unified record, cloud linkage, production reliability |
| Shared workflows and Supabase | DEV implementation, membership/role foundation and RLS | Cross-device realtime, permission/security testing |
| Operator/foreman handover | Role-scoped UI and SQL migration in repository; iPhone screenshots show records and filtering | Full two-account receipt test, audit verification, edge cases |
| Linked workflows and acknowledgment | Schema/RPC/UI foundation present in development | End-to-end validation and synchronization |
| Static checks | User reported `flutter analyze` clean and 16 tests passing after branch updates | Broader automated, integration and security tests |
| SAP / PI / enterprise SSO | Not integrated | Corporate approval, APIs, implementation and assurance |
| WALP / AI Academy / executive dashboards | Planned | Detailed requirements, approved sources, design and implementation |

**Important:** Screenshots and automated tests do not establish production readiness. Database migration presence in GitHub is not proof that every target environment has applied it.

## 6. Work register (initial prioritized backlog)

| ID | Work item | Status | Dependency | Completion evidence |
|---|---|---|---|---|
| CORE-01 | Two-user, same-role handover receipt test | TODO | Second account/device | Screenshots and backend audit |
| CORE-02 | Linked task/handover cross-device validation | TODO | Test records, backend | Both users see identical links and status |
| CORE-03 | RLS/RPC authorization negative tests | TODO | DEV backend access | Unauthorized cases rejected |
| CORE-04 | Premium consistent UX and copy across workflows | IN PROGRESS | UI review | Reviewed screenshots and usability check |
| CORE-05 | Canonical operational record model | TODO | Data architecture | Approved schema and migration strategy |
| CORE-06 | Reliable realtime/offline/reconnect | TODO | Sync design | Automated and device tests |
| CORE-07 | Unit/equipment-linked searchable history | TODO | CORE-05 | Source-linked queries and UI |
| BIZ-01 | HELLENiQ ENERGY pilot value proposition and demo | TODO | CORE acceptance | Demo, KPIs and pilot charter |
| BIZ-02 | IP, employment conflict and commercial legal review | TODO | Counsel/company process | Written agreed terms |
| MAINT-01 | SAP Notification Assistant draft-only MVP | TODO | Approved field mapping | Foreman/coordinator demo |
| WALP-01 | Confirm official WALP definitions and approvers | TODO | Corporate stakeholder | Approved scope |
| AI-01 | Grounded AI assistant evaluation framework | TODO | Approved data/sources | Traceable benchmark results |

Status vocabulary: **TODO, IN PROGRESS, BLOCKED, IMPLEMENTED, TESTED, PILOT-VALIDATED, PRODUCTION-READY**. Never mark TESTED without evidence, or PRODUCTION-READY without formal acceptance.

## 7. Reporting contract — when asked “πού βρισκόμαστε;”

Provide a detailed progress report using the **latest repository state and available test/deployment evidence**, not memory alone. Report:

1. Snapshot date, branch and latest relevant commit.
2. Executive summary: achieved outcomes, top risks and next decision.
3. Pillar-by-pillar status (implemented/tested/planned; evidence links).
4. Completed items since last report with commits/tests.
5. In-progress and remaining backlog, dependencies and blockers.
6. Quality/security/enterprise readiness, explicit unknowns.
7. Pilot readiness and KPI baseline status.
8. Prioritized next 3–5 actions, owner, acceptance test and estimated effort where supportable.
9. Changes to scope, architecture, business assumptions or timelines.
10. Update this charter and the implementation registry **during active development/reporting when GitHub write access is available**; commit and identify changes. Never imply autonomous/background monitoring or updates.

**Progress percentages:** Avoid arbitrary percentages. If requested, calculate against a defined weighted scope and show denominator and assumptions. Do not confuse number of screens with delivered enterprise value.

## 8. Change log

| Date | Version | Change | Evidence |
|---|---|---|---|
| 2026-11-12 | 1.0 | Strategic vision approved by user; five pillars, commercialization approach, acceptance gates, baseline and progress reporting contract established | This charter and companion master plan |

## 9. Key business risks and decisions

- **IP/employment:** Clarify ownership, use of employer resources, confidentiality and conflict of interest before commercial negotiation.
- **Pilot access:** No operational data or corporate integrations without permission.
- **Adoption:** Operator UX must reduce workload; validate on shift with real users after authorization.
- **Security:** Public/dev stack is not an approved refinery production architecture.
- **Scope:** Avoid building all planned modules before proving OPERON Core.
- **Commercial:** Prefer paid pilot followed by negotiated multi-year licensing/support if justified; no exclusivity or source-code transfer without legal/commercial evaluation.
