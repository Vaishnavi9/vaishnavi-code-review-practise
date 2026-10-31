# save can merge and return a different managed object

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Handing in a photocopy does not make it the original record. Merge copies state into a managed object and returns that object.

## Requirement

Modify the correct managed entity and avoid accidental overwrite from incomplete detached objects.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Code ignores the object returned by merge/save or constructs a partial entity with an existing ID.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Detached object has an existing identifier

2. save may use EntityManager.merge based on newness detection

3. Merge returns managed state; input is not made managed

4. Changes to the detached input can be lost or overwrite data on another merge

## Why the correction works

Spring Data newness detection considers version/ID and optional Persistable rules. An assigned UUID alone does not guarantee persist is selected. Use the returned save result when applicable. A load-and-update avoids treating a partial payload as a complete entity.

## Limits, alternatives and trade-offs

Current Transaction has constructor-assigned UUID, no @Version, and no setters. The example uses a hypothetical mutable Merchant; do not paste it into the current model. Merge can still issue an INSERT for a new assigned-ID object.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
- [Official reference](https://docs.spring.io/spring-data/jpa/reference/3.5/jpa/entity-persistence.html)
