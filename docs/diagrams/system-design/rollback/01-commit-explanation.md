# COMMIT: finish the database transaction

[Open the large diagram](01-commit.svg)

Use one transaction when related database changes must become committed together. The owning transaction boundary commits; a method that joined an outer transaction does not commit independently. Normal Hibernate flushing sends pending SQL before commit. A successful commit must be established, not assumed from a method body returning. Durability depends on database durability settings; replication lag is a separate issue. This is a proposed two-write lesson, not a claim that an outbox exists in this project.

**Rule:** Successful SQL execution is different from successful COMMIT.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```sql
BEGIN;
-- Write related record A.
-- Write related record B.
COMMIT;
```

## Evidence to obtain

In a disposable test database, perform both writes and verify both through a new transaction after commit. Checking managed Java objects alone does not prove commit.

## Explain without looking

After the first INSERT succeeds, has the transaction committed?

## Source notes

- [Commit](https://www.postgresql.org/docs/18/sql-commit.html)
- [Proxy](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/annotations.html)
- [Hibernate](https://docs.hibernate.org/orm/6.6/userguide/html_single/#flushing)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
