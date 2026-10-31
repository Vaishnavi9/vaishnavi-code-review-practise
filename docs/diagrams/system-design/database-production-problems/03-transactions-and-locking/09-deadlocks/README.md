# Deadlocks and whole-transaction retry

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two people each hold the key the other needs. Neither can progress until one gives up its work.

## Requirement

Transfer between accounts without indefinite waiting or partial effects.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

T1 locks account A then requests B; T2 locks B then requests A.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. T1 holds A; T2 holds B

2. T1 waits for B

3. T2 waits for A; cycle exists

4. Database aborts a participant; application must handle failure

## Why the correction works

Consistent lock order removes this particular cycle. Re-read values and rerun business checks inside the new attempt. Use SQLSTATE classification such as deadlock 40P01 and serialization 40001.

## Limits, alternatives and trade-offs

Other tables and triggers can introduce different lock paths. Lock timeout 55P03 is not identical to deadlock. Do not blindly retry external charging. Monitor lock waits, retries and exhausted attempts.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/explicit-locking.html)
- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
