# A backup is useful only if recovery works

[Atlas index](../../README.md) · [Problem diagram](diagram.md) · [Correction diagram](correction.md) · [Wrong code](wrong-code.md) · [Corrected code](corrected-code.md) · [Verification](verification.md)

## Everyday picture

A spare key is useful only if it opens the door. A backup needs an actual restore exercise to prove it can recover data.

## Requirement

Recover data within stated loss and time limits, then reconcile uncertain business effects.

## Where it applies

Hypothetical fixture; this is not an observed defect in the practice service.

## Production symptom and trigger

Backups exist but nobody has restored them; events/providers continued during the outage; restored state disagrees with external reality.

A tiny fixture, one request or warm caches may hide the trigger. Use the specific reproduction described in Verification before asserting this is the cause of a real incident.

## Trace the problem

1. Backup job reports success

2. Incident requires restoration

3. Missing logs, permissions or procedure block recovery

4. Restored local data may also disagree with external payments

## Why the correction works

RPO describes tolerated data loss; RTO describes tolerated recovery time. Schema-only restore, as done for this ERD, verifies structure reproduction only, not backup of payment data or point-in-time recovery.

## Limits, alternatives and trade-offs

Do not declare zero loss without matching durability/backup/replication evidence. Restore procedures must avoid contacting real providers with replayed data. Deletion and retention policies must retain the evidence recovery needs.

## Immediate containment versus durable fix

Containment: reduce or pause the affected workload under the incident runbook and retain evidence; do not disguise incorrect outcomes as success. The durable correction is the changed contract or code explained above and in the corrected snippet. Validate its own failure cases before rollout. Cancellation, live DDL or retry storms are not automatic recommendations.

## Explain it without notes

What invariant does this protect? Which exact line or boundary was wrong? What happens with two callers or a crash halfway through? Name an alternative and a requirement that would make you choose it.

## Sources

- [Official reference](https://www.postgresql.org/docs/18/backup.html)
