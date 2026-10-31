# MongoDB unique identity needs an actual index

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Writing a rule on each form does not prevent two clerks accepting the same booking. The collection needs a shared enforcement mechanism.

## Requirement

One merchant/request pair must identify one document.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Two find-then-insert callers race; an annotation is assumed to have created a production index.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Two clients read missing key

2. Both attempt document insertion

3. Without a unique index, both can exist

4. Application has two records for the same request

## Why the correction works

MongoDB single-document atomicity does not enforce uniqueness across different documents by itself. Sharded-collection unique-index restrictions and shard-key design must be considered separately.

## Limits, alternatives and trade-offs

Existing duplicates prevent index creation. Missing/null values and partial indexes alter uniqueness semantics. This project has no MongoDB connection or dependency; no Mongo examples were executed.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.mongodb.com/docs/manual/core/index-unique/)
