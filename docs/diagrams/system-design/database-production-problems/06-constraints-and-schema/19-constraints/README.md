# Annotations do not guarantee installed constraints

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A rule printed on a form does not install a lock on a door. Mapping metadata likewise does not prove the deployed database enforces that rule.

## Requirement

Every write path must respect uniqueness, required data and valid references.

## Where it applies

Live constraints have been inspected and included in the schema snapshot. This is a diagnosis checklist, not evidence those constraints are missing.

## Production symptom and trigger

A schema migration is missing, dirty rows prevent adding a constraint, or code assumes @Column creates constraints in every environment.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Code declares mapping metadata

2. Environment does not generate or migrate that constraint

3. Another writer inserts invalid data

4. Application assumption is violated in stored rows

## Why the correction works

The live snapshot confirms the current composite unique key, required columns and checks. SQLSTATE distinguishes 23505 unique, 23502 not-null, 23503 foreign-key and 23514 check errors. Do not treat all as the same business conflict.

## Limits, alternatives and trade-offs

CHECK expressions evaluating NULL do not substitute for NOT NULL. PostgreSQL foreign keys do not automatically create a child-column index. Deferrable constraints may fail at commit; validation of ORM mappings is not validation of every business invariant.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/ddl-constraints.html)
