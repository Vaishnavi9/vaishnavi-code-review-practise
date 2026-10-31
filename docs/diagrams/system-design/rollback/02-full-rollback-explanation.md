# ROLLBACK: discard the whole transaction

[Open the large diagram](02-full-rollback.svg)

Use full rollback when one required step fails and keeping earlier changes would violate the business rule. Database rollback does not reset Java fields, retract logs or emails, undo external calls, or reverse another transaction that already committed. Generated sequence numbers need not be returned, so gaps do not prove lost records. Do not try to continue normal JPA work after a failed flush; finish rollback and begin a fresh unit of work.

**Rule:** Rollback covers this transaction, not every action the program performed.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```sql
BEGIN;
-- Write A, then encounter a failure.
ROLLBACK;
```

## Evidence to obtain

Cause a known constraint failure after an earlier write. Check from a fresh transaction that the earlier write is absent. Do not infer rollback just from an exception being printed.

## Explain without looking

Does rollback erase rows committed by a previous transaction?

## Source notes

- [Rollback](https://www.postgresql.org/docs/18/sql-rollback.html)
- [Hibernate](https://docs.hibernate.org/orm/6.6/userguide/html_single/#flushing)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
