# Cross-row invariants and write skew

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two guards each leave because the other appears to be present. Checking separate rows does not protect the rule that someone must stay.

## Requirement

Keep at least one available processing route for a merchant.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Two concurrent transactions disable different routes after each sees the other enabled.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. T1 and T2 each see two enabled routes

2. T1 disables A; T2 disables B

3. Updates touch different rows; row versions may not conflict

4. No route remains enabled

## Why the correction works

This invariant spans rows, so per-row versioning alone is insufficient. A shared coordination row makes the check and change serial for that merchant.

## Limits, alternatives and trade-offs

Serializable transactions with complete retries are an alternative. All writers must participate. Isolation reduces anomalies but does not invent business validation. Parent locking can limit throughput for a hot merchant.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Official reference](https://www.postgresql.org/docs/18/explicit-locking.html)
