# Correction — Check then insert is not atomic

Focused fragment or algorithm under the assumptions in the [scenario](README.md). It is not a complete drop-in implementation.

```sql
-- Existing schema has UNIQUE (merchant_id, request_key).
INSERT INTO paymesh.transactions(id,merchant_id,request_key,amount_minor,currency)
VALUES (:id,:merchant,:key,:amount,:currency)
ON CONFLICT (merchant_id,request_key) DO NOTHING
RETURNING id;
-- If no ID: issue a separate SELECT in Read Committed, then compare payload.
-- Require a retention rule so the winning row cannot disappear during replay.
```

The database unique constraint is the arbiter. A Java synchronized block cannot protect multiple application instances. NOT NULL prevents missing values; it does not replace uniqueness.

**Still required:** DO NOTHING does not return the existing row. A same-statement CTE can fail to see a concurrent winner due to snapshot timing. Higher isolation can require whole-transaction retry. This creates a local record, not an exactly-once external charge.

Follow the [corrected sequence](correction.md). Read [verification](verification.md) before treating this as proven for your application.
