# Intentionally wrong example — Two writers overwrite each other

Teaching fragment only. Do not install this in the application.

```sql
UPDATE accounts SET balance_minor = :previously_calculated_balance WHERE id = :id;
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. T1 and T2 read balance 100, version 0

2. T1 computes 90; T2 computes 80

3. Both unconditional UPDATEs succeed

4. Last write wins; one intended change is lost

Both requests read version 0; both write a value derived from that stale state.
