# Database commit and event publish are two writes

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Saving an order and mailing its receipt are separate actions. Crashing between them leaves one done and the other missing.

## Requirement

Every committed business change must eventually produce its required event without duplicating downstream effects.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Application commits a row then crashes before publishing, or publishes before the database rollback.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Business row commits

2. Process crashes before event publish

3. No durable record says publish is still owed

4. Downstream system never learns about the change

## Why the correction works

The outbox closes the local dual-write gap, but delivery can repeat. Inbox uniqueness and effect must share an atomic boundary. Claim leases need expiry/recovery so crashed workers do not strand work.

## Limits, alternatives and trade-offs

Ordering, poison events, bounded retries, schema evolution and retention still need policy. This does not make arbitrary external side effects exactly once. Current small service has no implemented outbox flow even though the larger database has outbox tables.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html)
