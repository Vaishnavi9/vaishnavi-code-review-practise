# Correction — Long snapshots, dead tuples and storage growth

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Operational diagnosis, not a blanket kill/vacuum script.
SELECT state, xact_start, wait_event_type, wait_event
FROM pg_stat_activity WHERE xact_start IS NOT NULL;
-- Bound application transaction lifetime; monitor autovacuum and dead tuples.
-- Review specific old sessions before any cancellation.
```

MVCC allows readers and writers to coexist but retains versions for visibility. Ordinary VACUUM generally makes space reusable within the table; it is not the same as returning all file space to the operating system.

**Still required:** Replication slots and other retention mechanisms can also cause storage growth. VACUUM FULL rewrites and strongly locks a table; it is not a casual first response. Diagnose before applying disruptive actions.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
