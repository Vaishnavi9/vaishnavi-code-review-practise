# Master prompt: transactions, flush, commit, rollback and recovery

Create a rigorous, beginner-friendly learning pack for a generic Java/Spring payment application. Use the practice project at `/Users/vaishnavidhanwade/Desktop/vaishnavi-code-review-practise`. Do not use an actual payment company's name or suggest knowledge of its private architecture.

The learner wants to understand why each mechanism exists, what happens internally, how failures appear in production, and how to review and correct code independently. Assume no prior Java, Spring, Hibernate or database knowledge. Teach one concept at a time; do not read the whole catalogue aloud. Do not claim every imaginable failure is covered.

## Inspect before generating

Read build.gradle, the transaction entity, repository, service, SQL scripts, existing tests, and the existing documentation. Reuse the diagrams already in `docs/diagrams/system-design/rollback` rather than overwriting or duplicating them. Preserve learner edits. Inspect the actual dependency versions and use version-matched official documentation. The known baseline is Java 25, Spring Boot 3.5.11 and AWS SDK v2 BOM 2.57.7; resolve transitive versions instead of guessing. Do not treat source inspection as proof of live database state.

Current teaching baseline: the service constructs a transaction and calls repository.save; repository save is transactional; the narrow repository declares two finders. The SQL declares a primary key, non-null and check constraints, and uniqueness over merchant_id plus request_key. Do not imply that payment-provider calls, outbox persistence, relationships or a full ledger already exist.

## Output organisation

Use existing `docs/diagrams/system-design/rollback/` as the entry point. Create logical subfolders only when useful: `transaction-boundaries/`, `commit-and-durability/`, `rollback-rules/`, `savepoints/`, `flush/`, `concurrent-failures/`, `external-recovery/`, `verification/`. Keep working links to existing files. Add a numbered index and an explicit coverage/status matrix.

For each distinct scenario, provide:

1. One customer need and the invariant being protected.
2. Prerequisites and plain-language definitions.
3. A small synthetic starting state: rows, amounts, thread, connection and transaction identities.
4. A black-and-white diagram with large text, plus a diagram-only Markdown wrapper and a separate explanation. Distinguish a runtime sequence from a relationship map.
5. Numbered steps with before-and-after Java state, pending SQL, executed SQL and committed state. Show the exact commit owner and all transaction boundaries.
6. A deliberately wrong Java/SQL fragment labelled WRONG, and an explanation of why it fails under a specific interleaving or fault.
7. The smallest corrected fragment labelled CORRECTED FOR THESE ASSUMPTIONS. Include imports, framework/API versions, required setup and transaction invocation path. State whether it is complete, a fragment or pseudocode.
8. An explanation of the runtime mechanism: proxy, transaction interceptor, transaction manager, EntityManager, Hibernate persistence context/dirty checking/ActionQueue, JDBC connection, driver and PostgreSQL, only as relevant.
9. Observable symptoms, the evidence needed to distinguish causes, and a meaningful test with a predicted result. Keep expected results separate from actual executions.
10. One alternative, its cost, and when changed requirements favour it.
11. One closed-book question and one independently implementable variation.
12. Official source links, verification date, limitations and a status: documented, proposed, compiled, executed, or unverified. Keep learner understanding separately tracked.

## Required transaction scenarios

Cover all items below; split large cases instead of compressing them into one oversized diagram.

### Boundaries and normal completion

- One repository save with no outer transaction; multiple repository calls without a shared service transaction; the same calls under a service transaction.
- Method return versus transaction completion; a joined transaction versus its owning outer boundary.
- Field/property mapping versus database enforcement; annotation metadata versus active transaction management.
- Proxy interception, same-object self-invocation, unmanaged objects created with new, visibility/proxy constraints and methods reached from tests.
- REQUIRED, REQUIRES_NEW, NESTED, SUPPORTS, MANDATORY, NOT_SUPPORTED and NEVER: required preconditions, what joins, suspends or fails, and why each might be used.
- Transaction-scoped connections, lazy connection acquisition where applicable, pool return, resource cleanup and accidental use of a separate connection.
- Thread-bound transaction context; executor/async work that does not inherit it; reactive context as a separate model, not a drop-in equivalent.

### Commit and durability

- Flush before commit; commit failure after a successful method body; deferred constraints; durability settings and WAL, with crash guarantees stated under their assumptions.
- Successful commit with lost HTTP response; lost database commit acknowledgement; retry resolving an already committed operation by stable identity.
- Visibility to a new read versus an older snapshot and a lagging replica. Do not say commit makes every replica or existing snapshot immediately current.
- Sequence/identity allocation and gaps after rollback; generated IDs do not prove committed rows.

### Rollback decisions and exceptions

- RuntimeException, Error and checked exceptions under standard defaults; rollbackFor/noRollbackFor; typed rules versus name patterns and conflicting specificity.
- Global rollback configuration and version-specific defaults.
- Exception thrown before SQL, during flush, at commit, or after commit.
- Catch-and-swallow, rethrow, exception translation, wrapping and rollback-only markers.
- An inner REQUIRED transaction marks rollback-only; outer code catches the exception; UnexpectedRollbackException at completion.
- Programmatic TransactionTemplate and setRollbackOnly; reporting an explicit unsuccessful business outcome.
- Read-only hints, actual database enforcement and permissions: do not present readOnly as a security mechanism.
- A failed PostgreSQL statement and the aborted transaction; when rollback or rollback-to-savepoint is necessary. Do not continue using an inconsistent Hibernate session.

### Partial and independent work

- Full rollback versus SAVEPOINT, ROLLBACK TO SAVEPOINT and RELEASE SAVEPOINT.
- Savepoint support in JDBC; transaction-manager compatibility; JPA persistence-context state is not rewound by JDBC savepoints.
- REQUIRES_NEW committing or failing while the outer transaction does the opposite; pool exhaustion and lock contention caused by extra independent connections.
- Choosing a whole-transaction retry instead of savepoints; bounded attempts and safe re-evaluation of business rules.
- Separate databases, XA/two-phase commit where supported, and why a normal local JPA transaction does not coordinate arbitrary resources.

### Flush internals and policies

- Managed, transient, detached and removed entities; persist versus merge; the managed return value of merge/save; dirty checking and write-behind.
- ActionQueue and statement ordering; SQL execution is not necessarily Java invocation order. No global or durable queue is implied.
- JPA AUTO and COMMIT; Hibernate ALWAYS and MANUAL; explicit flush is distinct from selecting MANUAL mode.
- Flush at transaction completion, before relevant queries, and native-query behaviour under the exact API/provider version.
- EntityManager.flush, JpaRepository.flush, saveAndFlush and saveAllAndFlush; whole-context effects and repository API availability.
- Identity-generated inserts that execute early; constraints can fail before, during or after a planned flush point.
- Immediate versus deferred constraints; successful flush does not promise successful commit.
- Batching and flush frequency; flush then clear for bounded persistence-context memory; clear without flushing may discard pending changes. Clearing is not committing.
- Mixing bulk updates/native SQL with managed state; stale first-level cache, clear/refresh and update counts.
- Spring read-only optimisations and flush behaviour; never invent portable guarantees.

### Payment failure and concurrency scenarios

- Concurrent duplicate create requests, duplicate with different details, original receipt and merchant-scoped uniqueness.
- Two concurrent refund reservations; lost updates; optimistic version conflict; conditional update versus row lock.
- Deadlock, lock timeout, serialization failure and retry of the whole unit with fresh state.
- Payment plus outgoing event in one local transaction; relay retry and duplicate-safe consuming.
- External provider success followed by local rollback; provider timeout with unknown outcome; late/duplicate webhook; cancellation racing success.
- Compensation/void/refund as new business operations, not database rollback; idempotent recovery and reconciliation.
- Audit facts versus success claims; independently committed audit data must not falsely assert that a failed business transaction succeeded.

## Verification discipline

Use isolated synthetic fixtures. Do not modify the interview repository, existing application properties, credentials, live data or cloud resources. Do not run destructive SQL or provider calls. Ask for specific missing environment facts rather than inventing them. Avoid automatic application implementation: the learner types application code. Documentation and approved dependency changes are permitted.

Design tests that prove state after the real transaction boundary. Explain how @Transactional tests, automatic rollback, cached entities, H2 differences and caught exceptions can hide defects. Use coordinated concurrency tests with barriers/latches and bounded waits rather than sleeps. Assert committed rows, constraints, side-effect count and recovery state, not just HTTP success or log lines. Never call NO-SOURCE passing tests.

Prioritise: commit versus flush, default rollback, outer transaction scope, concurrent uniqueness, failed-transaction recovery, then advanced propagation. Explain one scenario, ask the learner to predict the result, wait for their answer, and only then discuss the fix.
