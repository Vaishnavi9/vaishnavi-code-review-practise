# DynamoDB PutItem replaces an existing item

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Putting a new form in the same file slot replaces the old form. PutItem uses the primary key to identify that slot.

## Requirement

Creating a new request must not overwrite a stored request under the same key.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

An unconditional PutItem is used as create-only or a partial update.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Stored item already owns primary key K

2. New request issues unconditional PutItem for K

3. Existing item is replaced, including omitted attributes

4. Previous data or idempotency evidence disappears

## Why the correction works

The condition and write are evaluated atomically for the item. With a composite key, it protects that exact key pair, not every item sharing the partition key. Use UpdateItem for deliberate partial changes, with expected-state/version conditions.

## Limits, alternatives and trade-offs

Conditions do not enforce global uniqueness across unrelated keys. Enhanced Client bean annotations map attributes; they do not automatically impose the business uniqueness contract. SDK dependencies are installed, but this project is not connected to DynamoDB.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html)
