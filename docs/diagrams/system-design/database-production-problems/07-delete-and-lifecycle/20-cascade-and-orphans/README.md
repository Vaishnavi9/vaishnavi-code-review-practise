# Cascade delete, orphan removal and shared children

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Removing a booking should not demolish the shared hotel. An entity association must distinguish owned children from shared resources.

## Requirement

Delete only data that belongs exclusively to the deleted aggregate.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

CascadeType.REMOVE propagates through shared relationships; changing the inverse side alone leaves the owning foreign key unchanged.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Two merchants refer to the same shared method

2. One merchant is removed with REMOVE cascade

3. ORM tries to remove the shared method too

4. FK failure or unintended shared-data deletion follows

## Why the correction works

ORM cascade propagates entity operations; database ON DELETE CASCADE is a separate FK rule. orphanRemoval applies to supported owned associations when removed from the relationship. Maintain the owning side and in-memory inverse side consistently.

## Limits, alternatives and trade-offs

Financial history usually needs explicit retention policy, not blanket cascading. Soft delete adds filtering and uniqueness concerns. JPA bulk deletion bypasses individual entity callbacks and ORM cascades; database constraints still apply.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
