# Soft delete does not automatically change visibility or uniqueness

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Crossing a name off a list does not remove it from every photocopy. A deleted flag needs consistent use by all read and write paths.

## Requirement

Retired records must be hidden where required without erasing financial evidence or accidentally freeing permanent identities.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Queries forget deleted_at; a unique constraint blocks intended reuse or a partial index wrongly permits reuse of a permanent idempotency key.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Record is marked deleted

2. An unfiltered read still returns it

3. Old uniqueness rules and new reuse expectations conflict

4. Leaked retired data or unintended identity reuse results

## Why the correction works

Soft deletion is an application/database contract, not one magic annotation. Partial uniqueness is one option for reusable active names, not a universal solution.

## Limits, alternatives and trade-offs

Restoring a retired row can conflict with a new active one. Cleanup must be bounded and must not delete evidence needed for payment recovery. Cascades and native queries can bypass ORM filtering.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
