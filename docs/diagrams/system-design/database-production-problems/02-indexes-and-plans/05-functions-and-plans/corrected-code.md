# Correction — Function filters and stale planning assumptions

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Hypothetical schema: name is text. Check the actual query plan.
CREATE INDEX merchants_lower_name ON merchants(lower(name));
SELECT id FROM merchants WHERE lower(name) = lower(:name);
```

An expression index stores the searched expression. Alternatively store a separately normalised lookup key. Parameter types should match column types to avoid unwanted casts.

**Still required:** This does not fix leading-wildcard text search, incorrect joins, sort spills or low selectivity. Those require separate plan evidence. Normalisation and collation must preserve the product’s identity rules.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
