# SAVEPOINT: undo only the later portion

[Open the large diagram](06-savepoint.svg)

A savepoint permits partial database rollback. RELEASE SAVEPOINT removes the marker; it is not a commit. NESTED propagation uses savepoints only with suitable transaction-manager and driver support. JPA does not provide nested transaction semantics: rolling back JDBC state does not rewind the EntityManager cache. Do not add NESTED to this JPA repository and assume it is safe. First learn savepoints in an isolated JDBC/SQL exercise.

**Rule:** Use partial rollback only when the surviving work is valid on its own.

## Small example

Teaching fragment only; not executed or added to application code. It requires the surrounding transaction and setup described above.

```sql
BEGIN;
-- Write independent A.
SAVEPOINT optional_part;
-- Attempt optional B.
ROLLBACK TO SAVEPOINT optional_part;
COMMIT;
```

## Evidence to obtain

Using a scratch fixture, write A before the savepoint and B after it. Roll back to the savepoint, commit, and verify only A from a new transaction.

## Explain without looking

Is A already committed when the savepoint is created?

## Source notes

- [Savepoint](https://www.postgresql.org/docs/18/sql-rollback-to.html)
- [Jpa Manager](https://docs.spring.io/spring-framework/docs/6.2.x/javadoc-api/org/springframework/orm/jpa/JpaTransactionManager.html)

Verified against the linked public documentation. The scenario and diagrams are original teaching examples. No example was executed against a database.
