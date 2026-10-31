# Correction — A backup is useful only if recovery works

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```text
// Recovery drill on isolated resources.
restore backup and required logs to a known recovery target
validate schema, row counts, constraints and representative business invariants
measure recovery time and document the recoverable-data window
reconcile provider operations and event positions before resuming effects
```

RPO describes tolerated data loss; RTO describes tolerated recovery time. Schema-only restore, as done for this ERD, verifies structure reproduction only, not backup of payment data or point-in-time recovery.

**Still required:** Do not declare zero loss without matching durability/backup/replication evidence. Restore procedures must avoid contacting real providers with replayed data. Deletion and retention policies must retain the evidence recovery needs.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
