# Project report — CampusCare

Use this outline to prepare the final report. Update screenshots, test outcomes, and counts from the final running build; do not report unexecuted tests as passed.

1. **Title page** — project title, course, team, institution, faculty guide, date.
2. **Abstract** — campus maintenance coordination, workflow, and DBMS contribution.
3. **Problem statement** — fragmented issue reporting, approval, assignment, tracking, and inventory visibility.
4. **Objectives and scope** — student/faculty/admin/technician portals; request lifecycle; asset and room catalog; departments; SLA; inventory; analytics.
5. **Requirements** — functional requirements, non-functional requirements, role permissions, assumptions, and exclusions.
6. **System architecture** — browser/Next.js application, API routes, MySQL relational system of record, MongoDB event store; local Windows deployment (no Docker).
7. **Workflow** — request submission, faculty review, admin assignment, technician updates, requester confirmation, feedback, audit trail.
8. **Database design** — ER diagram, entity descriptions, relational schema, PK/FK constraints, cardinalities, normalization rationale, and MongoDB event document structure.
9. **Database implementation** — schema/seed scripts, indexes, views, triggers, stored procedures/functions, transaction boundaries, sample SQL queries, and connectivity configuration.
10. **Implementation** — role-aware pages, authentication, validation, APIs, dashboards, charts, and user-visible status changes.
11. **Testing** — test environment, test cases, expected/actual results, evidence screenshots, SQL integrity checks, and limitations. Include only tests actually executed.
12. **Results** — actual seed scale and demonstrated workflow outcomes.
13. **Conclusion and future work** — institutional SSO, notifications, production security, richer mobile UX, integrations.
14. **References and appendices** — source handout, database scripts, setup guide, query examples, screenshots.

## Suggested test matrix

| ID | Scenario | Expected result |
|---|---|---|
| T01 | Administrator login | Admin dashboard loads with operational metrics |
| T02 | Student registration/login | Student account created and role-specific dashboard shown |
| T03 | Student submits request | Request persisted and visible to authorized faculty/admin |
| T04 | Faculty approves/rejects | Decision, reviewer, timestamp, and notes persisted |
| T05 | Admin assigns department technician | Assignment linked to request, technician, and assigning admin |
| T06 | Technician updates progress | Activity/status is visible to student/faculty/admin |
| T07 | Completion and feedback | Resolution and rating persist; reports update |
| T08 | Inventory part usage | Stock decremented and low-stock state updated |
| T09 | Department workload report | Counts aggregate by department/technician |
| T10 | Referential integrity | Invalid foreign-key references rejected |
