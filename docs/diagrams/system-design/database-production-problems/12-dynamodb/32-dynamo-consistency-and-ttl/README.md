# DynamoDB index lag and TTL are not correctness gates

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A directory can lag behind its source, and an expiry label is not an immediate shredder. Index visibility and physical TTL deletion are different from business validity.

## Requirement

Do not accept a duplicate or expired operation solely because an index is stale or an expired item still exists.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A GSI query misses a just-written item; code assumes TTL removes data immediately at the expiry second.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Base-table write succeeds

2. GSI has not caught up, or TTL cleanup has not happened

3. Application treats visibility as the business rule

4. Duplicate acceptance or stale validity decision occurs

## Why the correction works

A strong read does not lock the row for a later write; use conditions for races. TTL cleanup is asynchronous. Retaining or deleting an idempotency record changes retry behaviour and must be intentional.

## Limits, alternatives and trade-offs

Hot partition keys, scans and oversized items are separate access-pattern/capacity problems. Shard only with a plan for queries, uniqueness and aggregation. Do not promise exact timing for TTL deletion.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html)
- [Official reference](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
