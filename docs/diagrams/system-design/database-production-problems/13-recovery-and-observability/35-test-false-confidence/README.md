# Passing tests can hide missing commit and missing coverage

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A rehearsal ending before the final act cannot prove the ending works. A test that always rolls back can miss commit-time failures.

## Requirement

Evidence must exercise the actual boundary and verify durable outcomes.

## Where it applies

Current persistence test class is empty. The guide’s separate scratch SQL checks do not constitute application integration test coverage.

## Production symptom and trigger

H2 differs from PostgreSQL, transactional tests roll back, sleep-based concurrency tests do not force overlap, or an empty test suite runs no assertions.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Test creates Java object and calls save

2. Assertion inspects only the object in memory

3. Test-owned transaction rolls back

4. No evidence establishes commit or concurrent correctness

## Why the correction works

Use PostgreSQL for PostgreSQL-specific constraints, isolation and SQL. Unit tests remain useful for pure logic but cannot establish database behaviour. This project’s TransactionPersistenceTest is empty; compile success is not passing persistence tests.

## Limits, alternatives and trade-offs

Mocks cannot reproduce database locks. Testcontainers require Docker and cleanup; a disposable local database is another option. Race tests must have bounded timeouts and clean resources even when assertions fail.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-boot/3.5/reference/testing/spring-boot-applications.html)
