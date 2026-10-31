# Intentionally wrong example — Cross-row invariants and write skew

Teaching fragment only. Do not install this in the application.

```sql
-- Snapshot: both route A and route B are enabled.
-- T1 checks B, disables A. T2 checks A, disables B.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. T1 and T2 each see two enabled routes

2. T1 disables A; T2 disables B

3. Updates touch different rows; row versions may not conflict

4. No route remains enabled

Two concurrent transactions disable different routes after each sees the other enabled.
