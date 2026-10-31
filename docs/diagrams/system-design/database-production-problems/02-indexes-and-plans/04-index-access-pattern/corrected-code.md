# Correction — An index that does not match the query

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Proposed index for this particular filter and ordering.
CREATE INDEX payments_merchant_recent ON payments(merchant_id, created_at DESC, id DESC);
-- Measure the same parameterised SELECT before and after on a scratch dataset.
```

Column ordering and selectivity matter. A matching B-tree can supply filtered ordered rows, but the planner chooses based on costs and data. Do not force an index solely because a sequential scan appears.

**Still required:** Small tables and broad filters may favour scans. Existing indexes may already cover the query. Build strategies and locking must be reviewed before a production migration. No index has been installed by this guide.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
