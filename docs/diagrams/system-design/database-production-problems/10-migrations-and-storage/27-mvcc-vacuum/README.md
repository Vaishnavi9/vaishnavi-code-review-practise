# Long snapshots, dead tuples and storage growth

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

An archive cannot discard an old edition while someone still needs it. PostgreSQL keeps row versions needed by active snapshots.

## Requirement

Keep storage and cleanup healthy while preserving readers’ valid snapshots.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Long-running or idle-in-transaction sessions keep old versions relevant; update/delete-heavy tables grow and plans degrade.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. A transaction keeps an old snapshot open

2. Writers produce new versions and dead tuples

3. Vacuum cannot remove versions still potentially visible

4. Storage and scan costs can grow

## Why the correction works

MVCC allows readers and writers to coexist but retains versions for visibility. Ordinary VACUUM generally makes space reusable within the table; it is not the same as returning all file space to the operating system.

## Limits, alternatives and trade-offs

Replication slots and other retention mechanisms can also cause storage growth. VACUUM FULL rewrites and strongly locks a table; it is not a casual first response. Diagnose before applying disruptive actions.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/routine-vacuuming.html)
