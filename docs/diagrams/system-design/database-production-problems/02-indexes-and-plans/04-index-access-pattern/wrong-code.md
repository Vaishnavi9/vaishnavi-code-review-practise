# Intentionally wrong example — An index that does not match the query

Teaching fragment only. Do not install this in the application.

```sql
CREATE INDEX payments_status_only ON payments(status);
SELECT * FROM payments WHERE merchant_id = :m ORDER BY created_at DESC, id DESC LIMIT 20;
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Query filters by merchant and orders by time

2. Status index does not match these leading needs

3. Planner may scan and sort many rows

4. More data increases latency and database work

A growing table makes a frequently used filter/order query slow; extra indexes also slow writes.
