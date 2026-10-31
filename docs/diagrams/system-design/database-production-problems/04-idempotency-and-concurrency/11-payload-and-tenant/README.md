# Same idempotency key, different intent

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A ticket number cannot silently change from one journey to another. A request key similarly names one business intent within its owner’s scope.

## Requirement

Same merchant and key with different amount or currency must be rejected, not replayed as success.

## Where it applies

Current finder is merchant-scoped. Payload comparison and authentication-to-merchant binding are not demonstrated by the current create method.

## Production symptom and trigger

A client accidentally reuses a key, or another merchant uses the same text key.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Key K belongs to merchant A and amount 100

2. Caller sends K with amount 900, or another merchant

3. Lookup uses only K and blindly replays

4. Response refers to wrong intent or leaks another merchant’s data

## Why the correction works

For the current four-input constructor, amount and currency distinguish intent once merchant/key identify the row. A richer API must also include recipient, operation type and other semantic fields. Do not trust a client-supplied merchant claim alone.

## Limits, alternatives and trade-offs

Canonical payload hashing is useful for richer payloads but requires stable normalization and field definitions. A random request key does not authorize access. Retention/expiry must be part of the API contract.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
