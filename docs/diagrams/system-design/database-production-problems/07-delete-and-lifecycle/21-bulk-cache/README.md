# Bulk updates leave managed objects stale

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Changing the official register does not update a photocopy already on your desk. Bulk SQL similarly bypasses previously loaded entity state.

## Requirement

Decisions after bulk updates must use fresh state without losing pending changes.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A JPQL/native bulk update changes rows while the persistence context still contains old entity values.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Load enabled=true into persistence context

2. Bulk UPDATE sets database row to false

3. Existing managed object still says true

4. Later logic makes a stale decision

## Why the correction works

clear detaches all managed entities and can discard unflushed changes. Spring Data @Modifying offers flushAutomatically/clearAutomatically; both default false. Configure deliberately, not as a substitute for understanding the context.

## Limits, alternatives and trade-offs

Bulk updates also need explicit tenant, version and state predicates. Clearing does not automatically repair external caches. Large deletes need bounded batches and retention checks.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://docs.spring.io/spring-data/jpa/docs/3.5.x/api/org/springframework/data/jpa/repository/Modifying.html)
- [Official reference](https://jakarta.ee/specifications/persistence/3.1/jakarta-persistence-spec-3.1.pdf)
