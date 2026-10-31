# Intentionally wrong example — Long snapshots, dead tuples and storage growth

Teaching fragment only. Do not install this in the application.

```sql
-- Open a transaction, read data, then leave it idle for hours while writers continue.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. A transaction keeps an old snapshot open

2. Writers produce new versions and dead tuples

3. Vacuum cannot remove versions still potentially visible

4. Storage and scan costs can grow

Long-running or idle-in-transaction sessions keep old versions relevant; update/delete-heavy tables grow and plans degrade.
