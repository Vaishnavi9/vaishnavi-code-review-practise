# Intentionally wrong example — Unbounded reads, offset cost and unstable pages

Teaching fragment only. Do not install this in the application.

```sql
SELECT * FROM payments ORDER BY created_at OFFSET 1000000 LIMIT 50;
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Data grows; client asks for a deep page

2. OFFSET scans and discards many earlier results

3. Concurrent changes shift row positions

4. Slow pages can skip or repeat entries

findAll materialises growing data; deep OFFSET reads/discards earlier rows; sorting by timestamp alone has ties.
