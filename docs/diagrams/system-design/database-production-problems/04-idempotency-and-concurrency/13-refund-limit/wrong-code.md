# Intentionally wrong example — Concurrent refunds exceed the captured amount

Teaching fragment only. Do not install this in the application.

```sql
-- Both read captured=100, reserved=0, then each reserve 80.
UPDATE refund_budget SET reserved = reserved + 80 WHERE payment_id = :id;
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. A and B each request refund 80 against capture 100

2. Both separately read available 100

3. Both increment reserved without a guard

4. Combined reservation becomes 160, violating the limit

Two concurrent refunds both pass a stale available-balance check.
