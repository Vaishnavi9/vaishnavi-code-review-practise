# Function filters and stale planning assumptions

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Changing every label before searching defeats a catalogue organised by the original labels. A function on an indexed column can similarly require different indexing.

## Requirement

Search case-insensitively with explicitly chosen matching semantics.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A lookup uses lower(column) while only a plain column index exists; a deployment may also change data distribution.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Application transforms the search column with lower

2. Ordinary index may not support that expression lookup

3. Database evaluates many candidate rows

4. High traffic amplifies unnecessary CPU and reads

## Why the correction works

An expression index stores the searched expression. Alternatively store a separately normalised lookup key. Parameter types should match column types to avoid unwanted casts.

## Limits, alternatives and trade-offs

This does not fix leading-wildcard text search, incorrect joins, sort spills or low selectivity. Those require separate plan evidence. Normalisation and collation must preserve the product’s identity rules.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/indexes-expressional.html)
- [Official reference](https://www.postgresql.org/docs/18/using-explain.html)
