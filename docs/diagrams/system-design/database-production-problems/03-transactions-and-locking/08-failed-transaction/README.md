# Catching a constraint error does not repair a transaction

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A failed safety inspection leaves the work blocked until it is reset. Continuing paperwork does not remove the failed status.

## Requirement

Recover from conflicts without reporting a failed transaction as committed.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Code catches a duplicate-key exception then performs another query in the same aborted transaction; or inner REQUIRED marks rollback-only.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Transaction T1 tries a write

2. Immediate constraint fails; T1 is aborted

3. Java catch block runs, but T1 remains failed

4. Further SQL or eventual commit fails

## Why the correction works

The recovery boundary is outside the failed database transaction. Do not translate every integrity exception to an idempotency hit: NOT NULL, CHECK and unrelated unique constraints mean different things.

## Limits, alternatives and trade-offs

The algorithm requires actual new transaction ownership, not a same-object annotated call. Savepoints can recover SQL state in a deliberate JDBC design, but do not rewind Hibernate managed objects.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/tx-propagation.html)
- [Official reference](https://www.postgresql.org/docs/18/explicit-locking.html)
