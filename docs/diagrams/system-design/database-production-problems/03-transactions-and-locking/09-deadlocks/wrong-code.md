# Intentionally wrong example — Deadlocks and whole-transaction retry

Teaching fragment only. Do not install this in the application.

```sql
-- T1: lock A; then lock B
-- T2: lock B; then lock A
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. T1 holds A; T2 holds B

2. T1 waits for B

3. T2 waits for A; cycle exists

4. Database aborts a participant; application must handle failure

T1 locks account A then requests B; T2 locks B then requests A.
