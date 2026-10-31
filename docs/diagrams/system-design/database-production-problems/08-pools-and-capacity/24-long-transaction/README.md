# Network calls hold database transactions open

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Holding the checkout counter while phoning someone blocks everyone behind you. A transaction can likewise hold locks during a slow remote call.

## Requirement

Keep database transactions short and recover external payment outcomes safely.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A provider slows down while a service transaction holds row locks and a database connection.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Begin transaction and acquire locks

2. Call remote provider while transaction stays open

3. Slow provider holds local resources for a long time

4. Timeout may roll back local data after provider already charged

## Why the correction works

The corrected algorithm exposes the distributed boundary instead of implying database rollback reverses a remote charge. It requires worker recovery, provider idempotency where supported, and an explicit pending state.

## Limits, alternatives and trade-offs

This is a broader design, not a drop-in method. A brief synchronous call may fit another contract, but timeout uncertainty still exists. Limit transaction duration and monitor lock ages.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html)
- [Official reference](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga-orchestration.html)
