# Duplicate and out-of-order outcomes

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Reading an older delivery notice after a newer one should not send the parcel backward. Event consumers need a rule for stale updates.

## Requirement

Repeated or stale outcomes must not duplicate effects or regress an authoritative state.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A delayed pending event arrives after success; two workers process the same event.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. SUCCESS for operation K is committed

2. Older PENDING event or duplicate SUCCESS arrives

3. Blind overwrite regresses state or repeats an effect

4. Merchant view and accounting become inconsistent

## Why the correction works

A timestamp alone is not reliable causal order across clocks. Use provider sequence/version only where documented. Compare-and-set guards and transition rules must be operation-specific: a refund is not simply payment success becoming failure.

## Limits, alternatives and trade-offs

Terminal-state assumptions can be wrong for some products; define the state machine first. Poison events need bounded retries and a repair path. An inbox table alone does not implement correct handling.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html)
