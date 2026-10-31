# Read replica and cache lag after a write

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A noticeboard copied every minute can lag behind the official register. A replica or cache can similarly be temporarily stale.

## Requirement

A freshly accepted payment must not be treated as missing or safe to recreate because a read is stale.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

POST commits to primary; immediate GET reads a lagging replica or old cache entry.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Primary commits payment P

2. Replica or cache has not received P

3. Client sees missing on a stale GET

4. Naive retry creates another business operation

## Why the correction works

Consistency depends on the read path. A cache invalidation can race an older read that repopulates stale data; versioned updates, bounded staleness and bypass rules may be needed.

## Limits, alternatives and trade-offs

Primary reads do not fix client authorization, commit ambiguity or incorrect state transitions. Stronger read routing costs primary capacity. A report can tolerate lag where payment authorization cannot.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/transaction-iso.html)
