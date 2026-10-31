# Commit, rollback and flush — one concept at a time

Start with **01: Commit**, then **02: Full rollback**. Do not read every diagram at once. Each concept has a diagram-only Markdown file, a large black-and-white SVG, and a separate explanation with a small example and a check question.

| Order | Diagram | Explanation |
|---|---|---|
| 01 | [COMMIT: finish the database transaction](01-commit.md) | [Explanation](01-commit-explanation.md) |
| 02 | [ROLLBACK: discard the whole transaction](02-full-rollback.md) | [Explanation](02-full-rollback-explanation.md) |
| 03 | [SPRING: choose the rollback rule](03-spring-rollback-rules.md) | [Explanation](03-spring-rollback-rules-explanation.md) |
| 04 | [EXPLICIT ROLLBACK-ONLY](04-explicit-rollback-only.md) | [Explanation](04-explicit-rollback-only-explanation.md) |
| 05 | [CAUGHT FAILURE: the transaction can still be doomed](05-caught-inner-failure.md) | [Explanation](05-caught-inner-failure-explanation.md) |
| 06 | [SAVEPOINT: undo only the later portion](06-savepoint.md) | [Explanation](06-savepoint-explanation.md) |
| 07 | [REQUIRES_NEW: an independent transaction](07-independent-transaction.md) | [Explanation](07-independent-transaction-explanation.md) |
| 08 | [COMPENSATION: a new corrective action](08-compensation.md) | [Explanation](08-compensation-explanation.md) |
| 09 | [FLUSH: send the pending database work](09-flush-internals.md) | [Explanation](09-flush-internals-explanation.md) |
| 10 | [FLUSH POLICIES: when synchronization happens](10-flush-policies.md) | [Explanation](10-flush-policies-explanation.md) |
| 11 | [EXPLICIT FLUSH: ask for synchronization now](11-explicit-flush.md) | [Explanation](11-explicit-flush-explanation.md) |
| 12 | [FAILURE TIMING: flush success is not commit success](12-failure-timing.md) | [Explanation](12-failure-timing-explanation.md) |

## Relating this to our application

At inspection, TransactionService.create constructs one entity and calls repository.save. TransactionRepository declares transactional save and two read-only finders. The service create method itself is not annotated. This collection does not imply an outbox, a provider integration, or multi-write business logic is already implemented.

The examples assume ordinary Spring proxy-based transactions with one PostgreSQL database unless a diagram explicitly says otherwise. A new transaction is committed at its owning boundary; joined methods do not create independent commits. Atomicity does not mean requests execute one at a time. Read-only is not a replacement for permissions. Rollback does not rewind all Java state or external effects.

## Versions and verification

Sources: Spring Framework 6.2, Spring Data JPA 3.5, Hibernate ORM 6.6, and PostgreSQL 18 documentation. The later schema inspection confirmed PostgreSQL 18.6 locally. A source check is not a passing application test. Annotation, savepoint and flush behaviour can depend on the configured transaction manager, provider, database and invocation path.

All examples are fragments or pseudocode. Creating these diagrams did not implement transaction handling in the application. Later synthetic SQL/Hibernate checks are recorded in the [production atlas evidence](../database-production-problems/VERIFICATION.md); those checks do not validate every fragment in this folder. Existing diagrams were preserved. The current learner understanding is not assessed by creating these files.
