# BE1 US35 Task 35.1 — meeting data source

Status: draft backend foundation; not complete US35. Base develop 3e3b043.

The authoritative meeting source is the new `meetings` and `meeting_participants` tables. Apply `sql/schema_be1_meetings.sql` manually after core/BE2/BE3 schema, initially on an isolated test DB. Existing program/enrollment/mentor tables are read and locked for authorization, never modified by this module. No runtime DDL, seed data, email sends or UI changes.

`MeetingRequest`: programId, title (trimmed 1..200), description (optional <=10000), location (trimmed 1..500), startsAt/endsAt as UTC Instant, distinct enrollmentIds (1..200). Participants must be ACTIVE enrollments in the selected PLANNED/ACTIVE program, resolving to ACTIVE INTERN users. No arbitrary client-supplied recipient emails/user IDs. Meeting start must be in the future; end after start. TIMESTAMP range 1970-01-01T00:00:01Z through 2038-01-19T03:14:07Z; microseconds preserved. FE should display Asia/Ho_Chi_Minh but submit instants with timezone.

`MeetingService.create(actorUserId, request)` returns meeting ID. `update(actorUserId, meetingId, expectedRevision, request)` replaces current details/participants atomically, preserving organizer/program. `cancel(actorUserId, meetingId, expectedRevision)` keeps meeting/participant rows, marks CANCELLED and increments revision. Updating cancelled meetings is rejected. A fresh cancellation of an already cancelled meeting with its current revision is a no-op. A stale revision is rejected; callers must reload.

Actor IDs must come from authenticated server sessions, never a request field. Service re-reads ACTIVE role from DB. ADMIN/HR may manage meetings. MENTOR may create only for currently assigned ACTIVE mentees; only the organizing Mentor may update/cancel, and must still have current assignments for every existing and proposed participant. After reassignment or inactive enrollment, HR/Admin manage existing meeting cleanup. INTERN cannot write. Authority is checked in the same transaction as writes; DAO does not commit.

Both meeting data and participants commit/rollback together. Dedicated connection sets SESSION timezone UTC; JDBC date reads/binds use UTC Calendar. Foreign keys use existing signed INT program/enrollment and signed BIGINT user IDs. No cascading deletion. Participant changes replace current links; there is not yet a versioned attendee history.

No HTTP routes/list/detail API provided in this foundation yet: FE must not assume an endpoint exists. The next increment must add authorized read/list routes and CSRF-protected writes with clear HTTP validation/conflict/error handling before UI integration. MeetingService is the backend entry point for that increment.

Task 35.2 must add transactional outbox/versioned delivery snapshots before sending mail: CREATE/CHANGE/CANCEL/reminder events, recipients including removed participants, retry schedule/claim locking and dedup by meeting/revision/event/recipient. Never perform SMTP while holding the scheduling transaction. Existing EmailService.sendEmail is reusable; no external messages sent in Task 35.1. Email exactly-once delivery must not be promised when SMTP acknowledgment is uncertain.

Open integration decisions: HR scope is currently all programs (existing project role policy); reminders and allowed lead time require a documented setting. Delivery recipient address (users.email vs profile contact email) must be explicitly selected in Task 35.2. Existing enrollment/mentor lifecycle owners retain their modules. Task 35.1 remains In Progress until migration and JDBC behavior are tested against MySQL, read/write API is supplied and FE/BE3 integration contract is reviewed.
