# Concurrent refunds exceed the captured amount

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two people both see room in a jar and each fills it beyond its limit. Reserve capacity as part of adding, not in a separate earlier glance.

## Requirement

Total refund reservations must not exceed captured funds.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Two concurrent refunds both pass a stale available-balance check.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. A and B each request refund 80 against capture 100

2. Both separately read available 100

3. Both increment reserved without a guard

4. Combined reservation becomes 160, violating the limit

## Why the correction works

The predicate and increment are one database operation. Pair it with a unique operation key in the same transaction: guarded increments are not themselves idempotent if the same request is retried.

## Limits, alternatives and trade-offs

A provider refund is a separate external effect; failed/unknown submission needs its own state machine and reconciliation. Currency and capture identity must match. Signed bigint overflow and input bounds still require validation.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
