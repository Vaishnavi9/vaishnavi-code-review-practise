# Flush does not clear memory or commit batches

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Sending a copy of your notes does not empty your desk. Flushing SQL does not remove managed objects from Hibernate’s context.

## Requirement

Import bounded work without retaining every entity or accidentally changing atomicity.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A huge loop persists records and calls flush, but never clears the persistence context; one enormous transaction also holds locks and rollback work.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Import loads many rows and creates managed entities

2. flush sends SQL but retains managed objects

3. Persistence context and transaction grow

4. Heap, dirty checking, locks and rollback costs increase

## Why the correction works

clear detaches objects; batch size must be measured. JDBC batching requires appropriate configuration and compatible ID strategy/SQL patterns. A flush failure requires ending the unit of work.

## Limits, alternatives and trade-offs

Multiple committed chunks lose whole-import atomicity; use staging/publish designs if the business requires all-or-nothing visibility. Identity generation may require early INSERTs and constrain batching.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.hibernate.org/orm/6.6/userguide/html_single/#fetching)
- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
