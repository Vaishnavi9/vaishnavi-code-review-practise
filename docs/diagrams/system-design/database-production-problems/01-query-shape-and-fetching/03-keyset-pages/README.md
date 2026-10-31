# Unbounded reads, offset cost and unstable pages

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Reading a whole library to answer one page request wastes effort. A bookmark lets the next request start after the last known item.

## Requirement

Bound memory and page work; define behaviour when data changes between pages.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

findAll materialises growing data; deep OFFSET reads/discards earlier rows; sorting by timestamp alone has ties.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Data grows; client asks for a deep page

2. OFFSET scans and discards many earlier results

3. Concurrent changes shift row positions

4. Slow pages can skip or repeat entries

## Why the correction works

The ID breaks timestamp ties; the cursor must preserve all ordering/filter semantics. Validate cursor ownership and limits. Keyset pagination helps sequential navigation; it is not an exact snapshot of a changing collection.

## Limits, alternatives and trade-offs

Use immutable ordering fields, or updates can move rows across the cursor. A report needing one stable snapshot needs a different export/snapshot design. Keyset does not provide arbitrary page numbers or total count cheaply.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/indexes-multicolumn.html)
- [Official reference](https://www.postgresql.org/docs/18/using-explain.html)
