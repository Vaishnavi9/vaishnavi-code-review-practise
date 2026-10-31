# A timeout does not prove payment failure

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A lost receipt does not prove the purchase never happened. A provider can complete work while its reply is lost.

## Requirement

Never create a second charge merely because the first result is unknown.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Connection times out after the provider receives a payment; application retries using a new provider operation key.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Provider receives operation K and may complete it

2. Response is lost; local caller sees timeout

3. Caller retries with fresh identity K2

4. Provider may accept two distinct charges

## Why the correction works

Database rollback cannot undo an already completed provider action. Compensation such as refund is a new operation with its own idempotency, possible failure and accounting entries.

## Limits, alternatives and trade-offs

Not every provider supports idempotency or status lookup; such cases require explicit operational reconciliation. A UI pending state can be safer than falsely reporting failure or success. Preserve audit evidence.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga-orchestration.html)
