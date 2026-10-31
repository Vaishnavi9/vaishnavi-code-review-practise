# Intentionally wrong example — Function filters and stale planning assumptions

Teaching fragment only. Do not install this in the application.

```sql
SELECT id FROM merchants WHERE lower(name) = lower(:name);
-- Assume the ordinary index on name makes this efficient.
```

Read it with the [failure sequence](diagram.md). The defect and its causal steps are:

1. Application transforms the search column with lower

2. Ordinary index may not support that expression lookup

3. Database evaluates many candidate rows

4. High traffic amplifies unnecessary CPU and reads

A lookup uses lower(column) while only a plain column index exists; a deployment may also change data distribution.
