# Correction — Passing tests can hide missing commit and missing coverage

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Test design, not a runnable method.
run application operation through its real boundary
force required flush and allow transaction owner to commit
read from a fresh transaction/connection and assert stored invariant
for races: coordinate two connections with barriers, not arbitrary sleep
report discovered and executed tests, failures and skipped cases
```

Use PostgreSQL for PostgreSQL-specific constraints, isolation and SQL. Unit tests remain useful for pure logic but cannot establish database behaviour. This project’s TransactionPersistenceTest is empty; compile success is not passing persistence tests.

**Still required:** Mocks cannot reproduce database locks. Testcontainers require Docker and cleanup; a disposable local database is another option. Race tests must have bounded timeouts and clean resources even when assertions fail.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
