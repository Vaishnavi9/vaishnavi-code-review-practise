# Collection fetch join and pagination

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A shop receipt spans several lines; taking ten lines is not taking ten receipts. Joined child rows are receipt lines, while a page promises parent records.

## Requirement

Return 20 distinct roots with complete children and stable ordering.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A collection fetch with a page can cause in-memory limiting, excessive reads, warnings or an exception if configured to fail.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Query joins payments with many operations

2. One root occupies multiple SQL rows

3. ORM may retrieve far more rows to preserve collections

4. Small page request consumes large time and memory

## Why the correction works

Separate selecting the page from loading its graph. Retain tenant predicates. Use one suitable snapshot if the contract requires both reads to see an identical point in time.

## Limits, alternatives and trade-offs

Two reads allow intervening changes under Read Committed. A DTO query or separate bounded children query may be simpler. Count totals separately only when required. Joining two collections can multiply rows severely.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.hibernate.org/orm/6.6/userguide/html_single/#fetching)
