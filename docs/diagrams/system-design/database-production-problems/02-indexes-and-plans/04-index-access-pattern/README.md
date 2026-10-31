# An index that does not match the query

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A phone book sorted by surname is awkward for searching by street. A database index is also ordered for particular access patterns.

## Requirement

Find one merchant’s recent payments without assuming any index guarantees speed.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

A growing table makes a frequently used filter/order query slow; extra indexes also slow writes.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Query filters by merchant and orders by time

2. Status index does not match these leading needs

3. Planner may scan and sort many rows

4. More data increases latency and database work

## Why the correction works

Column ordering and selectivity matter. A matching B-tree can supply filtered ordered rows, but the planner chooses based on costs and data. Do not force an index solely because a sequential scan appears.

## Limits, alternatives and trade-offs

Small tables and broad filters may favour scans. Existing indexes may already cover the query. Build strategies and locking must be reviewed before a production migration. No index has been installed by this guide.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/indexes-multicolumn.html)
- [Official reference](https://www.postgresql.org/docs/18/using-explain.html)
