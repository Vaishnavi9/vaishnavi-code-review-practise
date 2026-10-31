# Connections are not returned to the pool

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A library runs out of books when borrowers never return them. A connection pool likewise has a finite number of reusable connections.

## Requirement

Return resources on success and failure without closing a transaction-owned connection incorrectly.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A JDBC connection or result stream leaks on exceptions; active pool count stays high after requests finish.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Each request borrows one connection

2. Failure skips cleanup

3. Pool reaches its connection limit

4. New requests wait and time out without reaching SQL

## Why the correction works

AutoCloseable allows try-with-resources. JdbcTemplate manages JDBC resources and participates in Spring transactions. Direct getConnection can bypass the transaction-bound connection depending on the DataSource wrapper; do not mix access styles casually.

## Limits, alternatives and trade-offs

A pool timeout is not proof of a leak: slow queries, blocked locks or too much concurrency also occupy connections. Increasing pool size can worsen database overload.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-framework/reference/6.2/data-access/jdbc/core.html)
- [Official reference](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
