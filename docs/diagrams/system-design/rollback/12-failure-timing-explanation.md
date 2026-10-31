# FAILURE TIMING: flush success is not commit success

[Open the large diagram](12-failure-timing.svg)

PostgreSQL checks NOT NULL and CHECK constraints immediately. Deferrable constraints can be checked later, including at commit. The unique constraint in this project's SQL is not declared deferrable. After a PostgreSQL statement failure, normal work cannot simply continue in that transaction; rollback or suitable savepoint recovery is needed. After a Hibernate failure, end the unit of work rather than trusting its managed state. A lost commit acknowledgement is an uncertainty problem: resolve using stable operation identity and a fresh read or retry protocol.

**Rule:** Do not treat a connection timeout as proof that COMMIT did not happen.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```sql
-- Conceptual SQL fragment; only affects deferrable constraints.
SET CONSTRAINTS ALL DEFERRED;
-- A later COMMIT may still reject inconsistent data.
```

## Evidence to obtain

Use an isolated fixture with an explicitly deferrable constraint to separate statement success from commit failure. Separately test ambiguous commit responses with controlled fault injection; never infer correctness from logs alone.

## Explain without looking

If the connection disappears during commit, can we assume rollback?

## Source notes

- [Constraints](https://www.postgresql.org/docs/18/sql-set-constraints.html)
- [Rollback](https://www.postgresql.org/docs/18/sql-rollback.html)
- [Hibernate](https://docs.hibernate.org/orm/6.6/userguide/html_single/#flushing)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
