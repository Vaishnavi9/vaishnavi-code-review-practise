# MongoDB stale read–modify–write

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Two people edit the same copied total; the final copy overwrites the other. A guarded change applies directly to the current record.

## Requirement

Reserve funds without overwriting concurrent updates or spending more than available.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A read followed by $set writes a balance computed from stale data.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Two callers read available=100

2. Each computes a replacement value

3. Both write without an expected-state predicate

4. One change is lost or funds are over-reserved

## Why the correction works

The conditional update protects this single document. $inc alone does not deduplicate repeated requests. Multi-document operations need an explicit atomicity design, potentially a supported multi-document transaction.

## Limits, alternatives and trade-offs

JavaScript numeric examples require safe integer bounds; monetary BSON Long/Decimal128 needs compatible mapping. Different read/write concerns affect durability and visibility. No live Mongo tests have run.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.mongodb.com/docs/manual/core/write-operations-atomicity/)
