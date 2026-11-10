# OPERON multi-user foundation (prototype)

Status: **schema committed, not deployed**. Existing iPhone release continues using the offline demo repository and SharedPreferences. No Supabase credentials or company data are stored in this repository.

## Scope
- Units, administrator-provisioned memberships, workflow items and append-only workflow events.
- Authenticated users can read only records for units where they hold an active membership (RLS).
- Mobile clients have no direct INSERT/UPDATE/DELETE grants on workflow tables.
- Two SECURITY DEFINER RPC functions validate the authenticated user and unit membership for submission and state transitions. The transition function locks the row, checks the expected revision, records the actor's role and audit note, and rejects unauthorized transitions.
- This mirrors the existing **fixed demo approval path**. Configurable paths, escalation, emergency bypass, attachments and notifications remain future work.

## Security and readiness caveats
1. **Do not apply to a production refinery database yet.** First review the SQL with a PostgreSQL/Supabase security engineer, test privilege grants, RLS, cross-unit access, concurrency, disabled users and audit immutability.
2. Memberships must be provisioned by trusted administrators, never by users from the app. Never ship service-role keys in an iOS build.
3. Use only synthetic data until data processing, IP rights, hosting region, corporate infosec and access approval are resolved.
4. The schema is not a live backend: no Supabase project configured, no Flutter authentication, no remote repository, no realtime subscriptions and no push notifications.
5. Existing local demo records are not migrated to a server. Never silently upload local records.

## Integration sequence
1. Provision a nonproduction Supabase project and apply the reviewed migration.
2. Create test users, units and role memberships through a trusted administrator.
3. Add Flutter authentication and remote repository with explicit environment configuration.
4. Add integration tests using **two distinct test accounts**, cross-unit access attempts, unauthorized approvals, duplicate submissions and concurrent revisions.
5. Add offline outbox/conflict handling, reconnect and audit synchronization.
6. Validate on two real iPhones before adding push notifications or enterprise rollout.

## SQL RPC API
- `operon_submit_workflow(p_unit_id uuid, p_title text) -> uuid`
- `operon_transition_workflow(p_workflow_id uuid, p_expected_revision integer, p_next_state text, p_note text) -> integer`

Use authenticated user JWTs only. Do not send or trust an actor ID or role from the client.
