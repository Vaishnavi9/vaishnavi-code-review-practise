# Schema changes break mixed application versions

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

Removing a bridge while people still use it breaks the journey. A column cannot disappear while an older application version still expects it.

## Requirement

Old and new application instances must coexist during rollout without corrupting data.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A column is renamed/dropped or tightened to NOT NULL before old writers and historical rows are compatible.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Old and new application instances coexist

2. Destructive migration removes a required column

3. Old SQL fails or dual-write fields diverge

4. Rolling deployment becomes an outage

## Why the correction works

Measure lock requirements and migration duration on representative data. PostgreSQL CREATE INDEX CONCURRENTLY is a separate tool with restrictions: it cannot run inside a normal transaction block and failed builds may leave invalid indexes.

## Limits, alternatives and trade-offs

Rollback of application code must remain compatible with the expanded schema. Dual writes need a defined consistency rule. Flyway presence alone does not mean the migration ran or the PostgreSQL database module/configuration is correct.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/sql-altertable.html)
