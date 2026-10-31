# Two writers overwrite each other

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two editors start from the same draft and the second save erases the first edit. A version number tells the second editor that the draft changed.

## Requirement

A concurrent update must not silently erase another committed update.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Both requests read version 0; both write a value derived from that stale state.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. T1 and T2 read balance 100, version 0

2. T1 computes 90; T2 computes 80

3. Both unconditional UPDATEs succeed

4. Last write wins; one intended change is lost

## Why the correction works

The version predicate makes the check and write atomic. Check the affected-row count. Hibernate @Version implements optimistic locking for supported entity operations; bulk/custom SQL must preserve the invariant explicitly.

## Limits, alternatives and trade-offs

A version conflict does not mean retry the stale calculated value. Atomic arithmetic updates or pessimistic locking can fit other requirements. @Version alone does not prevent cross-row write skew.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
