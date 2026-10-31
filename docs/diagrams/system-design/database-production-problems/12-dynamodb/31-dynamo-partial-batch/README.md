# DynamoDB batch success can contain unfinished work

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A courier can deliver some parcels and return the rest. Receiving a batch response does not prove every item was delivered.

## Requirement

Track every requested write to completion or durable retry without claiming partial success is total success.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

BatchWriteItem response has UnprocessedItems which the application ignores.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Submit batch of puts/deletes

2. Service processes some items and returns others unprocessed

3. Application ignores the remaining list

4. Caller is told all succeeded while some data is missing

## Why the correction works

BatchWriteItem is not one atomic transaction and does not support per-item conditional expressions. Whole-call errors also need a defined retry path. Repeating unconditional puts can overwrite newer data, so workload semantics matter.

## Limits, alternatives and trade-offs

Use TransactWriteItems for a supported all-or-nothing set when required, with its limits and conflict handling. Do not retry forever or hide failures. No live Dynamo batch test was run.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html)
