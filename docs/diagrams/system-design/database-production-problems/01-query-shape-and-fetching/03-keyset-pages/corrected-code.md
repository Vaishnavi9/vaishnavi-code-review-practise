# Correction — Unbounded reads, offset cost and unstable pages

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Named parameters are illustrative: bind them with a database client.
SELECT id, created_at FROM payments
WHERE merchant_id = :merchant
  AND (created_at, id) > (:last_time, :last_id)
ORDER BY created_at, id LIMIT 50;
-- For this pattern consider an index on (merchant_id, created_at, id).
```

The ID breaks timestamp ties; the cursor must preserve all ordering/filter semantics. Validate cursor ownership and limits. Keyset pagination helps sequential navigation; it is not an exact snapshot of a changing collection.

**Still required:** Use immutable ordering fields, or updates can move rows across the cursor. A report needing one stable snapshot needs a different export/snapshot design. Keyset does not provide arbitrary page numbers or total count cheaply.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
