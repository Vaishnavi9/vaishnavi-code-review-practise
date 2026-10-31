# Correction — Cross-row invariants and write skew

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Option: serialize all route edits for the merchant on a parent row.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT id FROM merchants WHERE id = :m FOR UPDATE;
-- Now read routes, validate at least one remains, then update.
COMMIT;
-- Every writer must follow this same locking protocol.
```

This invariant spans rows, so per-row versioning alone is insufficient. A shared coordination row makes the check and change serial for that merchant.

**Still required:** Serializable transactions with complete retries are an alternative. All writers must participate. Isolation reduces anomalies but does not invent business validation. Parent locking can limit throughput for a hot merchant.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
